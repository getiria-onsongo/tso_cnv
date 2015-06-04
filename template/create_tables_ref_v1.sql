DROP TABLE IF EXISTS cnv_sample_name_over_control_name_60bp_exon_ref1;
CREATE TABLE cnv_sample_name_over_control_name_60bp_exon_ref1 AS
SELECT DISTINCT A.*,ref_exon_contig_id, A_over_B_ratio, bowtie_bwa_ratio  
FROM
tso_exon_60bp_segments_pileup A
JOIN
cnv_sample_name_over_control_name_ref1 B
ON(A.chr = B.chr AND A.pos = B.pos);
CREATE INDEX cnv_sample_name_over_control_name_60bp_exon_ref1_1 ON cnv_sample_name_over_control_name_60bp_exon_ref1(window_id);

DROP TABLE IF EXISTS cnv_sample_name_over_control_name_60bp_exon_ref2;
CREATE TABLE cnv_sample_name_over_control_name_60bp_exon_ref2 AS
SELECT DISTINCT A.*,ref_exon_contig_id, A_over_B_ratio, bowtie_bwa_ratio  
FROM
tso_exon_60bp_segments_pileup A
JOIN
cnv_sample_name_over_control_name_ref2 B
ON(A.chr = B.chr AND A.pos = B.pos);
CREATE INDEX cnv_sample_name_over_control_name_60bp_exon_ref2_1 ON cnv_sample_name_over_control_name_60bp_exon_ref2(window_id);


DROP TABLE IF EXISTS cnv_sample_name_over_control_name_60bp_exon_ref3;
CREATE TABLE cnv_sample_name_over_control_name_60bp_exon_ref3 AS
SELECT DISTINCT A.*,ref_exon_contig_id, A_over_B_ratio, bowtie_bwa_ratio  
FROM
tso_exon_60bp_segments_pileup A
JOIN
cnv_sample_name_over_control_name_ref3 B
ON(A.chr = B.chr AND A.pos = B.pos);
CREATE INDEX cnv_sample_name_over_control_name_60bp_exon_ref3_1 ON cnv_sample_name_over_control_name_60bp_exon_ref3(window_id);
