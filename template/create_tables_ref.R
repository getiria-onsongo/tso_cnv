options(warn=-1);
library(RMySQL)
library(calibrate)
library(plotrix)
library(zoo)

m <- dbDriver("MySQL");
con <-dbConnect(m,username="root",dbname="cnv",host="localhost",unix.socket="socket_path");
directory_path = "sample_path";
setwd(directory_path);
source("scripts_location/R_function.R");

sample_table_name <- "cnv_sample_name_over_control_name_60bp_exon_ref1";
output_table_name <- "cnv_sample_name_over_control_name_60bp_exon_ref1_med";
res=try(cnv_median_window_coverage(con, sample_table_name, output_table_name));
if(class(res) == "try-error"){
   quit(save = "no", status = 1, runLast = FALSE)
}

sample_table_name <- "cnv_sample_name_over_control_name_60bp_exon_ref2";
output_table_name <- "cnv_sample_name_over_control_name_60bp_exon_ref2_med";
res=try(cnv_median_window_coverage(con, sample_table_name, output_table_name));
if(class(res) == "try-error"){
   quit(save = "no", status = 1, runLast = FALSE)
}

sample_table_name <- "cnv_sample_name_over_control_name_60bp_exon_ref3";
output_table_name <- "cnv_sample_name_over_control_name_60bp_exon_ref3_med";
res=try(cnv_median_window_coverage(con, sample_table_name, output_table_name));
if(class(res) == "try-error"){
   quit(save = "no", status = 1, runLast = FALSE)
}

dbDisconnect(con);
