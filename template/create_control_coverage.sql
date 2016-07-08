DROP TABLE IF EXISTS `cnv_sample_name_over_control_name_60bp_exon_ref1_control`;
CREATE TABLE `cnv_sample_name_over_control_name_60bp_exon_ref1_control` AS
SELECT DISTINCT A.*, avg_window_coverage, ref_min_bowtie_bwa_ratio, ref_max_bowtie_bwa_ratio 
FROM
`cnv_sample_name_over_control_name_60bp_exon_ref1_med_gene` A
JOIN
`tso_exon_60bp_segments_main_data_control_name` B
ON(A.window_id = B.window_id); 
CREATE INDEX `cnv_sample_name_over_control_name_60bp_exon_ref1_contr` ON `cnv_sample_name_over_control_name_60bp_exon_ref1_control`(window_id);

DROP TABLE IF EXISTS `cnv_sample_name_over_control_name_60bp_exon_ref2_control`;
CREATE TABLE `cnv_sample_name_over_control_name_60bp_exon_ref2_control` AS
SELECT DISTINCT A.*, avg_window_coverage, ref_min_bowtie_bwa_ratio, ref_max_bowtie_bwa_ratio 
FROM
`cnv_sample_name_over_control_name_60bp_exon_ref2_med_gene` A
JOIN
`tso_exon_60bp_segments_main_data_control_name` B
ON(A.window_id = B.window_id); 
CREATE INDEX `cnv_sample_name_over_control_name_60bp_exon_ref2_contr` ON `cnv_sample_name_over_control_name_60bp_exon_ref2_control`(window_id);

DROP TABLE IF EXISTS `cnv_sample_name_over_control_name_60bp_exon_ref3_control`;
CREATE TABLE `cnv_sample_name_over_control_name_60bp_exon_ref3_control` AS
SELECT DISTINCT A.*, avg_window_coverage, ref_min_bowtie_bwa_ratio, ref_max_bowtie_bwa_ratio 
FROM
`cnv_sample_name_over_control_name_60bp_exon_ref3_med_gene` A
JOIN
`tso_exon_60bp_segments_main_data_control_name` B
ON(A.window_id = B.window_id); 
CREATE INDEX `cnv_sample_name_over_control_name_60bp_exon_ref3_contr` ON `cnv_sample_name_over_control_name_60bp_exon_ref3_control`(window_id);
