SELECT A.* FROM
(SELECT * FROM sample_name_predicted
UNION
SELECT * FROM sample_name_predicted_amp) A
JOIN
cnv_sample_name_ordered_genes B
USING(gene_symbol);
