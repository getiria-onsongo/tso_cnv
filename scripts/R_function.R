cnv_predict <- function(con,train_data,predict_output){
    drop_table_str <- paste("DROP TABLE IF EXISTS `",predict_output,"`;",sep="");
    drop_table <- dbGetQuery(con, drop_table_str);
    
    get_train_str <- paste("SELECT window_id,mfe,gc,num_repeats,bb_sd,cnv_ratio_sd,cnv_ratio_dip_stat,cov_sd,cov_avg,dup_rat_avg,true_deletion,label AS random_forest, sample,data_type FROM `",train_data,
    "` WHERE data_type = 'train';",sep="");
    dataTrain <- as.data.frame(dbGetQuery(con, get_train_str));
	if(length(dataTrain) == 0){
		error_message <- paste("The query[ ",get_train_str,"] returns 0 rows");
		stop(error_message);
	}
    dataTrain[,12] <- as.factor(dataTrain[,12]);
    
    get_test_str <- paste("SELECT window_id,mfe,gc,num_repeats,bb_sd,cnv_ratio_sd,cnv_ratio_dip_stat,cov_sd,cov_avg,dup_rat_avg,true_deletion,label AS random_forest, sample,data_type FROM `",train_data,
    "` WHERE data_type = 'test';",sep="");
    dataTest <- as.data.frame(dbGetQuery(con, get_test_str));
	if(length(dataTest) == 0){
		error_message <- paste("The query[ ",get_test_str,"] returns 0 rows");
		stop(error_message);
	}
    dataTest[,12] <- as.factor(dataTest[,12]);
	
    fol_rand <- formula(random_forest ~ cnv_ratio_dip_stat + cnv_ratio_sd + bb_sd + cov_avg + cov_sd + mfe + gc);
	randomForestmodel <- randomForest(fol_rand, data=dataTrain);
    predict_forest <-predict(randomForestmodel,type="class",newdata=dataTest);
    dataTest[,12] <- predict_forest;
	
    ans <- data.frame(dataTest);
    dbWriteTable(con, predict_output, ans, append=TRUE,field.types=list(window_id="varchar(64)",mfe="float(8,4)",gc="float(8,4)",num_repeats="int(11)",bb_sd="decimal(14,7)",
    cnv_ratio_sd="decimal(14,7)",cnv_ratio_dip_stat="decimal(14,7)",cov_sd="decimal(14,7)", cov_avg="decimal(14,7)",dup_rat_avg="decimal(14,7)",true_deletion="int(11)",random_forest="varchar(5)",sample="varchar(10)",data_type="varchar(5)"),row.names=FALSE);
}

cnv_normalize_scale <- function(con,train,test,out_output){
    drop_table_str <- paste("DROP TABLE IF EXISTS `",out_output,"`;",sep="");
    drop_table <- dbGetQuery(con, drop_table_str);
    
    get_str <- paste("SELECT window_id,mfe,gc,num_repeats,bb_sd,cnv_ratio_sd,cnv_ratio_dip_stat,cov_sd,cov_avg,dup_rat_avg,true_deletion,label,sample,data_type FROM `",train,"` UNION SELECT window_id,mfe,gc,num_repeats,bb_sd,cnv_ratio_sd,cnv_ratio_dip_stat,cov_sd,cov_avg,dup_rat_avg,true_deletion,label,sample,data_type FROM `",test,"`;",sep="");
    result_set <- dbGetQuery(con, get_str);
    if(length(result_set) == 0){
		error_message <- paste("The query[ ",get_str,"] returns 0 rows");
		stop(error_message);
	}
    window_id <- result_set[,1];
    mfe <- result_set[,2];
    mfe <- (mfe - mean(mfe,na.rm=TRUE))/((max(mfe,na.rm=TRUE) + 1) - min(mfe,na.rm=TRUE));
    gc <- result_set[,3];
    gc <- (gc - mean(gc,na.rm=TRUE))/((max(gc,na.rm=TRUE) + 1) - min(gc,na.rm=TRUE));
    num_repeats <- result_set[,4];
    num_repeats <- (num_repeats - mean(num_repeats,na.rm=TRUE))/((max(num_repeats,na.rm=TRUE) + 1) - min(num_repeats,na.rm=TRUE));
    bb_sd <- result_set[,5];
    bb_sd <- (bb_sd - mean(bb_sd,na.rm=TRUE))/((max(bb_sd,na.rm=TRUE) + 1) - min(bb_sd,na.rm=TRUE));
    cnv_ratio_sd <- result_set[,6];
    cnv_ratio_sd <- (cnv_ratio_sd - mean(cnv_ratio_sd,na.rm=TRUE))/((max(cnv_ratio_sd,na.rm=TRUE) + 1) - min(cnv_ratio_sd,na.rm=TRUE));
    cnv_ratio_dip_stat <- result_set[,7];
    cnv_ratio_dip_stat <- (cnv_ratio_dip_stat - mean(cnv_ratio_dip_stat,na.rm=TRUE))/((max(cnv_ratio_dip_stat,na.rm=TRUE) + 1) - min(cnv_ratio_dip_stat,na.rm=TRUE));
    cov_sd <- result_set[,8];
    cov_sd <- (cov_sd - mean(cov_sd,na.rm=TRUE))/((max(cov_sd,na.rm=TRUE) + 1) - min(cov_sd,na.rm=TRUE));
    cov_avg <- result_set[,9];
    cov_avg <- (cov_avg - mean(cov_avg,na.rm=TRUE))/((max(cov_avg,na.rm=TRUE) + 1) - min(cov_avg,na.rm=TRUE));
    dup_rat_avg <- result_set[,10];
    dup_rat_avg <- (dup_rat_avg - mean(dup_rat_avg,na.rm=TRUE))/((max(dup_rat_avg,na.rm=TRUE) + 1) - min(dup_rat_avg,na.rm=TRUE));
    true_deletion <- result_set[,11];
    label <- result_set[,12];
    sample <- result_set[,13];
    data_type <- result_set[,14];
    output = cbind(window_id,mfe,gc,num_repeats,bb_sd,cnv_ratio_sd,cnv_ratio_dip_stat,cov_sd,cov_avg,dup_rat_avg,true_deletion,label,sample,data_type);
    ans <- data.frame(output);
    dbWriteTable(con, out_output, ans, append=TRUE,field.types=list(window_id="varchar(64)",mfe="float(8,4)",gc="float(8,4)",num_repeats="int(11)",bb_sd="decimal(14,7)",
    cnv_ratio_sd="decimal(14,7)",cnv_ratio_dip_stat="decimal(14,7)",cov_sd="decimal(14,7)", cov_avg="decimal(14,7)",dup_rat_avg="decimal(14,7)",true_deletion="int(11)",label="varchar(5)",sample="varchar(10)",data_type="varchar(5)"),row.names=FALSE);
}

