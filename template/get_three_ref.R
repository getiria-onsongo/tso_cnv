options(warn=-1);
library(RMySQL);

m <- dbDriver("MySQL");
con <-dbConnect(m,username="root",dbname="cnv",host="localhost",unix.socket="socket_path");
directory_path = "sample_path";
setwd(directory_path);
source("scripts_location/R_function.R");

out_table1 <- "DROP TABLE IF EXISTS cnv_sample_name_over_control_name_ref1";
drop_table1 <- dbGetQuery(con, out_table1);
out_table2 <- "DROP TABLE IF EXISTS cnv_sample_name_over_control_name_ref2";
drop_table2 <- dbGetQuery(con, out_table2);
out_table3 <- "DROP TABLE IF EXISTS cnv_sample_name_over_control_name_ref3";
drop_table3 <- dbGetQuery(con, out_table3);

get_str = "SELECT ref_exon_contig_id FROM (SELECT DISTINCT ref_exon_contig_id FROM cnv_sample_name_tso_over_control_name_n_bowtie_bwa_ratio_gene_out)A ORDER BY RAND() LIMIT 3;";
result_set <- dbGetQuery(con, get_str);


create_table_str1 <- paste("CREATE TABLE cnv_sample_name_over_control_name_ref1 AS SELECT * FROM cnv_sample_name_tso_over_control_name_n_bowtie_bwa_ratio_gene_out WHERE ref_exon_contig_id = '",result_set[1,1],"';",sep="");
create_table1 <- dbGetQuery(con, create_table_str1);
create_index1_str <-  "CREATE INDEX cnv_sample_name_over_control_name_ref1_1 ON cnv_sample_name_over_control_name_ref1(chr,pos);";
create_index1 <- dbGetQuery(con, create_index1_str);

create_table_str2 <- paste("CREATE TABLE cnv_sample_name_over_control_name_ref2 AS SELECT * FROM cnv_sample_name_tso_over_control_name_n_bowtie_bwa_ratio_gene_out WHERE ref_exon_contig_id = '",result_set[2,1],"';",sep="");
create_table2 <- dbGetQuery(con, create_table_str2);
create_index2_str <-  "CREATE INDEX cnv_sample_name_over_control_name_ref2_1 ON cnv_sample_name_over_control_name_ref2(chr,pos);";
create_index2 <- dbGetQuery(con, create_index2_str);

create_table_str3 <- paste("CREATE TABLE cnv_sample_name_over_control_name_ref3 AS SELECT * FROM cnv_sample_name_tso_over_control_name_n_bowtie_bwa_ratio_gene_out WHERE ref_exon_contig_id = '",result_set[3,1],"';",sep="");
create_table3 <- dbGetQuery(con, create_table_str3);
create_index3_str <-  "CREATE INDEX cnv_sample_name_over_control_name_ref3_1 ON cnv_sample_name_over_control_name_ref3(chr,pos);";
create_index3 <- dbGetQuery(con, create_index3_str);
