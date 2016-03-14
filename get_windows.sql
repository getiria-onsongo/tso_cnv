select DISTINCT chr, window_start, window_end, CONCAT(gene_symbol,"_",window_id) AS label FROM tso_exon_60bp_segments_main_data ORDER BY window_start;
