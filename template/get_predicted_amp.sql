DROP TABLE IF EXISTS sample_name_predicted_amp;
CREATE TABLE sample_name_predicted_amp AS
SELECT DISTINCT gene_symbol, A.*, 'control_name' AS control
FROM
sample_name_prediction_amp A
JOIN
tso_exon_60bp_segments_window_data B
USING(window_id);
SELECT * FROM sample_name_predicted_amp;
