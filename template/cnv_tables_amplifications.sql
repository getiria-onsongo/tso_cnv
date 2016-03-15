DROP TABLE IF EXISTS `cnv_sample_name_over_control_name_joint_cov_amp`;
CREATE TABLE `cnv_sample_name_over_control_name_joint_cov_amp` AS
SELECT DISTINCT A1.* FROM
(SELECT A.* FROM
(SELECT DISTINCT *
FROM
`cnv_sample_name_over_control_name_60bp_exon_ref1_control`
WHERE cnv_ratio > 1.4 AND avg_window_coverage > 20 AND ref_min_bowtie_bwa_ratio >  0.9 AND ref_max_bowtie_bwa_ratio < 1.1) A
JOIN
(SELECT DISTINCT gene_symbol, gene_num_exons, exon_contig_id, window_id
FROM
`cnv_sample_name_over_control_name_60bp_exon_ref2_control`
WHERE cnv_ratio > 1.4 AND avg_window_coverage > 20 AND ref_min_bowtie_bwa_ratio >  0.9 AND ref_max_bowtie_bwa_ratio < 1.1) B
USING(window_id)) A1
JOIN
(SELECT DISTINCT gene_symbol, gene_num_exons, exon_contig_id, window_id
FROM
`cnv_sample_name_over_control_name_60bp_exon_ref3_control`
WHERE cnv_ratio > 1.4 AND avg_window_coverage > 20 AND ref_min_bowtie_bwa_ratio >  0.9 AND ref_max_bowtie_bwa_ratio < 1.1) B1
USING(window_id);
