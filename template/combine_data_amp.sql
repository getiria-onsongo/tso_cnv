DROP TABLE IF EXISTS sample_name_data_amp;
CREATE TABLE sample_name_data_amp AS
SELECT A.window_id, mfe, gc, num_repeats, bb_sd, cnv_ratio_sd, cnv_ratio_dip_stat, cov_sd, cov_avg, dup_rat_avg, 
-1 AS true_deletion, 'nonel' AS label, 'sample_name' AS sample, 'test' AS data_type
FROM 
sample_name_window_data_amp A
JOIN
tso_data B
ON(A.window_id = B.window_id);
CREATE INDEX sample_name_data_amp_i ON sample_name_data_amp(window_id);  
