#!/bin/bash 
FILE=$1
current_path=$(pwd)
echo "Current directory is: $current_path"

# Accept ini file as a sourcable input
source $FILE 

[[ -z ${control_name+unset} ]] && echo "Variable control_name not found." && exit -1  || echo "Variable control_name found: ${control_name}."
[[ -z ${c_s1r1Fastq+unset} ]] &&  echo "Variable c_s1r1Fastq not found." && exit -1  || echo "Variable c_s1r1Fastq found: ${c_s1r1Fastq}."
[[ -z ${c_s1r2Fastq+unset} ]] &&  echo "Variable c_s1r2Fastq not found." && exit -1  || echo "Variable c_s1r2Fastq found: ${c_s1r2Fastq}."
[[ -z ${c_s2r1Fastq+unset} ]] &&  echo "Variable c_s2r1Fastq not found." && exit -1  || echo "Variable c_s2r1Fastq found: ${c_s2r1Fastq}."
[[ -z ${c_s2r2Fastq+unset} ]] &&  echo "Variable c_s2r2Fastq not found." && exit -1  || echo "Variable c_s2r2Fastq found: ${c_s2r2Fastq}."

[[ -z ${sample_name+unset} ]] &&  echo "Variable sample_name not found." && exit -1  || echo "Variable sample_name found: ${sample_name}."
[[ -z ${s_s1r1Fastq+unset} ]] &&  echo "Variable s_s1r1Fastq not found." && exit -1  || echo "Variable s_s1r1Fastq found: ${s_s1r1Fastq}."
[[ -z ${s_s1r2Fastq+unset} ]] &&  echo "Variable s_s1r2Fastq not found." && exit -1  || echo "Variable s_s1r2Fastq found: ${s_s1r2Fastq}."
[[ -z ${s_s2r1Fastq+unset} ]] &&  echo "Variable s_s2r1Fastq not found." && exit -1  || echo "Variable s_s2r1Fastq found: ${s_s2r1Fastq}."
[[ -z ${s_s2r2Fastq+unset} ]] &&  echo "Variable s_s2r2Fastq not found." && exit -1  || echo "Variable s_s2r2Fastq found: ${s_s2r2Fastq}."

[[ -z ${training+unset} ]] &&  echo "Variable training not found." && exit -1  || echo "Variable training found: ${training}."
[[ -z ${ordered_genes+unset} ]] &&  echo "Variable ordered_genes not found." && exit -1  || echo "Variable ordered_genes found: ${ordered_genes}."
[[ -z ${email+unset} ]] &&  echo "Variable email not found." && exit -1  || echo "Variable email found: ${email}."
[[ -z ${bwa_db_value+unset} ]] &&  echo "Variable bwa_db_value not found." && exit -1  || echo "Variable bwa_db_value found: ${bwa_db_value}."
[[ -z ${bowtie2_db_value+unset} ]] &&  echo "Variable bowtie2_db_value not found." && exit -1  || echo "Variable bowtie2_db_value found: ${bowtie2_db_value}."
[[ -z ${seq_db+unset} ]] &&  echo "Variable seq_db not found." && exit -1  || echo "Variable seq_db found: ${seq_db}."
[[ -z ${archive_path+unset} ]] &&  echo "Variable archive_path not found." && exit -1  || echo "Variable archive_path found: ${archive_path}."
[[ -z ${user_tmp+unset} ]] &&  echo "Variable user_tmp not found." && exit -1  || echo "Variable user_tmp found: ${user_tmp}."
[[ -z ${version+unset} ]] &&  echo "Variable version not found." && exit -1  || echo "Variable version found: ${version}."

echo "All required variables found"

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

# normalize_coverage.R
sed -e s,sample_path,"$sample_path",g -e s,sample_name,"$sample_name",g -e s,control_name,"$control_name",g \
-e s,scripts_location,"$scripts_location",g -e s,socket_path,"$socket_path",g \
< "$template_pwd/normalize_coverage.R" > "$sample_path/normalize_coverage.R"

# smooth_coverage.R
sed -e s,sample_path,"$sample_path",g -e s,sample_name,"$sample_name",g -e s,control_name,"$control_name",g \
-e s,scripts_location,"$scripts_location",g -e s,socket_path,"$socket_path",g \
< "$template_pwd/smooth_coverage.R" > "$sample_path/smooth_coverage.R"

# get_three_ref.R                                                                                                
sed -e s,sample_path,"$sample_path",g -e s,sample_name,"$sample_name",g -e s,control_name,"$control_name",g \
-e s,scripts_location,"$scripts_location",g -e s,socket_path,"$socket_path",g \
< "$template_pwd/get_three_ref.R" > "$sample_path/get_three_ref.R"

# create_tables_ref_v1.sql                                                                                                                                            
sed -e s,control_name,"$control_name",g -e s,sample_name,"$sample_name",g < "$template_pwd/create_tables_ref_v1.sql" > "$sample_path/create_tables_ref_v1.sql"

