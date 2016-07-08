DROP TABLE IF EXISTS ref1_sample_name_ratio;
CREATE TABLE ref1_sample_name_ratio AS 
SELECT window_id, window_number, window_start, window_end, MIN(gene_symbol) AS gene_symbol, 
AVG(A_over_B_ratio) AS avg_ratio, MIN(bowtie_bwa_ratio) AS min_bowtie_bwa_ratio, MAX(bowtie_bwa_ratio) AS max_bowtie_bwa_ratio FROM
(SELECT A.*, A_over_B_ratio, bowtie_bwa_ratio FROM
tso_exon_60bp_segments_main_data A
JOIN
`cnv_sample_name_over_control_name_ref1`  B
ON(A.chr = B.chr AND A.pos = B.pos)) C GROUP BY window_id;
CREATE INDEX `ref1_sample_name_ratio_i` ON `ref1_sample_name_ratio`(window_id);

DROP TABLE IF EXISTS `ref2_sample_name_ratio`;
CREATE TABLE `ref2_sample_name_ratio` AS 
SELECT window_id, window_number, window_start, window_end, MIN(gene_symbol) AS gene_symbol, 
AVG(A_over_B_ratio) AS avg_ratio, MIN(bowtie_bwa_ratio) AS min_bowtie_bwa_ratio, MAX(bowtie_bwa_ratio) AS max_bowtie_bwa_ratio FROM
(SELECT A.*, A_over_B_ratio, bowtie_bwa_ratio FROM
tso_exon_60bp_segments_main_data A
JOIN
`cnv_sample_name_over_control_name_ref2` B
ON(A.chr = B.chr AND A.pos = B.pos)) C GROUP BY window_id;
CREATE INDEX `ref2_sample_name_ratio_i` ON `ref2_sample_name_ratio`(window_id);

DROP TABLE IF EXISTS `ref3_sample_name_ratio`;
CREATE TABLE `ref3_sample_name_ratio` AS 
SELECT window_id, window_number, window_start, window_end, MIN(gene_symbol) AS gene_symbol, 
AVG(A_over_B_ratio) AS avg_ratio, MIN(bowtie_bwa_ratio) AS min_bowtie_bwa_ratio, MAX(bowtie_bwa_ratio) AS max_bowtie_bwa_ratio FROM
(SELECT A.*, A_over_B_ratio, bowtie_bwa_ratio FROM
tso_exon_60bp_segments_main_data A
JOIN
`cnv_sample_name_over_control_name_ref3` B
ON(A.chr = B.chr AND A.pos = B.pos)) C GROUP BY window_id;
CREATE INDEX `ref3_sample_name_ratio_i` ON `ref3_sample_name_ratio`(window_id);

DROP TABLE IF EXISTS `data_sample_name_temp`;
CREATE TABLE `data_sample_name_temp` AS
SELECT A.*, B.avg_ratio AS ref2_avg_ratio, B.min_bowtie_bwa_ratio AS ref2_min_bowtie_bwa_ratio, B.max_bowtie_bwa_ratio AS ref2_max_bowtie_bwa_ratio
FROM 
`ref1_sample_name_ratio` A
JOIN
`ref2_sample_name_ratio` B
ON(A.window_id = B.window_id);
CREATE INDEX `data_sample_name_temp_i` ON `data_sample_name_temp`(window_id);

DROP TABLE IF EXISTS `data_sample_name`;
CREATE TABLE `data_sample_name` AS
SELECT A1.*, B1.avg_ratio AS ref3_avg_ratio, B1.min_bowtie_bwa_ratio AS ref3_min_bowtie_bwa_ratio, B1.max_bowtie_bwa_ratio AS ref3_max_bowtie_bwa_ratio
FROM
`data_sample_name_temp` A1
JOIN
`ref3_sample_name_ratio` B1
ON(A1.window_id = B1.window_id);
CREATE INDEX data_sample_name_i ON data_sample_name(window_id);
