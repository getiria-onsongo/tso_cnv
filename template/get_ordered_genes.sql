SELECT gene_symbol,ref_exon_contig_id,A3.window_id,min_bowtie_bwa_ratio,max_bowtie_bwa_ratio,cnv_ratio,exon_contig_id,exon_number,avg_window_coverage,window_number, cnv_called, random_forest
FROM
(SELECT DISTINCT window_id FROM tso_exon_60bp_segments_window_data) A3
LEFT JOIN
(SELECT A2.*,random_forest
FROM
(SELECT A1.*, cnv_called FROM
(SELECT DISTINCT A.gene_symbol,ref_exon_contig_id,window_id,min_bowtie_bwa_ratio,max_bowtie_bwa_ratio,cnv_ratio,exon_contig_id,exon_number,avg_window_coverage,window_number
FROM cnv_sample_name_over_control_name_60bp_exon_ref1_med_gene_cov A
JOIN
cnv_sample_name_ordered_genes
USING(gene_symbol)) A1
LEFT JOIN
(SELECT window_id,'yes' AS cnv_called FROM cnv_sample_name_over_control_name_joint_cov
UNION
SELECT window_id,'yes' AS cnv_called FROM cnv_sample_name_over_control_name_joint_control
UNION
SELECT window_id,'yes' AS cnv_called FROM cnv_sample_name_over_control_name_joint_cov_amp) B1
USING(window_id)) A2
LEFT JOIN
sample_name_predicted B2
USING(window_id)) B3
USING(window_id);