# create_tables_ref.R                                                                                                                                        
sed -e s,sample_path,"$sample_path",g -e s,sample_name,"$sample_name",g -e s,control_name,"$control_name",g \
-e s,scripts_location,"$scripts_location",g -e s,socket_path,"$socket_path",g  < "$template_pwd/create_tables_ref.R" > "$sample_path/create_tables_ref.R"

# create_tables_ref_v2.sql                                                                                                                                       
sed -e s,control_name,"$control_name",g -e s,sample_name,"$sample_name",g < "$template_pwd/create_tables_ref_v2.sql" > "$sample_path/create_tables_ref_v2.sql"

# create_coverage.sql                                                                                                                                        
sed -e s,control_name,"$control_name",g -e s,sample_name,"$sample_name",g < "$template_pwd/create_coverage.sql" > "$sample_path/create_coverage.sql"

# create_sample_coverage.sql                                                                                                                                             
sed -e s,control_name,"$control_name",g -e s,sample_name,"$sample_name",g < "$template_pwd/create_sample_coverage.sql" > "$sample_path/create_sample_coverage.sql"

# create_control_coverage.sql                                                                                                                                            
sed -e s,control_name,"$control_name",g -e s,sample_name,"$sample_name",g < "$template_pwd/create_control_coverage.sql" > "$sample_path/create_control_coverage.sql"

# cnv_tables.sql                                                                                                                                 
sed -e s,control_name,"$control_name",g -e s,sample_name,"$sample_name",g < "$template_pwd/cnv_tables.sql" > "$sample_path/cnv_tables.sql"

# cnv_tables_amplifications.sql                                                                                                                                           
sed -e s,control_name,"$control_name",g -e s,sample_name,"$sample_name",g < "$template_pwd/cnv_tables_amplifications.sql" > "$sample_path/cnv_tables_amplifications.sql"

# get_cnv.sql                                                                                                                        
sed -e s,control_name,"$control_name",g -e s,sample_name,"$sample_name",g < "$template_pwd/get_cnv.sql" > "$sample_path/get_cnv.sql"

# Create file with list of gene panel (comma delimited)
echo $ordered_genes > "$sample_path/ordered_genes_temp.txt"

# Replace comma with newline so we can load it into a MySQL database
tr , '\n' < "$sample_path/ordered_genes_temp.txt" > "$sample_path/ordered_genes.txt"

# Delete the temp file
rm -rf "$sample_path/ordered_genes_temp.txt"

# ordered_genes.sql
sed -e s,sample_name,"$sample_name",g -e s,control_name,"$control_name",g < "$template_pwd/ordered_genes.sql" > "$sample_path/ordered_genes.sql"

# plot_genes.R                                                                        
sed -e s,sample_path,"$sample_path",g -e s,scripts_location,"$scripts_location",g \
-e s,socket_path,"$socket_path",g -e s,tables_path,"$tables_path",g \
< "$template_pwd/plot_genes.R" > "$sample_path/plot_genes.R"

# plot_genes_ordered.R                                                                
sed -e s,sample_path,"$sample_path",g -e s,scripts_location,"$scripts_location",g \
-e s,socket_path,"$socket_path",g -e s,tables_path,"$tables_path",g \
< "$template_pwd/plot_genes_ordered.R" > "$sample_path/plot_genes_ordered.R"

# create_data.sql
sed -e s,control_name,"$control_name",g -e s,sample_name,"$sample_name",g -e s,sample_path,"$sample_path",g \
< "$template_pwd/create_data.sql" > "$sample_path/create_data.sql"

# get_machine_learning_data.sql
sed -e s,control_name,"$control_name",g -e s,sample_name,"$sample_name",g -e s,sample_path,"$sample_path",g \
< "$template_pwd/get_machine_learning_data.sql" > "$sample_path/get_machine_learning_data.sql"

# aggregate_window.R
sed -e s,sample_name,"$sample_name",g -e s,sample_path,"$sample_path",g -e s,scripts_location,"$scripts_location",g \
-e s,socket_path,"$socket_path",g -e s,tables_path,"$tables_path",g \
< "$template_pwd/aggregate_window.R" > "$sample_path/aggregate_window.R"

# combine_data.sql
sed -e s,sample_name,"$sample_name",g < "$template_pwd/combine_data.sql" > "$sample_path/combine_data.sql"

# cnv_randomForest_predict.R                                                                                              
sed -e s,sample_name,"$sample_name",g -e s,sample_path,"$sample_path",g -e s,scripts_location,"$scripts_location",g \
-e s,socket_path,"$socket_path",g -e s,tables_path,"$tables_path",g \
-e s,training,"$training",g < "$template_pwd/cnv_randomForest_predict.R" > "$sample_path/cnv_randomForest_predict.R"

# get_predicted.sql
sed -e s,sample_name,"$sample_name",g -e s,control_name,"$control_name",g < "$template_pwd/get_predicted.sql" > "$sample_path/get_predicted.sql"

# get_ordered_genes.sql
sed -e s,sample_name,"$sample_name",g -e s,control_name,"$control_name",g < "$template_pwd/get_ordered_genes.sql" > "$sample_path/get_ordered_genes.sql"
