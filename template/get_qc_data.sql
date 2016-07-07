-- Should not need the DISTINCT key word but just in case. 
SELECT DISTINCT gene_symbol,window_id,window_number,min_bowtie_bwa_ratio,max_bowtie_bwa_ratio,cnv_ratio AS median_cnv_ratio, avg_window_coverage, 'sample_name' AS sample
FROM 
cnv_sample_name_over_control_name_60bp_exon_ref1_med_gene_cov ORDER BY gene_symbol, window_id;
