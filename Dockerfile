# Galaxy - CLIA Germline
#
# VERSION       0.2

FROM centos:6

MAINTAINER Evan F. Bollig, boll0107@umn.edu

ENV GALAXY_CONFIG_BRAND clia-cnv

WORKDIR /root

RUN yum update -y
# Needed to get R
RUN yum install -y epel-release

RUN yum install -y git
RUN yum install -y unzip
RUN yum install -y ant
RUN yum install -y perl 
RUN yum install -y R
RUN yum install -y bwa
RUN yum install -y samtools

#DONE: install bowtie
RUN curl -L -O https://github.com/BenLangmead/bowtie2/releases/download/v2.2.6/bowtie2-2.2.6-linux-x86_64.zip \
    && unzip bowtie2-2.2.6-linux-x86_64.zip \ 
    && find bowtie2-* -perm -100 -name 'bowtie*' -type f | xargs -i cp {} /usr/bin/.

#DONE: install picard-tools
RUN curl -L -O https://github.com/broadinstitute/picard/releases/download/1.137/picard-tools-1.137.zip \
    && unzip picard-tools-1.137.zip \ 
    && cp -r picard-tools-1.137 /usr/bin/picard

ENV PATH=$PATH:/usr/bin/picard
ENV CLASSPATH=$CLASSPATH:/usr/bin/picard
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/bin/picard
#TODO: RUN mkdir -p /scratch.local/evan/picard_temp 
#TODO: ENV _JAVA_OPTIONS -Djava.io.tmpdir=/scratch.local/evan/picard_temp 
ENV PTOOL="java -jar /usr/bin/picard"

RUN R CMD javareconf
        #install.packages( 'devtools' ); \ 
        #require(devtools); \
RUN yum install -y mysql-devel mysql-lib 
RUN R --vanilla --slave <<< " \
        r <- getOption(\"repos\"); \
        r[\"CRAN\"] <- \"http://cran.rstudio.com/\"; \ 
        options(repos=r); \
        install.packages(c('MASS', 'calibrate', 'getopt', 'optparse', 'plotrix', 'DBI', 'RMySQL', 'zoo', 'diptest', 'randomForest')); \
        "
RUN yum install -y perl-DBD-MySQL perl-Exporter-Tiny perl-DBI

RUN yum install -y tar
RUN git clone https://github.com/getiria-onsongo/tso_cnv.git /root/tso_cnv 
RUN cd /root/tso_cnv && \ 
    curl -L -O https://s3.msi.umn.edu/CNVMySQL/mysql-5.6.24-linux-glibc2.5-x86_64.tar.gz

#TODO: 
RUN mkdir -p /root/tso_cnv/tso_tables && \ 
    cd /root/tso_cnv/tso_tables && \ 
    curl -L -O https://s3.msi.umn.edu/CNVMySQL/mysql_tables.tar.gz && \
    tar xzvf mysql_tables.tar.gz

#TODO: allow runtime my.cnf and config_template.ini

RUN yum install -y mysql-server
RUN /sbin/service mysqld start

# Mark folders as imported from the host.
VOLUME ["/export/", "/data/", "/var/lib/docker"]

# Expose port 80 (webserver), 21 (FTP server), 8800 (Proxy)
#EXPOSE :80
#EXPOSE :21
#EXPOSE :8800

# Autostart script that is invoked during container start
CMD ["/bin/bash"]

#TODO: CMD for launching given a sample sheet
