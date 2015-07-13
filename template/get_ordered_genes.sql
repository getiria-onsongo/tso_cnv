SELECT A2.*, random_forest FROM
(SELECT gene_symbol, window_id,cnv_ratio,exon_contig_id,avg_window_coverage, max(cnv_called) AS cnv_called FROM 
(SELECT B.*
FROM 
cnv_sample_name_ordered_genes A
JOIN
(
SELECT gene_symbol, window_id,cnv_ratio,exon_contig_id,avg_window_coverage, 'yes' AS cnv_called FROM 
(SELECT X1.* FROM cnv_sample_name_over_control_name_joint_cov X1 JOIN cnv_sample_name_heterozygous USING(gene_symbol)) Y1
UNION
SELECT gene_symbol, window_id,cnv_ratio,exon_contig_id,avg_window_coverage, 'yes' AS cnv_called FROM 
(SELECT X2.* FROM cnv_sample_name_over_control_name_joint_control X2 JOIN cnv_sample_name_homozygous USING(gene_symbol)) Y2
UNION
SELECT gene_symbol, window_id,cnv_ratio,exon_contig_id,avg_window_coverage, 'yes' AS cnv_called FROM 
(SELECT X3.* FROM cnv_sample_name_over_control_name_joint_cov_amp X3 JOIN cnv_sample_name_amplification USING(gene_symbol)) Y3) B
USING(gene_symbol)
UNION
SELECT  B1.*
FROM
cnv_sample_name_ordered_genes A1
JOIN
(SELECT gene_symbol, window_id,cnv_ratio,exon_contig_id,avg_window_coverage, 'no' AS cnv_called FROM cnv_sample_name_over_control_name_60bp_exon_ref1_med_gene_cov) B1
USING(gene_symbol)) C GROUP BY window_id) A2
LEFT JOIN
sample_name_predicted
USING(window_id)
ORDER BY gene_symbol, window_id;
-- NOTE 1: We are using group by so it can pick up entry from the YES group as opposed to NO. Easy way to distinguish called and uncalled windows
-- NOTE 2: If a window has NO in cnv_called but TRUE in random forest it means the window did not pass cnv filters e.g., ration btw 0.3 and 0.7
-- but the machine learning algorithm nevertheless marked it as a deletion 
