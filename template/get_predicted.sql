DROP TABLE IF EXISTS `sample_name_predicted`;
CREATE TABLE `sample_name_predicted` AS
SELECT DISTINCT A1.*, gene_symbol FROM 
(SELECT DISTINCT A.window_id,A.mfe,A.gc,A.num_repeats,A.bb_sd,A.cnv_ratio_sd,A.cnv_ratio_dip_stat,A.cov_sd,A.cov_avg,
A.dup_rat_avg,A.true_deletion,random_forest,A.sample,A.data_type 
FROM
`sample_name_data` A
JOIN
`sample_name_prediction` B
USING(window_id)) A1
JOIN
tso_exon_60bp_segments_window_data B1
USING(window_id);
SELECT * FROM `sample_name_predicted`;
