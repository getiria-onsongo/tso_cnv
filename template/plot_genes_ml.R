options(warn=-1);
library(RMySQL)
library(calibrate)
library(plotrix)
library(zoo)

m <- dbDriver("MySQL")
con <-dbConnect(m,username="root",dbname="cnv",host="localhost",unix.socket="socket_path");
dir_path = "sample_path";
setwd(dir_path);
source("scripts_location/R_function.R");
