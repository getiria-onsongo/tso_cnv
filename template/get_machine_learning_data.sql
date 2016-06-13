DROP TABLE IF EXISTS `sample_name_tso_one_window_het`;
CREATE TABLE `sample_name_tso_one_window_het` AS
SELECT DISTINCT A2.window_id FROM
(SELECT DISTINCT A1.window_id FROM
(SELECT DISTINCT window_id FROM 
(SELECT X2.* FROM cnv_sample_name_over_control_name_60bp_exon_ref1_med_gene_cov X2 JOIN cnv_sample_name_ordered_genes X3 USING(gene_symbol)) X1
WHERE 
(cnv_ratio > 0.25 AND cnv_ratio < 0.75)
AND
(min_bowtie_bwa_ratio > (75/100) AND max_bowtie_bwa_ratio < (100/75))
AND 
avg_window_coverage > 10) A1
JOIN
(SELECT DISTINCT window_id FROM 
(SELECT Y2.* FROM cnv_sample_name_over_control_name_60bp_exon_ref2_med_gene_cov Y2 JOIN cnv_sample_name_ordered_genes Y3 USING(gene_symbol)) Y1
WHERE 
(cnv_ratio > 0.25 AND cnv_ratio < 0.75)
AND
(min_bowtie_bwa_ratio > (75/100) AND max_bowtie_bwa_ratio < (100/75))
AND 
avg_window_coverage > 10) B1
USING(window_id)) A2
JOIN
(SELECT DISTINCT window_id FROM 
(SELECT Z2.* FROM cnv_sample_name_over_control_name_60bp_exon_ref3_med_gene_cov Z2 JOIN cnv_sample_name_ordered_genes Z3 USING(gene_symbol)) Z1
WHERE 
(cnv_ratio > 0.25 AND cnv_ratio < 0.75)
AND
(min_bowtie_bwa_ratio > (75/100) AND max_bowtie_bwa_ratio < (100/75))
AND 
avg_window_coverage > 10) B2
USING(window_id);

DROP TABLE IF EXISTS `sample_name_one_window_het_temp1`;
CREATE TABLE `sample_name_one_window_het_temp1` AS
SELECT A.* FROM 
`sample_name_tso_one_window_het` B
JOIN
tso_windows_padded_pileup A
ON(A.window_id = B.window_id);
CREATE INDEX `sample_name_one_window_het_temp1_i` ON `sample_name_one_window_het_temp1`(chr,pos);

DROP TABLE IF EXISTS `sample_name_one_window_het_temp2`;
CREATE TABLE `sample_name_one_window_het_temp2` AS
SELECT A.*,coverage 
FROM
`sample_name_one_window_het_temp1` A
JOIN
`cnv_sample_name_bwa_pileup` B
ON(A.chr = B.chr AND A.pos = B.pos);
CREATE INDEX `sample_name_one_window_het_temp2_i` ON `sample_name_one_window_het_temp2`(chr,pos);

DROP TABLE IF EXISTS `sample_name_one_window_het_temp3`;
CREATE TABLE `sample_name_one_window_het_temp3` AS
SELECT A.*,coverage AS no_dup_coverage
FROM
`sample_name_one_window_het_temp1` A
JOIN
`cnv_sample_name_bwa_pileup_no_dup` B
ON(A.chr = B.chr AND A.pos = B.pos);
CREATE INDEX `sample_name_one_window_het_temp3_i` ON `sample_name_one_window_het_temp3`(chr,pos);

DROP TABLE IF EXISTS `sample_name_one_window_het_temp4`;
CREATE TABLE `sample_name_one_window_het_temp4` AS
SELECT A.*, (coverage/no_dup_coverage) AS duplication_ratio
FROM
`sample_name_one_window_het_temp2` A
JOIN 
`sample_name_one_window_het_temp3` B
ON(A.chr = B.chr AND A.pos = B.pos);
CREATE INDEX `sample_name_one_window_het_temp4_i` ON `sample_name_one_window_het_temp4`(chr,pos);

DROP TABLE IF EXISTS `sample_name_one_window_het_temp5`;
CREATE TABLE `sample_name_one_window_het_temp5` AS
SELECT chr, pos, AVG(A_over_B_ratio) AS cnv_ratio, AVG(bowtie_bwa_ratio) AS bowtie_bwa_ratio
FROM `cnv_sample_name_tso_over_control_name_n_bowtie_bwa_ratio_gene_out` GROUP BY chr, pos;
CREATE INDEX `sample_name_one_window_het_temp5_i` ON `sample_name_one_window_het_temp5`(chr,pos);

DROP TABLE IF EXISTS `sample_name_tso_one_window_het_raw_data`;
CREATE TABLE `sample_name_tso_one_window_het_raw_data` AS
SELECT DISTINCT A.*, cnv_ratio, bowtie_bwa_ratio 
FROM
`sample_name_one_window_het_temp4` A
JOIN
`sample_name_one_window_het_temp5` B
ON(A.chr = B.chr AND A.pos = B.pos);

select  *, NOW() AS time_stamp , 'sample_name' AS sample, 'control_name' AS control from `sample_name_tso_one_window_het_raw_data` order by window_id, chr, pos asc;
