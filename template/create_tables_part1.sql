-- ---------------------------------------- sample_name_tso WITHING SAMPLE  ratio

DROP TABLE IF EXISTS cnv_sample_name_exon_within_ratio;
CREATE TABLE cnv_sample_name_exon_within_ratio(
exon_contig_id     VARCHAR(56),
chr                VARCHAR(32),
pos                INT(11),
coverage           INT(11),
ref_exon_contig_id VARCHAR(56),
ref_chr            VARCHAR(32),
ref_pos            INT(11),
ref_coverage       INT(11),
within_ratio       DECIMAL(20,16));
INSERT INTO cnv_sample_name_exon_within_ratio(exon_contig_id,chr,pos,coverage,ref_exon_contig_id,ref_chr,ref_pos,ref_coverage,within_ratio)
SELECT A.exon_contig_id, A.chr, A.pos, A.coverage, 
B.exon_contig_id AS ref_exon_contig_id, B.chr AS ref_chr, B.pos AS ref_pos, B.coverage AS ref_coverage, (A.coverage/B.coverage) AS within_ratio 
FROM 
cnv_sample_name_exon_pileup A
JOIN 
cnv_sample_name_exon_reference B;
CREATE INDEX cnv_sample_name_exon_within_ratio_1 ON cnv_sample_name_exon_within_ratio(chr,pos,ref_exon_contig_id );

-- ---------------------------------------- control_name_tso WITHING SAMPLE  ratio
DROP TABLE IF EXISTS cnv_control_name_exon_within_ratio;
CREATE TABLE cnv_control_name_exon_within_ratio(
exon_contig_id     VARCHAR(56),
chr                VARCHAR(32),
pos                INT(11),
coverage           INT(11),
ref_exon_contig_id VARCHAR(56),
ref_chr            VARCHAR(32),
ref_pos            INT(11),
ref_coverage       INT(11),
within_ratio       DECIMAL(20,16));
INSERT INTO cnv_control_name_exon_within_ratio(exon_contig_id,chr,pos,coverage,ref_exon_contig_id,ref_chr,ref_pos,ref_coverage,within_ratio)
SELECT A.exon_contig_id, A.chr, A.pos, A.coverage, 
B.exon_contig_id AS ref_exon_contig_id, B.chr AS ref_chr, B.pos AS ref_pos, B.coverage AS ref_coverage, (A.coverage/B.coverage) AS within_ratio 
FROM 
cnv_control_name_exon_pileup A
JOIN 
cnv_control_name_exon_reference B;
CREATE INDEX cnv_control_name_exon_within_ratio_1 ON cnv_control_name_exon_within_ratio(chr,pos,ref_exon_contig_id );

-- ---------------------------------------- CROSS SAMPLE RATIO  sample_name_tso/control_name_tso  ratio
DROP TABLE IF EXISTS cnv_sample_name_over_control_name_tso;
CREATE TABLE cnv_sample_name_over_control_name_tso(
chr VARCHAR(8),
pos INT,
ref_exon_contig_id VARCHAR(56),
A_over_B_ratio DECIMAL(35,30));
INSERT INTO cnv_sample_name_over_control_name_tso(chr, pos, ref_exon_contig_id, A_over_B_ratio)
SELECT DISTINCT A.chr, A.pos, A.ref_exon_contig_id, (A.within_ratio/B.within_ratio) AS A_over_B_ratio
FROM 
cnv_sample_name_exon_within_ratio A
JOIN
cnv_control_name_exon_within_ratio B
USING(chr, pos, ref_exon_contig_id);
CREATE INDEX cnv_sample_name_over_control_name_1 ON cnv_sample_name_over_control_name_tso(chr, pos);

-- ---------------------------------------- ADD BOWTIE/BWA RATIO
DROP TABLE IF EXISTS cnv_sample_name_over_control_name_n_bowtie_bwa_ratio;
CREATE TABLE cnv_sample_name_over_control_name_n_bowtie_bwa_ratio AS
SELECT DISTINCT A.*, bowtie_bwa_ratio 
FROM
cnv_sample_name_over_control_name_tso A
JOIN
cnv_sample_name_exon_bwa_bowtie_ratio B
ON(A.chr = B.chr AND A.pos = B.pos);
CREATE INDEX cnv_sample_name_over_control_name_n_bowtie_bwa_ratio_1 ON cnv_sample_name_over_control_name_n_bowtie_bwa_ratio(chr, pos);



-- ---------------------------------------- ADD GENE SYMBOL
DROP TABLE IF EXISTS cnv_sample_name_over_control_name_n_bowtie_bwa_ratio_gene;
CREATE TABLE cnv_sample_name_over_control_name_n_bowtie_bwa_ratio_gene AS
SELECT DISTINCT A.*, gene_symbol
FROM
cnv_sample_name_over_control_name_n_bowtie_bwa_ratio A
JOIN
tso_exon_contig_pileup B
ON(A.chr = B.chr AND A.pos = B.pos);
CREATE INDEX cnv_sample_name_over_control_name_n_bowtie_bwa_ratio_gene_1 ON cnv_sample_name_over_control_name_n_bowtie_bwa_ratio_gene(ref_exon_contig_id, gene_symbol);
