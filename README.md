## DEPENDENCIES

### SOFTWARE
- perl 
- R version 3.1.1
- bwa
- bowtie2
- picard-tools
- samtools

### PERL PACKAGES
- DBD           [http://search.cpan.org/CPAN/authors/id/C/CA/CAPTTOFU/DBD-mysql-4.031.tar.gz]
- Exporter-Tiny [http://search.cpan.org/CPAN/authors/id/T/TO/TOBYINK/Exporter-Tiny-0.042.tar.gz]
- DBI           [http://search.cpan.org/CPAN/authors/id/T/TI/TIMB/DBI-1.633.tar.gz]

### R PACKAGES
- MASS         [http://cran.r-project.org/src/contrib/MASS_7.3-40.tar.gz]
- calibrate    [http://cran.r-project.org/src/contrib/calibrate_1.7.2.tar.gz]
- getopt       [http://cran.r-project.org/src/contrib/getopt_1.20.0.tar.gz]
- optparse     [http://cran.r-project.org/src/contrib/optparse_1.3.0.tar.gz]
- plotrix      [http://cran.r-project.org/src/contrib/plotrix_3.5-11.tar.gz]
- DBI          [http://cran.r-project.org/src/contrib/DBI_0.3.1.tar.gz]
- RMySQL       [http://cran.r-project.org/src/contrib/RMySQL_0.10.3.tar.gz]
- zoo          [http://cran.r-project.org/src/contrib/zoo_1.7-12.tar.gz]
- diptest      [http://cran.r-project.org/src/contrib/diptest_0.75-6.tar.gz]
- randomForest [http://cran.r-project.org/src/contrib/randomForest_4.6-10.tar.gz]

1. Download source from GitHub
git clone https://github.com/getiria-onsongo/tso_cnv.git tso_cnv

2. Navigate to parent directory
cd cnv

3. Download generic MySQL source code
wget https://s3.msi.umn.edu/CNVMySQL/mysql-5.6.24-linux-glibc2.5-x86_64.tar.gz

'''
Original mysql source from: https://dev.mysql.com/downloads/mysql/
Selected options for Linux - Generic, compressed TAR archive.
'''

4. Navigate to directory that will contain base MySQL tables
cd ../tso_tables

5. Download and uncompress MySQL base tables
wget https://s3.msi.umn.edu/CNVMySQL/mysql_tables.tar.gz
tar xzvf mysql_tables.tar.gz

6. Edit my.cnf to specify MySQL configurations appropriate for your system. 
     Default setting assume a machine with at least 64GB of RAM. The file my-small.cnf
     contains example values for a smaller machine (at least 5GB of RAM). For more
     details on editing MySQL option file see https://dev.mysql.com/doc/refman/5.1/en/option-files.html

7. Edit configuration file (config_template.ini) to specify expected input values. Note, 
     The program assumes your data was sequenced on two lanes and expects four fastq files for
     both sample and its matched control. 
     

8. Generate PBS script to run program on cluster. 
cd ..
sh launcher.sh config_template.ini

**NOTE**: The template PBS script is in "template/run_sample.pbs". Edit this template to 
conform to your clusters settings

9. Submit job to cluster
cd sample_name
qsub run_cnv_sample_name.pbs

**NOTE**: sample_name is the name of the sample being analyzed which is specified in the 
      configuration file (config_template.ini)
