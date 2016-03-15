CREATE INDEX `cnv_sample_name_over_control_name_60bp_exon_ref1_med_1` ON `cnv_sample_name_over_control_name_60bp_exon_ref1_med`(window_id);
DROP TABLE IF EXISTS `cnv_sample_name_over_control_name_60bp_exon_ref1_med_gene`;
CREATE TABLE `cnv_sample_name_over_control_name_60bp_exon_ref1_med_gene` AS
SELECT DISTINCT A.*, exon_contig_id, exon_length, exon_number, gene_num_exons, gene_num_windows, window_number 
FROM
`cnv_sample_name_over_control_name_60bp_exon_ref1_med` A
JOIN
tso_exon_60bp_segments_window_data B
ON(A.window_id = B.window_id);
CREATE INDEX `cnv_sample_name_over_control_name_60bp_exon_ref1_med_gene_1` ON `cnv_sample_name_over_control_name_60bp_exon_ref1_med_gene`(gene_symbol);

CREATE INDEX `cnv_sample_name_over_control_name_60bp_exon_ref2_med_1` ON `cnv_sample_name_over_control_name_60bp_exon_ref2_med`(window_id);
DROP TABLE IF EXISTS `cnv_sample_name_over_control_name_60bp_exon_ref2_med_gene`;
CREATE TABLE `cnv_sample_name_over_control_name_60bp_exon_ref2_med_gene` AS
SELECT DISTINCT A.*, exon_contig_id, exon_length, exon_number, gene_num_exons, gene_num_windows, window_number 
FROM
`cnv_sample_name_over_control_name_60bp_exon_ref2_med` A
JOIN
tso_exon_60bp_segments_window_data B
ON(A.window_id = B.window_id);
CREATE INDEX `cnv_sample_name_over_control_name_60bp_exon_ref2_med_gene_1` ON `cnv_sample_name_over_control_name_60bp_exon_ref2_med_gene`(gene_symbol);

CREATE INDEX `cnv_sample_name_over_control_name_60bp_exon_ref3_med_1` ON `cnv_sample_name_over_control_name_60bp_exon_ref3_med`(window_id);
DROP TABLE IF EXISTS `cnv_sample_name_over_control_name_60bp_exon_ref3_med_gene`;
CREATE TABLE `cnv_sample_name_over_control_name_60bp_exon_ref3_med_gene` AS
SELECT DISTINCT A.*, exon_contig_id, exon_length, exon_number, gene_num_exons, gene_num_windows, window_number 
FROM
`cnv_sample_name_over_control_name_60bp_exon_ref3_med` A
JOIN
tso_exon_60bp_segments_window_data B
ON(A.window_id = B.window_id);
CREATE INDEX `cnv_sample_name_over_control_name_60bp_exon_ref3_med_gene_1` ON `cnv_sample_name_over_control_name_60bp_exon_ref3_med_gene`(gene_symbol);
