#!/bin/bash 
FILE=$1
current_path=$(pwd)
echo "Current directory is: $current_path"
while read line;do
	if [[ $line =~ control_name ]]; then
		IFS='=' read -a array <<< "$line"
		control_name=${array[1]}
	fi
	if [[ $line =~ c_s1r1Fastq ]]; then
		IFS='=' read -a array <<< "$line"
		c_s1r1Fastq=${array[1]}
	fi
	if [[ $line =~ c_s1r2Fastq ]]; then
		IFS='=' read -a array <<< "$line"
		c_s1r2Fastq=${array[1]}
	fi
	if [[ $line =~ c_s2r1Fastq ]]; then
		IFS='=' read -a array <<< "$line"
		c_s2r1Fastq=${array[1]}
	fi
	if [[ $line =~ c_s2r2Fastq ]]; then
		IFS='=' read -a array <<< "$line"
		c_s2r2Fastq=${array[1]}
	fi
	if [[ $line =~ sample_name ]]; then
		IFS='=' read -a array <<< "$line"
		sample_name=${array[1]}
	fi
	if [[ $line =~ s_s1r1Fastq ]]; then
		IFS='=' read -a array <<< "$line"
		s_s1r1Fastq=${array[1]}
	fi
	if [[ $line =~ s_s1r2Fastq ]]; then
		IFS='=' read -a array <<< "$line"
		s_s1r2Fastq=${array[1]}
	fi
	if [[ $line =~ s_s2r1Fastq ]]; then
		IFS='=' read -a array <<< "$line"
		s_s2r1Fastq=${array[1]}
	fi
	if [[ $line =~ s_s2r2Fastq ]]; then
		IFS='=' read -a array <<< "$line"
		s_s2r2Fastq=${array[1]}
	fi
	if [[ $line =~ training ]]; then
		IFS='=' read -a array <<< "$line"
		training=${array[1]}
	fi
	if [[ $line =~ ordered_genes ]]; then
		IFS='=' read -a array <<< "$line"
		ordered_genes=${array[1]}
	fi
	if [[ $line =~ email ]]; then
		IFS='=' read -a array <<< "$line"
		email=${array[1]}
	fi
	if [[ $line =~ bwa_db_value ]]; then
		IFS='=' read -a array <<< "$line"
		bwa_db_value=${array[1]}
	fi
	if [[ $line =~ bowtie2_db_value ]]; then
		IFS='=' read -a array <<< "$line"
		bowtie2_db_value=${array[1]}
	fi
	if [[ $line =~ seq_db ]]; then
		IFS='=' read -a array <<< "$line"
		seq_db=${array[1]}
	fi
    if [[ $line =~ archive_path ]]; then
        IFS='=' read -a array <<< "$line"
        archive_path=${array[1]}
    fi
    if [[ $line =~ user_tmp ]]; then
        IFS='=' read -a array <<< "$line"
        user_tmp=${array[1]}
    fi
    if [[ $line =~ version ]]; then
        IFS='=' read -a array <<< "$line"
        version=${array[1]}
    fi
done < $FILE

tables_path="$current_path/tso_tables"
scripts_location="$current_path/scripts"
template_pwd="$current_path/template"
sample_path="$user_tmp/$sample_name"
sample_result="$current_path/$version/$sample_name"
socket_path="$sample_path/mysql/thesock"

echo "Creating scripts in $sample_path"
# ######################################################################### CREATE DIRECTORIES
mkdir -p $sample_path
mkdir -p $sample_result

# ######################################################################### 
# NOTE: You can use "sed s,find,replace,g foo.txt" instead of "sed s/find/replace/g foo.txt"
# 
# If we use "," as a separator character, we won't need to worry about escaping the forward slashes.
# in the file paths

# run_sample.pbs
sed -e s,sample_path,"$sample_path",g -e s,sample_name,"$sample_name",g -e s,control_name,"$control_name",g -e s,scripts_location,"$scripts_location",g \
-e s,tables_path,"$tables_path",g -e s,sample_email@umn.edu,"$email",g -e s,archive_path,"$archive_path",g -e s,sample_result,"$sample_result",g \
-e s,code_path,"$current_path",g < "$template_pwd/run_sample.pbs" > "$sample_path/run_cnv_$sample_name.pbs"

# control_pileup.sh 
sed -e s,control_name,"$control_name",g -e s,c_s1r1Fastq,"$c_s1r1Fastq",g -e s,c_s1r2Fastq,"$c_s1r2Fastq ",g \
-e s,c_s2r1Fastq,"$c_s2r1Fastq",g -e s,c_s2r2Fastq,"$c_s2r2Fastq",g -e s,bwa_db_value,"$bwa_db_value",g \
-e s,bowtie2_db_value,"$bowtie2_db_value",g -e s,bwa_db_value,"$bwa_db_value",g -e s,seq_db,"$seq_db",g \
< "$template_pwd/control_pileup.sh" > "$sample_path/control_pileup.sh"

# sample_pileup.sh 
sed -e s,sample_name,"$sample_name",g -e s,s_s1r1Fastq,"$s_s1r1Fastq",g -e s,s_s1r2Fastq,"$s_s1r2Fastq ",g \
-e s,s_s2r1Fastq,"$s_s2r1Fastq",g -e s,s_s2r2Fastq,"$s_s2r2Fastq",g -e s,bwa_db_value,"$bwa_db_value",g \
-e s,bowtie2_db_value,"$bowtie2_db_value",g -e s,bwa_db_value,"$bwa_db_value",g -e s,seq_db,"$seq_db",g \
< "$template_pwd/sample_pileup.sh" > "$sample_path/sample_pileup.sh"

# load_control.sql
sed -e s,control_name,"$control_name",g < "$template_pwd/load_control.sql" > "$sample_path/load_control.sql"

# load_sample.sql
sed -e s,sample_name,"$sample_name",g < "$template_pwd/load_sample.sql" > "$sample_path/load_sample.sql"

# create_reference.sql
sed -e s,control_name,"$control_name",g -e s,sample_name,"$sample_name",g < "$template_pwd/create_reference.sql" > "$sample_path/create_reference.sql"

# find_median.R
sed -e s,sample_path,"$sample_path",g -e s,sample_name,"$sample_name",g -e s,control_name,"$control_name",g \
-e s,scripts_location,"$scripts_location",g -e s,socket_path,"$socket_path",g \
< "$template_pwd/find_median.R" > "$sample_path/find_median.R"

# create_tables_part1.sql
sed -e s,control_name,"$control_name",g -e s,sample_name,"$sample_name",g < "$template_pwd/create_tables_part1.sql" > "$sample_path/create_tables_part1.sql"

# get_data.sql
sed -e s,control_name,"$control_name",g -e s,sample_name,"$sample_name",g < "$template_pwd/get_data.sql" > "$sample_path/get_data.sql"
