options(warn=-1);
library(RMySQL)
library(calibrate)
library(plotrix)
library(zoo)

m <- dbDriver("MySQL")

con <-dbConnect(m,username="root",dbname="cnv",host="localhost",unix.socket="socket_path");

directory_path = "sample_path";

setwd(directory_path);

source("scripts_location/R_function.R");

input_table <- "`cnv_sample_name_over_control_name_n_bowtie_bwa_ratio_gene`";
output_table = "`cnv_sample_name_over_control_name_n_bowtie_bwa_ratio_gene_norm`";

res=try(cnv_normalize(con,input_table,output_table));
if(class(res) == "try-error"){
   quit(save = "no", status = 1, runLast = FALSE)
}

create_index_str <- "CREATE INDEX `cnv_sample_name_over_control_name_n_bowtie_bwa_ratio_gene_norm_i` ON `cnv_sample_name_over_control_name_n_bowtie_bwa_ratio_gene_norm`(ref_exon_contig_id, gene_symbol);";
create_index <- dbGetQuery(con, create_index_str);

dbDisconnect(con)