cnv_aggregate_data_one_window <- function(window_id){
    # We are working in LOG2 space because raw ratios are not symmetrical around 1.0			      
    get_str <- paste("SELECT coverage,LOG2(cnv_ratio),LOG2(bowtie_bwa_ratio),LOG2(duplication_ratio) FROM `",input_table,"` WHERE window_id = '",window_id,"';",sep="");
    result_set <- dbGetQuery(con, get_str);
    if(length(result_set) == 0){
		error_message <- paste("The query[ ",get_str,"] returns 0 rows");
		stop(error_message);
	}
    coverage <- result_set[,1];
    cnv_ratio <- result_set[,2];
    bowtie_bwa_ratio <- result_set[,3];
    duplication_ratio <- result_set[,4];
    
    bb_sd <- sd(bowtie_bwa_ratio,na.rm=TRUE);
    cnv_ratio_sd <- sd(cnv_ratio,na.rm=TRUE);
    cnv_ratio_dip_stat <- dip(cnv_ratio);
    cov_sd <- sd(coverage,na.rm=TRUE);
    cov_avg <- mean(coverage,na.rm=TRUE);
    dup_rat_avg <- mean(duplication_ratio,na.rm=TRUE);
    
    output = cbind(window_id, bb_sd, cnv_ratio_sd, cnv_ratio_dip_stat, cov_sd, cov_avg, dup_rat_avg);
    ans <- data.frame(output);
    dbWriteTable(con, out_output, ans, append=TRUE,field.types=list(window_id="varchar(64)",bb_sd="decimal(14,7)",cnv_ratio_sd="decimal(14,7)",cnv_ratio_dip_stat="decimal(14,7)",cov_sd="decimal(14,7)", cov_avg="decimal(14,7)",dup_rat_avg="decimal(14,7)"),row.names=FALSE);
}

cnv_aggregate_data_window <- function(con, input_table, out_output){
    drop_table_str <- paste("DROP TABLE IF EXISTS `",out_output,"`;",sep="");
    drop_table <- dbGetQuery(con, drop_table_str);

    create_table_str <- paste("CREATE TABLE `",out_output,"`(window_id varchar(64), bb_sd decimal(14,7), cnv_ratio_sd decimal(14,7), cnv_ratio_dip_stat decimal(14,7), cov_sd decimal(14,7), cov_avg decimal(14,7), dup_rat_avg decimal(14,7));",sep="");
    create_table <- dbGetQuery(con, create_table_str);    

    id_array_str <- paste("SELECT DISTINCT window_id FROM `",input_table,"`;",sep="");
    id_array <- dbGetQuery(con, id_array_str);
	if(length(id_array) == 0){
		error_message <- paste("The query[ ",id_array_str,"] returns 0 rows");
		stop(error_message);
	}
    window_id <- id_array[,1];
    x <- lapply(X=window_id, FUN=cnv_aggregate_data_one_window);
    
    index_str <- paste("CREATE INDEX `",out_output,"_i` ON `",out_output,"`(window_id);",sep="");
    output_index <- dbGetQuery(con, index_str);
}

