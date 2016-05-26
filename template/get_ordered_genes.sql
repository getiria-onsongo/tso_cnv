-- First select is not necessary but we need it to re-order columns. A legacy downstream script needs
-- columns represented in the give order
SELECT gene_symbol,ref_exon_contig_id,exon_contig_id,exon_number,window_id,window_number,cnv_ratio1,cnv_ratio2,cnv_ratio3,avg_window_cov_sample,min_bb_ratio_sample,max_bb_ratio_sample,avg_window_cov_control,min_bb_ratio_control,max_bb_ratio_control,cnv_called,cnv_rf,cnv_type FROM
(SELECT DISTINCT A4.*, random_forest AS cnv_rf FROM
(SELECT A3.*, cnv_called, cnv_type FROM
(SELECT A1.*, B1.avg_window_coverage AS avg_window_cov_control, B1.ref_min_bowtie_bwa_ratio AS min_bb_ratio_control, B1.ref_max_bowtie_bwa_ratio AS max_bb_ratio_control
FROM
(SELECT 
A.gene_symbol,A.ref_exon_contig_id, A.exon_contig_id, A.exon_number, A.window_id, A.window_number, cnv_ratio AS cnv_ratio1, cnv_ratio2, cnv_ratio3,
A.avg_window_coverage AS avg_window_cov_sample, min_bowtie_bwa_ratio AS min_bb_ratio_sample, A.max_bowtie_bwa_ratio AS max_bb_ratio_sample
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
(
SELECT window_id,'yes' AS cnv_called, 'het' AS cnv_type FROM cnv_sample_name_over_control_name_joint_cov
UNION
SELECT window_id,'yes' AS cnv_called, 'hom' AS cnv_type FROM cnv_sample_name_over_control_name_joint_control
UNION
SELECT window_id,'yes' AS cnv_called,'gain' AS cnv_type FROM cnv_sample_name_over_control_name_joint_cov_amp) B3
USING(window_id)) A4
LEFT JOIN
sample_name_predicted B4
USING(window_id) ORDER BY gene_symbol,window_number) final_results; 
