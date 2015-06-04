SELECT DISTINCT capture, gene_symbol, type, avg_coverage, coverage_std_dev, bb_ratio_std_dev, random_forest AS predicted_random_forest, 'control_name' AS control
FROM 
sample_name_tso_cnv A
LEFT JOIN
(SELECT gene_symbol, random_forest FROM sample_name_predicted WHERE random_forest = 'true') B
USING(gene_symbol);
