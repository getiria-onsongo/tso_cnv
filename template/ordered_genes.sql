DROP TABLE IF EXISTS `cnv_sample_name_ordered_genes`;
CREATE TABLE `cnv_sample_name_ordered_genes`(
gene_symbol VARCHAR(32));
LOAD DATA LOCAL INFILE 'ordered_genes.txt' INTO TABLE `cnv_sample_name_ordered_genes` FIELDS TERMINATED BY '\t';
