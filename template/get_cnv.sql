DROP TABLE IF EXISTS sample_name_random_forest_het;
CREATE TABLE sample_name_random_forest_het AS
SELECT DISTINCT gene_symbol from sample_name_predicted  WHERE random_forest = 'true' AND data_type = 'test';

DROP TABLE IF EXISTS sample_name_tso_cnv;
CREATE TABLE sample_name_tso_cnv AS
SELECT 'TruSightOne' AS capture, gene_symbol, type, avg_coverage, coverage_variance, coverage_std_dev, POWER(2,bb_ratio_variance) AS bb_ratio_variance, 
POWER(2,bb_ratio_std_dev) AS bb_ratio_std_dev
FROM
(SELECT gene_symbol, type, AVG(coverage) AS avg_coverage, VAR_SAMP(coverage) AS coverage_variance, STDDEV_SAMP(coverage) AS coverage_std_dev,
VAR_SAMP(bowtie_bwa_ratio) AS bb_ratio_variance, STDDEV_SAMP(bowtie_bwa_ratio) AS bb_ratio_std_dev
FROM
(SELECT A1.*, coverage, LOG2(bowtie_bwa_ratio) AS bowtie_bwa_ratio FROM
(SELECT DISTINCT A.gene_symbol, type, chr, pos FROM 
(
SELECT DISTINCT AA1.* FROM
cnv_sample_name_heterozygous AA1
JOIN
sample_name_random_forest_het BB1
USING(gene_symbol)
UNION
SELECT * FROM cnv_sample_name_amplification) A
JOIN
tso_exon_60bp_segments_main_data B
USING (gene_symbol)) A1
JOIN
cnv_sample_name_pileup_bowtie_bwa B1
ON(A1.chr = B1.chr AND A1.pos = B1.pos)) C GROUP BY gene_symbol) D
UNION
-- FOR HOMOZYGOUS DELETIONS, GET DATA FROM THE CONTROL SAMPLE
SELECT 'TruSightOne' AS capture, gene_symbol, type, avg_coverage, coverage_variance, coverage_std_dev, POWER(2,bb_ratio_variance) AS bb_ratio_variance, 
POWER(2,bb_ratio_std_dev) AS bb_ratio_std_dev
FROM
(SELECT gene_symbol, type, AVG(coverage) AS avg_coverage, VAR_SAMP(coverage) AS coverage_variance, STDDEV_SAMP(coverage) AS coverage_std_dev,
VAR_SAMP(bowtie_bwa_ratio) AS bb_ratio_variance, STDDEV_SAMP(bowtie_bwa_ratio) AS bb_ratio_std_dev
FROM
(SELECT A1.*, coverage, LOG2(bowtie_bwa_ratio) AS bowtie_bwa_ratio  FROM
(SELECT DISTINCT A.gene_symbol, type, chr, pos FROM 
cnv_sample_name_homozygous A
JOIN
tso_exon_60bp_segments_main_data B
USING (gene_symbol)) A1
JOIN
cnv_control_name_pileup_bowtie_bwa B1
ON(A1.chr = B1.chr AND A1.pos = B1.pos)) C GROUP BY gene_symbol) D;
