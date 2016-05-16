SELECT DISTINCT A4.*, random_forest AS random_forest_het_del FROM
(SELECT A3.*, cnv_called FROM
(SELECT A1.*, B1.avg_window_coverage AS avg_window_cov_control_name, B1.ref_min_bowtie_bwa_ratio AS min_bb_ratio_control_name, B1.ref_max_bowtie_bwa_ratio AS max_bb_ratio_control_name
FROM
(SELECT 
A.gene_symbol,A.ref_exon_contig_id, A.exon_contig_id, A.exon_number, A.window_id, A.window_number, cnv_ratio AS cnv_ratio1, cnv_ratio2, cnv_ratio3,
A.avg_window_coverage AS avg_window_cov_sample_name, min_bowtie_bwa_ratio AS min_bb_ratio_sample_name, A.max_bowtie_bwa_ratio AS max_bb_ratio_sample_name
FROM
(SELECT X3.*, X4.cnv_ratio AS cnv_ratio3 FROM
(SELECT X1.*, X2.cnv_ratio AS cnv_ratio2 FROM
cnv_sample_name_over_control_name_60bp_exon_ref1_med_gene_cov X1
JOIN
cnv_sample_name_over_control_name_60bp_exon_ref2_med_gene_cov X2
USING(window_id)) X3
JOIN
cnv_sample_name_over_control_name_60bp_exon_ref3_med_gene_cov X4
USING(window_id)) A
JOIN
cnv_sample_name_ordered_genes B
USING(gene_symbol)) A1
JOIN
cnv_sample_name_over_control_name_60bp_exon_ref1_control B1
USING(window_id)) A3
LEFT JOIN
(SELECT window_id,'yes' AS cnv_called FROM cnv_sample_name_over_control_name_joint_cov
UNION
SELECT window_id,'yes' AS cnv_called FROM cnv_sample_name_over_control_name_joint_control
UNION
SELECT window_id,'yes' AS cnv_called FROM cnv_sample_name_over_control_name_joint_cov_amp) B3
USING(window_id)) A4
LEFT JOIN
sample_name_predicted B4
USING(window_id) ORDER BY gene_symbol,window_number;
