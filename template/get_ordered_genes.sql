SELECT capture,A.gene_symbol,type,window_id,cnv_ratio,exon_contig_id,avg_window_coverage
FROM 
sample_name_tso_cnv A
JOIN
(
SELECT B1.* FROM
cnv_sample_name_ordered_genes A1
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
) B1
USING(gene_symbol)
) B
USING(gene_symbol) ORDER BY gene_symbol, window_id;
