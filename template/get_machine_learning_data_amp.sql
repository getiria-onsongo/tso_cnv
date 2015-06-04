DROP TABLE IF EXISTS sample_name_tso_one_window_het_amp;
CREATE TABLE sample_name_tso_one_window_het_amp AS
SELECT DISTINCT A2.window_id FROM
(SELECT DISTINCT A1.window_id FROM
(SELECT DISTINCT window_id FROM 
cnv_sample_name_over_control_name_60bp_exon_ref1_control
WHERE 
(cnv_ratio > 1.4 AND cnv_ratio < 10000)
AND
(min_bowtie_bwa_ratio > (75/100) AND max_bowtie_bwa_ratio < (100/75))
AND 
avg_window_coverage > 10) A1
JOIN
(SELECT DISTINCT window_id FROM 
cnv_sample_name_over_control_name_60bp_exon_ref2_control
WHERE 
(cnv_ratio > 1.4 AND cnv_ratio < 10000)
AND
(min_bowtie_bwa_ratio > (75/100) AND max_bowtie_bwa_ratio < (100/75))
AND 
avg_window_coverage > 10) B1
USING(window_id)) A2
JOIN
(SELECT DISTINCT window_id FROM 
cnv_sample_name_over_control_name_60bp_exon_ref3_control
WHERE 
(cnv_ratio > 1.4 AND cnv_ratio < 10000)
AND
(min_bowtie_bwa_ratio > (75/100) AND max_bowtie_bwa_ratio < (100/75))
AND 
avg_window_coverage > 10) B2
USING(window_id);

DROP TABLE IF EXISTS sample_name_one_window_het_temp1_amp;
CREATE TABLE sample_name_one_window_het_temp1_amp AS
SELECT A.* FROM 
sample_name_tso_one_window_het_amp B
JOIN
tso_windows_padded_pileup A
ON(A.window_id = B.window_id);
CREATE INDEX sample_name_one_window_het_temp1_amp_i ON sample_name_one_window_het_temp1_amp(chr,pos);

DROP TABLE IF EXISTS sample_name_one_window_het_temp2_amp;
CREATE TABLE sample_name_one_window_het_temp2_amp AS
SELECT A.*,coverage 
FROM
sample_name_one_window_het_temp1_amp A
JOIN
cnv_sample_name_bwa_pileup B
ON(A.chr = B.chr AND A.pos = B.pos);
CREATE INDEX sample_name_one_window_het_temp2_amp_i ON sample_name_one_window_het_temp2_amp(chr,pos);

DROP TABLE IF EXISTS sample_name_one_window_het_temp3_amp;
CREATE TABLE sample_name_one_window_het_temp3_amp AS
SELECT A.*,coverage AS no_dup_coverage
FROM
sample_name_one_window_het_temp1_amp A
JOIN
cnv_sample_name_bwa_pileup_no_dup B
ON(A.chr = B.chr AND A.pos = B.pos);
CREATE INDEX sample_name_one_window_het_temp3_amp_i ON sample_name_one_window_het_temp3_amp(chr,pos);

DROP TABLE IF EXISTS sample_name_one_window_het_temp4_amp;
CREATE TABLE sample_name_one_window_het_temp4_amp AS
SELECT A.*, (coverage/no_dup_coverage) AS duplication_ratio
FROM
sample_name_one_window_het_temp2_amp A
JOIN 
sample_name_one_window_het_temp3_amp B
ON(A.chr = B.chr AND A.pos = B.pos);
CREATE INDEX sample_name_one_window_het_temp4_amp_i ON sample_name_one_window_het_temp4_amp(chr,pos);

DROP TABLE IF EXISTS sample_name_one_window_het_temp5_amp;
CREATE TABLE sample_name_one_window_het_temp5_amp AS
SELECT chr, pos, AVG(A_over_B_ratio) AS cnv_ratio, AVG(bowtie_bwa_ratio) AS bowtie_bwa_ratio
FROM cnv_sample_name_tso_over_control_name_n_bowtie_bwa_ratio_gene_out GROUP BY chr, pos;
CREATE INDEX sample_name_one_window_het_temp5_amp_i ON sample_name_one_window_het_temp5_amp(chr,pos);

DROP TABLE IF EXISTS sample_name_tso_one_window_het_raw_data_amp;
CREATE TABLE sample_name_tso_one_window_het_raw_data_amp AS
SELECT DISTINCT A.*, cnv_ratio, bowtie_bwa_ratio 
FROM
sample_name_one_window_het_temp4_amp A
JOIN
sample_name_one_window_het_temp5_amp B
ON(A.chr = B.chr AND A.pos = B.pos);

select  *, NOW() AS time_stamp , 'sample_name' AS sample, 'control_name' AS control from sample_name_tso_one_window_het_raw_data_amp order by window_id, chr, pos asc;
