DROP TABLE IF EXISTS `sample_name_3_random_ref`;
CREATE TABLE `sample_name_3_random_ref` AS
SELECT DISTINCT A1.* FROM
tso_reference A1
JOIN
(SELECT gene_symbol FROM (SELECT DISTINCT gene_symbol FROM tso_reference_exon)B ORDER BY RAND() LIMIT 3) B1
ON(A1.gene_symbol = B1.gene_symbol);

CREATE INDEX `sample_name_3_random_ref_i1` ON `sample_name_3_random_ref`(chr,pos);
CREATE INDEX `sample_name_3_random_ref_i2` ON `sample_name_3_random_ref`(exon_contig_id);
