DROP TABLE IF EXISTS cnv_sample_name_over_control_name_joint_cov;
CREATE TABLE cnv_sample_name_over_control_name_joint_cov AS
SELECT DISTINCT A1.* FROM
(SELECT A.* FROM
(SELECT DISTINCT * 
FROM 
cnv_sample_name_over_control_name_60bp_exon_ref1_med_gene_cov
WHERE min_bowtie_bwa_ratio >  0.9 AND max_bowtie_bwa_ratio < 1.1 AND cnv_ratio > 0.3 AND cnv_ratio < 0.7 AND avg_window_coverage > 20 ) A
JOIN
(SELECT DISTINCT gene_symbol, gene_num_exons, exon_contig_id, window_id 
FROM 
cnv_sample_name_over_control_name_60bp_exon_ref2_med_gene_cov
WHERE min_bowtie_bwa_ratio >  0.9 AND max_bowtie_bwa_ratio < 1.1 AND cnv_ratio > 0.3 AND cnv_ratio < 0.7 AND avg_window_coverage > 20) B
USING(window_id)) A1
JOIN
(SELECT DISTINCT gene_symbol, gene_num_exons, exon_contig_id, window_id 
FROM 
cnv_sample_name_over_control_name_60bp_exon_ref3_med_gene_cov
WHERE min_bowtie_bwa_ratio >  0.9 AND max_bowtie_bwa_ratio < 1.1 AND cnv_ratio > 0.3 AND cnv_ratio < 0.7 AND avg_window_coverage > 20) B1
USING(window_id);

DROP TABLE IF EXISTS cnv_sample_name_over_control_name_joint_control;
CREATE TABLE cnv_sample_name_over_control_name_joint_control AS
SELECT DISTINCT A1.* FROM
(SELECT A.* FROM
(SELECT DISTINCT * 
FROM 
cnv_sample_name_over_control_name_60bp_exon_ref1_control
WHERE cnv_ratio <= 0.3 AND avg_window_coverage > 20 AND ref_min_bowtie_bwa_ratio >  0.9 AND ref_max_bowtie_bwa_ratio < 1.1) A
JOIN
(SELECT DISTINCT gene_symbol, gene_num_exons, exon_contig_id, window_id 
FROM 
cnv_sample_name_over_control_name_60bp_exon_ref2_control
WHERE cnv_ratio <= 0.3 AND avg_window_coverage > 20 AND ref_min_bowtie_bwa_ratio >  0.9 AND ref_max_bowtie_bwa_ratio < 1.1) B
USING(window_id)) A1
JOIN
(SELECT DISTINCT gene_symbol, gene_num_exons, exon_contig_id, window_id 
FROM 
cnv_sample_name_over_control_name_60bp_exon_ref3_control
WHERE cnv_ratio <= 0.3 AND avg_window_coverage > 20 AND ref_min_bowtie_bwa_ratio >  0.9 AND ref_max_bowtie_bwa_ratio < 1.1) B1
USING(window_id);
