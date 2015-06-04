DROP TABLE IF EXISTS sample_name_predicted;
CREATE TABLE sample_name_predicted AS
SELECT DISTINCT gene_symbol, A.*, 'control_name' AS control
FROM
sample_name_prediction A
JOIN
tso_exon_60bp_segments_window_data B
USING(window_id);
SELECT * FROM sample_name_predicted;
