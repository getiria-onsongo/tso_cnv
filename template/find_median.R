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

# ---------------------------------------- FIND REFERENCE COVERAGE (MEDIAN COVERAGE FOR REFERENCE EXON) FOR sample_name_tso
res= try(cnv_median_exon_coverage(con, "cnv_sample_name_exon_pileup", "sample_name_3_random_ref", "cnv_sample_name_exon_reference", "exon_contig_id"));
if(class(res) == "try-error"){
   quit(save = "no", status = 1, runLast = FALSE)
}

# ---------------------------------------- FIND REFERENCE COVERAGE (MEDIAN COVERAGE FOR REFERENCE EXON) FOR control_name_tso
res=try(cnv_median_exon_coverage(con, "cnv_control_name_exon_pileup", "sample_name_3_random_ref", "cnv_control_name_exon_reference", "exon_contig_id"));
if(class(res) == "try-error"){
   quit(save = "no", status = 1, runLast = FALSE)
}

dbDisconnect(con)
