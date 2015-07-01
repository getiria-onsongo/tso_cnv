SELECT * FROM 
(SELECT B.*
FROM 
cnv_sample_name_ordered_genes A
JOIN
(
SELECT gene_symbol, window_id,cnv_ratio,exon_contig_id,avg_window_coverage FROM cnv_sample_name_over_control_name_joint_cov
UNION
SELECT gene_symbol, window_id,cnv_ratio,exon_contig_id,avg_window_coverage FROM cnv_sample_name_over_control_name_joint_cov_oe 
UNION
SELECT gene_symbol, window_id,cnv_ratio,exon_contig_id,avg_window_coverage FROM cnv_sample_name_over_control_name_joint_control 
UNION
SELECT gene_symbol, window_id,cnv_ratio,exon_contig_id,avg_window_coverage FROM cnv_sample_name_over_control_name_joint_cov_amp 
UNION
SELECT gene_symbol, window_id,cnv_ratio,exon_contig_id,avg_window_coverage FROM cnv_sample_name_over_control_name_joint_cov_oe_amp 
) B
USING(gene_symbol)
UNION
SELECT  B1.*
FROM
cnv_sample_name_ordered_genes A1
JOIN
(SELECT gene_symbol, window_id,cnv_ratio,exon_contig_id,avg_window_coverage FROM cnv_sample_name_over_control_name_60bp_exon_ref1_med_gene_cov) B1
USING(gene_symbol)) C
ORDER BY gene_symbol, window_id;
