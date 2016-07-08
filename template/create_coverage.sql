DROP TABLE IF EXISTS `cnv_sample_name_pileup_bowtie_bwa`;
CREATE TABLE `cnv_sample_name_pileup_bowtie_bwa` AS
SELECT DISTINCT A.chr, A.pos, A.coverage, bowtie_bwa_ratio
FROM
`cnv_sample_name_exon_pileup` A
JOIN
`cnv_sample_name_exon_bwa_bowtie_ratio` B
USING(chr,pos);
CREATE INDEX `cnv_sample_name_pileup_bowtie_bwa_i1` ON  `cnv_sample_name_pileup_bowtie_bwa`(chr,pos);

DROP TABLE IF EXISTS `tso_sample_name_window`;
CREATE TABLE `tso_sample_name_window` AS
SELECT window_id, AVG(coverage) AS avg_window_coverage, VAR_SAMP(coverage) AS window_coverage_var, STDDEV_SAMP(coverage) AS window_coverage_std,
MIN(bowtie_bwa_ratio) AS min_bowtie_bwa_ratio, MAX(bowtie_bwa_ratio) AS max_bowtie_bwa_ratio,
VAR_SAMP(bowtie_bwa_ratio) AS window_bb_ratio_var, STDDEV_SAMP(bowtie_bwa_ratio) AS window_bb_ratio_std
FROM
(SELECT DISTINCT window_id, A.pos, coverage, bowtie_bwa_ratio
FROM
tso_exon_60bp_segments_main_data A
JOIN
`cnv_sample_name_pileup_bowtie_bwa` B
ON(A.chr = B.chr AND A.pos = B.pos)) A1 GROUP BY window_id;
CREATE INDEX `tso_sample_name_window_i1` ON  `tso_sample_name_window`(window_id);

DROP TABLE IF EXISTS `tso_exon_60bp_segments_main_data_sample_name`;
CREATE TABLE `tso_exon_60bp_segments_main_data_sample_name` AS
SELECT DISTINCT A.*, avg_window_coverage, window_coverage_var, window_coverage_std, min_bowtie_bwa_ratio, max_bowtie_bwa_ratio, window_bb_ratio_var, window_bb_ratio_std
FROM
tso_exon_60bp_segments_main_data A
JOIN
`tso_sample_name_window` B
USING(window_id);
CREATE INDEX `tso_exon_60bp_segments_main_data_sample_name_i1` ON  `tso_exon_60bp_segments_main_data_sample_name`(window_id);


DROP TABLE IF EXISTS `cnv_control_name_pileup_bowtie_bwa`; 
CREATE TABLE `cnv_control_name_pileup_bowtie_bwa` AS
SELECT DISTINCT A.chr, A.pos, A.coverage, bowtie_bwa_ratio 
FROM
`cnv_control_name_exon_pileup` A
JOIN
`cnv_control_name_exon_bwa_bowtie_ratio` B
USING(chr,pos);
CREATE INDEX `cnv_control_name_pileup_bowtie_bwa_i1` ON  `cnv_control_name_pileup_bowtie_bwa`(chr,pos);

DROP TABLE IF EXISTS `tso_control_name_window`;
CREATE TABLE `tso_control_name_window` AS
SELECT window_id, AVG(coverage) AS avg_window_coverage, VAR_SAMP(coverage) AS window_coverage_var, STDDEV_SAMP(coverage) AS window_coverage_std,
MIN(bowtie_bwa_ratio) AS ref_min_bowtie_bwa_ratio, MAX(bowtie_bwa_ratio) AS ref_max_bowtie_bwa_ratio,
VAR_SAMP(bowtie_bwa_ratio) AS window_bb_ratio_var, STDDEV_SAMP(bowtie_bwa_ratio) AS window_bb_ratio_std
FROM 
(SELECT DISTINCT window_id, A.pos, coverage, bowtie_bwa_ratio 
FROM
tso_exon_60bp_segments_main_data A
JOIN
`cnv_control_name_pileup_bowtie_bwa` B
ON(A.chr = B.chr AND A.pos = B.pos)) A1 GROUP BY window_id;
CREATE INDEX `tso_control_name_window_i1` ON  `tso_control_name_window`(window_id);

DROP TABLE IF EXISTS `tso_exon_60bp_segments_main_data_control_name`;
CREATE TABLE `tso_exon_60bp_segments_main_data_control_name` AS
SELECT DISTINCT A.*, avg_window_coverage, window_coverage_var, window_coverage_std, ref_min_bowtie_bwa_ratio, ref_max_bowtie_bwa_ratio, window_bb_ratio_var, window_bb_ratio_std
FROM
tso_exon_60bp_segments_main_data A
JOIN
`tso_control_name_window` B
USING(window_id);
CREATE INDEX `tso_exon_60bp_segments_main_data_control_name_i1` ON  `tso_exon_60bp_segments_main_data_control_name`(window_id);
