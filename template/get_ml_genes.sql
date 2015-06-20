DROP TABLE IF EXISTS ml_genes;
CREATE TABLE ml_genes AS
SELECT DISTINCT A.gene_symbol from
(SELECT * FROM sample_name_predicted WHERE random_forest = 'true')A
JOIN
(SELECT * FROM cnv_sample_name_heterozygous_mult_3w
UNION
SELECT * FROM cnv_sample_name_heterozygous_mult_oe_3w) B
USING(gene_symbol)
UNION
SELECT DISTINCT gene_symbol FROM cnv_sample_name_homozygous_3w;

SELECT A1.* FROM
(SELECT gene_symbol, window_id,cnv_ratio,exon_contig_id,avg_window_coverage FROM cnv_sample_name_over_control_name_joint_cov
UNION
SELECT gene_symbol, window_id,cnv_ratio,exon_contig_id,avg_window_coverage FROM cnv_sample_name_over_control_name_joint_cov_oe
UNION
SELECT gene_symbol, window_id,cnv_ratio,exon_contig_id,avg_window_coverage FROM cnv_sample_name_over_control_name_joint_control
UNION
SELECT gene_symbol, window_id,cnv_ratio,exon_contig_id,avg_window_coverage FROM cnv_sample_name_over_control_name_joint_cov_amp
UNION
SELECT gene_symbol, window_id,cnv_ratio,exon_contig_id,avg_window_coverage FROM cnv_sample_name_over_control_name_joint_cov_oe_amp) A1
JOIN
ml_genes B1
USING(gene_symbol);