cnv_delete_random_window <- function(input_gene_symbol){
    get_str <- paste("SELECT DISTINCT window_id, gene_num_windows FROM `",input_table,"` WHERE gene_symbol = '",input_gene_symbol,"';",sep="");
    window_array <- dbGetQuery(con, get_str);
	if(length(window_array) == 0){
		error_message <- paste("The query[ ",get_str,"] returns 0 rows");
		stop(error_message);
	}
    window_list <- window_array[,1];
    window_id <- sample(window_list, 1);
    num_windows <- as.numeric(window_array[1,2]);
    num_delete <- sample(1:num_windows,1);
    if(num_delete > 5){
       num_delete = 5;
    }
    
    chr = as.character(unlist(strsplit(window_id, "_"))[1]);
    delete_start = as.numeric(unlist(strsplit(window_id, "_"))[2]) - (30 * num_delete);
    delete_end = as.numeric(unlist(strsplit(window_id, "_"))[3]) + (30 * num_delete);
    delete_length = (delete_end - delete_start) + 1;
    
    gene_symbol = input_gene_symbol;
    output = cbind(gene_symbol, window_id, chr, delete_start, delete_end, delete_length);
    ans <- data.frame(output);
    dbWriteTable(con, out_output, ans, append=TRUE,field.types=list(gene_symbol="varchar(64)",window_id="varchar(64)",chr="varchar(8)",delete_start="INT",delete_end="INT", delete_length="INT"),row.names=FALSE);
    
    
}

cnv_random_delete <- function(con, gene_to_delete, input_table, out_output){
    drop_table_str <- paste("DROP TABLE IF EXISTS `",out_output,"`;",sep="");
    drop_table <- dbGetQuery(con, drop_table_str);
    
    gene_array_str <- paste("SELECT DISTINCT gene_symbol FROM `",gene_to_delete,"`;",sep="");
    gene_array <- dbGetQuery(con, gene_array_str);
	if(length(gene_array) == 0){
		error_message <- paste("The query[ ",gene_array_str,"] returns 0 rows");
		stop(error_message);
	}
    gene <- gene_array[,1];
    x <- lapply(X=gene, FUN=cnv_delete_random_window);
    
    index_str <- paste("CREATE INDEX `",out_output,"_i` ON `",out_output,"`(chr,delete_start, delete_end);",sep="");
    norm_output_index <- dbGetQuery(con, index_str);
}


piece.formula <- function(var.name, knots) {
# Code modified from http://rsnippets.blogspot.com/2013/04/estimating-continuous-piecewise-linear.html
    formula.sign <- rep(" - ", length(knots))
    formula.sign[knots < 0] <- " + "
    paste(var.name, "+",
		  paste("I(pmax(", var.name, formula.sign, abs(knots), ", 0))",
				collapse = " + ", sep=""))
}


cnv_lm_fit_gene <- function (gene_symbol){
    image_name = paste(gene_symbol,".png",sep="");
    setwd(dir_path);
	png(image_name, width=23, height=6, units="in", res=600)
    get_ref <- paste("SELECT DISTINCT ref_exon_contig_id FROM `",input_table,"` ORDER BY RAND() LIMIT 1;");
    i_ref <- dbGetQuery(con, get_ref);
	if(length(i_ref) == 0){
		error_message <- paste("The query[ ",get_ref,"] returns 0 rows");
		stop(error_message);
	}
	get_data <- paste("SELECT pos, A_over_B_ratio FROM `",input_table,"` WHERE ref_exon_contig_id = '",i_ref,"' AND gene_symbol = '",gene_symbol,"' ORDER BY  pos ASC;",sep="");
    i_data <- dbGetQuery(con, get_data);
	if(length(i_data) == 0){
		error_message <- paste("The query[ ",get_data,"] returns 0 rows");
		stop(error_message);
	}
    n =length(i_data[,1]);
	
	if(n < twice_seg_len){
		K = 1;
	}else{
		K = ceiling(n/twice_seg_len);
	}
    x <- seq(1,n,1);
    y = as.numeric(i_data[,2]);
    plot(x, y, col="green",  xlim=c(-1,n), ylim=c(-0.3,y_limit),xlab="chromosome position", ylab="ratio", title(main = gene_symbol));
    abline(h=0.5,col = "blue");
    abline(h=1,col = "blue", lty=2);
    knots <- seq(min(x), max(x), len = K + 2)[-c(1, K + 2)];
    model <- lm(formula(paste("y ~", piece.formula("x", knots))))
    points(knots, predict(model, newdata = data.frame(x = knots)), col = "blue", pch = "o",cex=2)
    y1 <- predict(model,newdata = data.frame(x));
    points(x,y1,pch="*",col="black");
    dev.off ();
    median_abs_residual = median(abs(y-y1));
    
    update_residual_str <- paste(" UPDATE `",cnv_table,"` SET ",cnv_table,".median_abs_residual = ",median_abs_residual," WHERE gene_symbol = '",gene_symbol,"';",sep="");
    update_res <- dbGetQuery(con, update_residual_str);
}

cnv_lm_fit <- function (con, input_table, cnv_table, twice_seg_len, y_limit, dir_path){
    gene_symbol_str <- paste("SELECT DISTINCT gene_symbol FROM `",cnv_table,"`;",sep="");
	gene_symbol_array <- dbGetQuery(con, gene_symbol_str);
	if(length(gene_symbol_array) == 0){
		error_message <- paste("The query[ ",gene_symbol_str,"] returns 0 rows");
		stop(error_message);
	}
	gene_symbol_list <- gene_symbol_array[,1];
	x <- lapply(X=gene_symbol_list, FUN=cnv_lm_fit_gene);
}


