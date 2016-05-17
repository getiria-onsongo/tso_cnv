SELECT A1.*, cnvrf FROM 
(SELECT DISTINCT	window_id, cnv_type  FROM
cnv_sample_name_ordered_genes A
JOIN
(SELECT gene_symbol, window_id,'het' AS cnv_type FROM cnv_sample_name_over_control_name_joint_cov
UNION
SELECT gene_symbol, window_id,'hom' AS cnv_type FROM cnv_sample_name_over_control_name_joint_control
UNION
SELECT gene_symbol, window_id,'gain' AS cnv_type FROM cnv_sample_name_over_control_name_joint_cov_amp) B
USING(gene_symbol)) A1
LEFT JOIN
(SELECT window_id, random_forest AS cnvrf FROM sample_name_predicted) B1
USING(window_id);
