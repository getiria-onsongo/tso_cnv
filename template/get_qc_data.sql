-- Should not need the DISTINCT key word but just in case. 
SELECT DISTINCT A1.*,C.min_bowtie_bwa_ratio AS C_min_bb_ratio,C.max_bowtie_bwa_ratio AS C_max_bb_ratio,C.cnv_ratio AS C_median_cnv_ratio, C.avg_window_coverage AS C_avg_window_cov
FROM 
(SELECT 'sample_name' AS sample, A.gene_symbol,A.window_id,A.window_number,A.min_bowtie_bwa_ratio AS A_min_bb_ratio,A.max_bowtie_bwa_ratio AS A_max_bb_ratio,A.cnv_ratio AS A_median_cnv_ratio, A.avg_window_coverage AS A_avg_window_cov,
B.min_bowtie_bwa_ratio AS B_min_bb_ratio,B.max_bowtie_bwa_ratio AS B_max_bb_ratio,B.cnv_ratio AS B_median_cnv_ratio, B.avg_window_coverage AS B_avg_window_cov
FROM 
cnv_sample_name_over_control_name_60bp_exon_ref1_med_gene_cov A
JOIN
cnv_sample_name_over_control_name_60bp_exon_ref2_med_gene_cov B
ON(A.window_id=B.window_id)) A1
JOIN
cnv_sample_name_over_control_name_60bp_exon_ref3_med_gene_cov C
ON(A1.window_id=C.window_id);