cnv_median_window_coverage <- function (con, sample_table_name, output_table_name){
	
	drop_table_str <- paste("DROP TABLE IF EXISTS `",output_table_name,"`;",sep="");
	drop_table <- dbGetQuery(con, drop_table_str);
	
	create_table_str <- paste("CREATE TABLE `",output_table_name,"` AS SELECT gene_symbol, ref_exon_contig_id, window_id, -1000.000001 AS min_bowtie_bwa_ratio,
       -1000.000001 AS max_bowtie_bwa_ratio, -1000.01 AS cnv_ratio FROM `",sample_table_name,"` WHERE 1 > 2;",sep="");
	create_table <- dbGetQuery(con, create_table_str);
	
	
	group_by_array_str <- paste("SELECT CONCAT(ref_exon_contig_id,'.',window_id) AS vals FROM (SELECT DISTINCT ref_exon_contig_id, window_id FROM  `",sample_table_name,"`) A;",sep="");
	group_by_array <- dbGetQuery(con, group_by_array_str);
	if(length(group_by_array) == 0){
		error_message <- paste("The query[ ",group_by_array_str,"] returns 0 rows");
		stop(error_message);
	}
	group_by_vals <- group_by_array[,1];
	x <- lapply(X=group_by_vals, FUN=cnv_window_coverage);
}

cnv_window_coverage <- function (vals){
	vals_vector <- unlist(strsplit(vals, "[.]"));
	ref_exon_contig_id_val <- vals_vector[1];
	window_id_val <- vals_vector[2];
	
	window_coverage_str = paste("SELECT gene_symbol, A_over_B_ratio, bowtie_bwa_ratio FROM `",sample_table_name,"` WHERE ref_exon_contig_id = '",
								ref_exon_contig_id_val,"' AND window_id ='",window_id_val,"';",sep="");
	window_coverage_data <- dbGetQuery(con, window_coverage_str);
	if(length(window_coverage_data) == 0){
		error_message <- paste("The query[ ",window_coverage_str,"] returns 0 rows");
		stop(error_message);
	}
	gene_symbol_val = window_coverage_data[1,1];
	window_coverage <- as.numeric(window_coverage_data[,2]);
	window_bowtie_bwa <- as.numeric(window_coverage_data[,3]);
	
	cnv_ratio_val <-  median(window_coverage);
	min_bowtie_bwa_ratio_val <- min(window_bowtie_bwa);
	max_bowtie_bwa_ratio_val <- max(window_bowtie_bwa);

	gene_symbol <- gene_symbol_val ; 
	ref_exon_contig_id <- ref_exon_contig_id_val;
	window_id <- window_id_val;
	min_bowtie_bwa_ratio <- min_bowtie_bwa_ratio_val;
	max_bowtie_bwa_ratio <- max_bowtie_bwa_ratio_val;
	cnv_ratio <- cnv_ratio_val;
	output = cbind(gene_symbol,ref_exon_contig_id,window_id,min_bowtie_bwa_ratio,max_bowtie_bwa_ratio,cnv_ratio);
	ans <- data.frame(output);
	dbWriteTable(con, output_table_name, ans, append=TRUE,field.types=list(gene_symbol="varchar(64)",ref_exon_contig_id="varchar(64)",window_id="varchar(64)",min_bowtie_bwa_ratio="decimal(14,7)",
																		   max_bowtie_bwa_ratio="decimal(14,7)",cnv_ratio="decimal(14,7)"),row.names=FALSE);
    
	
}

cnv_normalize <- function (con, input_table,output_table){
    drop_table_str <- paste("DROP TABLE IF EXISTS `",output_table,"`;",sep="");
    drop_table <- dbGetQuery(con, drop_table_str);

    create_table_str <- paste("CREATE TABLE `",output_table,"` AS SELECT * FROM `",input_table,"` WHERE 1 > 2;",sep="");
    create_table <- dbGetQuery(con, create_table_str);

    ref_array_str <- paste("SELECT DISTINCT ref_exon_contig_id FROM  `",input_table,"`;",sep="");
    ref_array <- dbGetQuery(con, ref_array_str);
	if(length(ref_array) == 0){
		error_message <- paste("The query[ ",ref_array_str,"] returns 0 rows");
		stop(error_message);
	}
    ref <- ref_array[,1];
	
    x <- lapply(X=ref, FUN=cnv_normalize_one_ref);
}

cnv_normalize_one_ref <- function(ref){
    panel_cov_str = paste("SELECT A_over_B_ratio FROM  `",input_table,"` WHERE ref_exon_contig_id = '",ref,"' AND A_over_B_ratio > 0.5 AND A_over_B_ratio < 2 AND bowtie_bwa_ratio > 0.8 AND bowtie_bwa_ratio < 1.2;",sep="");	
	panel_cov = dbGetQuery(con, panel_cov_str);
	if(length(panel_cov) == 0){
		error_message <- paste("The query[ ",panel_cov_str,"] returns 0 rows");
		stop(error_message);
	}
	ratio = as.numeric(panel_cov[,1]);
	avg_log2 = mean(log2(ratio));
	
	data_values_str = paste("SELECT chr,pos,ref_exon_contig_id,A_over_B_ratio,bowtie_bwa_ratio,gene_symbol FROM  `",input_table,"` WHERE ref_exon_contig_id = '",ref,"';",sep="");
	data_values = dbGetQuery(con,data_values_str);
	if(length(data_values) == 0){
		error_message <- paste("The query[ ",data_values_str,"] returns 0 rows");
		stop(error_message);
	}
	data_values[,4] <- 2^(log2(as.numeric(data_values[,4])) - avg_log2);
	
	ans <- data.frame(data_values);
    dbWriteTable(con, output_table, ans, append=TRUE,field.types=list(chr="varchar(8)",pos="INT",ref_exon_contig_id="varchar(64)",A_over_B_ratio="decimal(14,7)",
																		   bowtie_bwa_ratio="decimal(14,7)",gene_symbol="varchar(64)"),row.names=FALSE);
}

cnv_smooth_gene <- function(gene_ref){
	gene_ref_vector <- unlist(strsplit(gene_ref, "[.]"));
	ref <- gene_ref_vector[1];
	gene <- gene_ref_vector[2];
	
	input_table_str <- paste("SELECT DISTINCT gene_symbol, ref_exon_contig_id , chr, pos, A_over_B_ratio, bowtie_bwa_ratio FROM  `",
							 input_table_name,"` WHERE ref_exon_contig_id = '",ref,"' AND gene_symbol  ='",gene,
							 "' AND A_over_B_ratio IS NOT NULL AND bowtie_bwa_ratio IS NOT NULL ORDER BY chr, pos ASC;",sep="");
	input_table <- dbGetQuery(con, input_table_str);
	if(length(input_table) == 0){
		error_message <- paste("The query[ ",input_table_str,"] returns 0 rows");
		stop(error_message);
	}
	gene_symbol <- input_table[,1];
	ref_exon_contig_id <- input_table[,2];
	chr <- input_table[,3];
	pos <- as.numeric(input_table[,4]);
	gene_length <- length(pos);
	
	if(window_length >= (gene_length/4)){
		window_length = round(gene_length/4);
	}
	if(window_length < 1){
		window_length=1;	
	}		
	# Because we are using "extend" in rollmean, we are making the edges be 1
	input_table[1,5] = 1;
	input_table[length(input_table[,5]),5] = 1;
	input_table[1,6] = 1;
	input_table[length(input_table[,6]),6] = 1;
#	 print(gene_symbol[1]);
#	 print(ref_exon_contig_id[1]); 
#	 print(length(input_table[,5]));
#	 print(length(input_table[,6]));
#	 print(window_length);
#	 print(gene_length);
	A_over_B_ratio <- rollmean(input_table[,5],window_length,na.pad=TRUE,fill="extend");
	bowtie_bwa_ratio <- rollmean(input_table[,6],window_length,na.pad=TRUE,fill="extend");
	output = cbind(gene_symbol,ref_exon_contig_id,chr,pos,A_over_B_ratio,bowtie_bwa_ratio);
	ans <- data.frame(output);
        dbWriteTable(con, output_table_name, ans, append=TRUE,field.types=list(gene_symbol="varchar(64)",ref_exon_contig_id="varchar(64)",
	chr="varchar(8)",pos="INT",A_over_B_ratio="decimal(14,7)",bowtie_bwa_ratio="decimal(14,7)"),row.names=FALSE);
}

cnv_smooth_coverages<- function (con, input_table_name, output_table_name, window_length){
    prog_start <- proc.time();

    drop_table_str <- paste("DROP TABLE IF EXISTS `",output_table_name,"`;",sep="");
    drop_table <- dbGetQuery(con, drop_table_str);

    create_table_str <- paste("CREATE TABLE `",output_table_name,"` AS SELECT * FROM `",input_table_name,"` WHERE 1 > 2;",sep="");
    create_table <- dbGetQuery(con, create_table_str);

    gene_ref_array_str <- paste("SELECT CONCAT(ref_exon_contig_id,'.',gene_symbol) AS gene_ref FROM (SELECT DISTINCT ref_exon_contig_id,gene_symbol FROM  `",
								input_table_name,"` WHERE A_over_B_ratio IS NOT NULL AND bowtie_bwa_ratio IS NOT NULL) A;",sep="");
    gene_ref_array <- dbGetQuery(con, gene_ref_array_str);
	if(length(gene_ref_array) == 0){
		error_message <- paste("The query[ ",gene_ref_array_str,"] returns 0 rows");
		stop(error_message);
	}
    gene_ref <- gene_ref_array[,1];
	
   x <- lapply(X=gene_ref, FUN=cnv_smooth_gene);
   end_ptm <- proc.time() - prog_start;
   print(end_ptm);
}

cnv_plot_all_screen <- function (con, input_table, pos, filter_column1, filter_value1, data_column1, y_limit, title_label){
		
	get_ref_exon_contig_id <- paste("SELECT DISTINCT ref_exon_contig_id FROM `",input_table,"` WHERE ",filter_column1," = '",filter_value1,"';",sep="");
	i_ref_exon <- dbGetQuery(con, get_ref_exon_contig_id);
	if(length(i_ref_exon) == 0){
		error_message <- paste("The query[ ",get_ref_exon_contig_id,"] returns 0 rows");
		stop(error_message);
	}
	n1 =length(i_ref_exon[,1]);
	
	for(j in 1:n1){
		filter_value2 = i_ref_exon[j,1]
		get_data <- paste("SELECT DISTINCT ",pos,", ",data_column1," FROM `",input_table,"` WHERE ",filter_column1," = '",filter_value1,"' AND ref_exon_contig_id = '",
						  filter_value2,"' ORDER BY ",pos," ASC;",sep="");
		
		i_data <- dbGetQuery(con, get_data);
		if(length(i_data) == 0){
			error_message <- paste("The query[ ",get_data,"] returns 0 rows");
			stop(error_message);
		}
		n =length(i_data[,1]);
		num_exon = 0;
		
		if (length(i_data) < 1){
# empty array
		}else{
			n =length(i_data[,1]);
			
			if(j == 1){
				dev.new(width=11, height=6);
				plot(0, 0.07,pch = "o", col="blue",  xlim=c(-0.08,n), ylim=c(-0.08,y_limit),xlab="chromosome position", ylab="ratio", title(main = title_label));
				abline(h=0.5,col = "blue");
                abline(h=0.4,col = "blue");
                abline(h=0.3,col = "blue");
                abline(h=0.2,col = "blue");
                abline(h=0.1,col = "blue");
				abline(h=1,col = "blue", lty=2)
				textxy(0, 0, num_exon);
			}
			for(i in 2:n){
				data_value1 = as.numeric(i_data[i,2]);
				data_value2 = as.numeric(i_data[i,3]);
				points(i, data_value1, pch = "+", col=j);
				if((as.numeric(i_data[i,1]) - as.numeric(i_data[(i-1),1])) > 1){
					num_exon = num_exon + 1;
					textxy(i, 0, num_exon);
					points(i,0.07, pch = "o", col="blue");  
				}
			}
		}
	}
}



cnv_plot_all <- function (con, input_table, pos, filter_column1, filter_value1, data_column1, y_limit, title_label, dir_path){
	image_name = paste(title_label,".png",sep="");
	setwd(dir_path);
	png(image_name, width=23, height=6, units="in", res=600)
	
	get_ref_exon_contig_id <- paste("SELECT DISTINCT ref_exon_contig_id FROM `",input_table,"` WHERE ",filter_column1," = '",filter_value1,"';",sep="");
	i_ref_exon <- dbGetQuery(con, get_ref_exon_contig_id);
	if(length(i_ref_exon) == 0){
		error_message <- paste("The query[ ",get_ref_exon_contig_id,"] returns 0 rows");
		stop(error_message);
	}
	n1 =length(i_ref_exon[,1]);
	
	for(j in 1:n1){
		filter_value2 = i_ref_exon[j,1]
		get_data <- paste("SELECT DISTINCT ",pos,", ",data_column1," FROM `",input_table,"` WHERE ",filter_column1," = '",filter_value1,"' AND ref_exon_contig_id = '",
					  filter_value2,"' ORDER BY ",pos," ASC;",sep="");
	
		i_data <- dbGetQuery(con, get_data);
		if(length(i_data) == 0){
			error_message <- paste("The query[ ",get_data,"] returns 0 rows");
			stop(error_message);
		}
		n =length(i_data[,1]);
		num_exon = 0;
	
		if (length(i_data) < 1){
			# empty array
		}else{
			n =length(i_data[,1]);
			
			if(j == 1){
				plot(0, 0.07, pch = "o", col="blue",  xlim=c(-0.08,n), ylim=c(-0.08,y_limit),xlab="chromosome position", ylab="ratio", title(main = title_label));
                abline(h=0.5,col = "blue");
                abline(h=0.4,col = "blue");
                abline(h=0.3,col = "blue");
                abline(h=0.2,col = "blue");
                abline(h=0.1,col = "blue");
				abline(h=1,col = "blue", lty=2)
				textxy(0, 0, num_exon);
			}
			for(i in 2:n){
				data_value1 = as.numeric(i_data[i,2]);
				data_value2 = as.numeric(i_data[i,3]);
				points(i, data_value1, pch = "+", col=j);
				if((as.numeric(i_data[i,1]) - as.numeric(i_data[(i-1),1])) > 1){
					num_exon = num_exon + 1;
					textxy(i, 0, num_exon);
					points(i,0.07, pch = "o", col="blue");  
				}
			}
		}
	}
	dev.off ();
}

cnv_plot_all_bowtie_bwa <- function (con, input_table, pos, filter_column1, filter_value1, data_column1, bowtie_bwa_ratio, y_limit, title_label, dir_path){
	image_name = paste(title_label,".png",sep=""); setwd(dir_path); png(image_name, width=23, height=6, units="in", res=600);
	get_ref_exon_contig_id <- paste("SELECT DISTINCT ref_exon_contig_id FROM `",input_table,"` WHERE ",filter_column1," = '",filter_value1,"';",sep="");
	i_ref_exon <- dbGetQuery(con, get_ref_exon_contig_id);
	if(length(i_ref_exon) == 0){
		error_message <- paste("The query[ ",get_ref_exon_contig_id,"] returns 0 rows");
		stop(error_message);
	}
	n1 =length(i_ref_exon[,1]);
	for(j in 1:n1){
		filter_value2 = i_ref_exon[j,1]
		get_data <- paste("SELECT DISTINCT ",pos,", ",data_column1,",",bowtie_bwa_ratio," FROM `",input_table,"` WHERE ",filter_column1," = '",filter_value1,"' AND ref_exon_contig_id = '",
						  filter_value2,"' ORDER BY ",pos," ASC;",sep="");
		i_data <- dbGetQuery(con, get_data);
		if(length(i_data[,1]) < 1){
			plot(0, 0.07, pch = "o", col="blue",  xlim=c(-1,1), ylim=c(-0.3,y_limit),xlab="chromosome position", ylab="ratio", title(main = title_label));
			text(-0.95, 0.5, "This gene has no coverage data",cex = 1)
		}else{
			n =length(i_data[,1]); num_exon = 0; xmin = min(as.numeric(i_data[,1])); xmax = max(as.numeric(i_data[,1])); x_min = xmin-5; x_max = xmax+5;
			if(j == 1){
				plot(0, 0.07, pch = "o", col="blue",  xlim=c(-1,n), ylim=c(-0.3,y_limit),xlab="chromosome position", ylab="ratio", title(main = title_label));
                		abline(h=0.5,col = "blue"); abline(h=0.4,col = "blue"); abline(h=0.3,col = "blue"); abline(h=0.2,col = "blue"); abline(h=0.1,col = "blue");
				abline(h=1,col = "blue", lty=2); textxy(0, 0, num_exon);
			}
			altPlot=1;
			for(i in 2:n){
				data_value1 = as.numeric(i_data[i,1]); data_value2 = as.numeric(i_data[i,2]); data_value3 = as.numeric(i_data[i,3]);
				points(i, data_value2, pch = "+", col=j); points(i, data_value3, pch = "*", col="red");
				if((as.numeric(i_data[i,1]) - as.numeric(i_data[(i-1),1])) > 1){
					num_exon = num_exon + 1;
					textxy(i, 0, num_exon);
					if(altPlot == 1){
						textxy(i, -0.1, data_value1); altPlot = -1;
					}else{
					   textxy(i, -0.2, data_value1); altPlot = 1;
					}
					points(i,0.07, pch = "o", col="blue");  
				}
			}
		}
	}
	dev.off ();
}



cnv_plot_screen <- function (con, input_table, pos, filter_column1, filter_value1, filter_column2, filter_value2, data_column1, data_column2, y_limit, color1, color2, title_label,ref,normal_region){

	get_data <- paste("SELECT DISTINCT ",pos,", ",data_column1,", ",data_column2," FROM `",input_table,"` WHERE ",filter_column1," = '",filter_value1,"' AND ",filter_column2," = '",
					  filter_value2,"' ORDER BY ",pos," ASC;",sep="");
	i_data <- dbGetQuery(con, get_data);
	if(length(i_data) == 0){
		error_message <- paste("The query[ ",get_data,"] returns 0 rows");
		stop(error_message);
	}
	ref_vector = unlist(strsplit(ref, "[:]"));
	chr = ref_vector[1];
	range_vector = unlist(strsplit(ref_vector[2], "[-]"));
	start = as.numeric(range_vector[1]);
	end = as.numeric(range_vector[2]);
	
	norm_vector = unlist(strsplit(normal_region, "[:]"));
	n_chr = norm_vector[1];
	n_range_vector = unlist(strsplit(norm_vector[2], "[-]"));
	n_start = as.numeric(n_range_vector[1]);
	n_end = as.numeric(n_range_vector[2]);
	
	get_norm_data <- paste("SELECT DISTINCT pos, A_over_B_ratio FROM `",input_table,"` WHERE ref_exon_contig_id = '",ref,"' AND chr = '",n_chr,"' AND pos >= ",n_start," AND pos <= ",n_end," ORDER BY pos ASC;",sep="");
	norm_data <- dbGetQuery(con, get_norm_data);
	if(length(norm_data) == 0){
		error_message <- paste("The query[ ",get_norm_data,"] returns 0 rows");
		stop(error_message);
	}
	n =length(i_data[,1]);
	m =length(ref_data[,1]);
	t =length(norm_data[,1]);
	
	j = n+10;
	k = j + m;
	l = k+10;
	p = l + t;
	num_exon = 0;
	
	
	dev.new(width=22, height=6);
	plot(0, 0.07, pch = "o", col="blue",  xlim=c(-0.08,k), ylim=c(-0.08,y_limit),xlab="chromosome position", ylab="ratio", title(main = title_label));
	abline(h=0.5,col = "blue");
	abline(h=1,col = "blue", lty=2)
	textxy(0, 0, num_exon);
	
	if (length(i_data) < 1){
      # empty array
	}else{
		for(i in 2:n){
			data_value1 = as.numeric(i_data[i,2]);
			data_value2 = as.numeric(i_data[i,3]);
			points(i, data_value1, pch = "+", col=color1);
			points(i, data_value2, pch = "+", col=color2);
			if((as.numeric(i_data[i,1]) - as.numeric(i_data[(i-1),1])) > 1){
				num_exon = num_exon + 1;
				textxy(i, 0, num_exon);
				points(i,0.07, pch = "o", col="blue");  
			}
		}
		
		for(i in n:j){
			points(i,0.07, pch = "o", col="white");
		}
		
		for(i in 1:m){
			ref_value = as.numeric(ref_data[i,2]);
			x_val = j+i;
			points(x_val, ref_value, pch = "o", col=color1);
		}
		
		for(i in k:l){
			points(i,0.07, pch = "o", col="white");
		}
		
		for(i in 1:t){
			norm_value = as.numeric(norm_data[i,2]);
			norm_x = l+i;
			points(norm_x,norm_value, pch = "*", col=color1);
		}
		
	}
	
}



cnv_plot <- function (con, input_table, pos, filter_column1, filter_value1, filter_column2, filter_value2, data_column1, data_column2, y_limit, color1, color2, title_label, dir_path){
	image_name = paste(title_label,".png",sep="");
	setwd(dir_path);
	
	get_data <- paste("SELECT DISTINCT ",pos,", ",data_column1,", ",data_column2," FROM `",input_table,"` WHERE ",filter_column1," = '",filter_value1,"' AND ",filter_column2," = '",
					  filter_value2,"' ORDER BY ",pos," ASC;",sep="");
	i_data <- dbGetQuery(con, get_data);
	if(length(i_data) == 0){
		error_message <- paste("The query[ ",get_data,"] returns 0 rows");
		stop(error_message);
	}
	n =length(i_data[,1]);
	num_exon = 0;
	
	png(image_name, width=23, height=6, units="in", res=600)
	plot(0, 0.07, pch = "o", col="blue",  xlim=c(-0.08,n), ylim=c(-0.08,y_limit),xlab="chromosome position", ylab="ratio", title(main = title_label));
	abline(h=0.5,col = "blue");
	abline(h=1,col = "blue", lty=2)
	textxy(0, 0, num_exon);
	
	if (length(i_data) < 1){
# empty array
	}else{
		n =length(i_data[,1]);
		for(i in 2:n){
			data_value1 = as.numeric(i_data[i,2]);
			data_value2 = as.numeric(i_data[i,3]);
			points(i, data_value1, pch = "+", col=color1);
			points(i, data_value2, pch = "+", col=color2);
			if((as.numeric(i_data[i,1]) - as.numeric(i_data[(i-1),1])) > 1){
				num_exon = num_exon + 1;
				textxy(i, 0, num_exon);
				points(i,0.07, pch = "o", col="blue");  
			}
		}
	}
	dev.off ();
}

cnv_median_exon_coverage <- function (con, sample_table_name, reference_table_name, output_table_name, contig_label){
	
	drop_table_str <- paste("DROP TABLE IF EXISTS `",output_table_name,"`;",sep="");
	drop_table <- dbGetQuery(con, drop_table_str);
	
	create_table_str <- paste("CREATE TABLE `",output_table_name,"` AS SELECT ",contig_label,", chr, pos, coverage  FROM `",sample_table_name,"` WHERE 1 > 2;",sep="");
	create_table <- dbGetQuery(con, create_table_str);
	
	
	contig_array_str <- paste("SELECT  DISTINCT ",contig_label," FROM  `",reference_table_name,"`;",sep="");
	contig_array <- dbGetQuery(con, contig_array_str);
	if(length(contig_array) == 0){
		error_message <- paste("The query[ ",contig_array_str,"] returns 0 rows");
		stop(error_message);
	}
	n =length(contig_array[,1]);
	
	for(i in 1:n){
		contig_id = contig_array[i,1];
		contig_coverage_str = paste("SELECT chr, pos, coverage FROM `",sample_table_name,"` WHERE ",contig_label," = '",contig_id,"';",sep="");
		contig_coverage_data <- dbGetQuery(con, contig_coverage_str);
		if(length(contig_coverage_data) == 0){
			error_message <- paste("The query[ ",contig_coverage_str,"] returns 0 rows");
			stop(error_message);
		}
		contig_coverage <- contig_coverage_data[,3];
# We want the index for median coverage so we can retrieve other details such as the chromosome position for that coverage. 
# To retrieve the index, we are using the (which) command that requires us to know the median value. If the array has an 
# even number of elements, no index will contain the median since the median is the average of the two middle numbers. To get 
# around this, we add 1 at the end of the array which will guarantee the array will have an element with the median value. 
		
		if((length(contig_coverage) %% 2) == 0){
			contig_coverage[(length(contig_coverage) + 1)] <- 1;
		}
		
		index_median <- which(contig_coverage == median(contig_coverage));
		chr <- contig_coverage_data[index_median,1];
		pos <- contig_coverage_data[index_median,2];
		median_coverage <- contig_coverage_data[index_median,3];
		output_str <- paste(contig_id," ",chr," ",pos," ",median_coverage);
		
		insert_query_str <- paste("INSERT INTO `",output_table_name,"` VALUES('",contig_id,"','",chr,"',",pos,",",median_coverage,");",sep=""); 
		insert_query <- dbGetQuery(con, insert_query_str);
	}
}

