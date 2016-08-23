#!/usr/bin/python
#-*- coding: utf-8 -*-
#===============================================================================
#
#         FILE: test.py
#
#        USAGE: ./test.py cnv.output.txt win_id cnv_type cnv_rf reference 
#
#  DESCRIPTION: 
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Getiria Onsongo (getiria.onsongo@gmail.com), modied a script 
#              originally written by Rendong Yang
# ORGANIZATION: 
#      VERSION: 1.0
#      CREATED: Tue  May 17 13:27:17 CDT 2014
#     REVISION: ---
#===============================================================================
import sys
import os

ifp = open(sys.argv[1])
ofp = open('temp.vcf.bed','w')
ofp2 = open('temp.cnv.txt','w')
headers = ifp.readline().rstrip().split('\t')
start_index = headers.index('cnv_ratio1')

window_id_column=int(sys.argv[2])
cnv_type_column=int(sys.argv[3])
cnv_rf_call_column=int(sys.argv[4])
reference = sys.argv[-1]
header = "##fileformat=VCFv4.1\n##reference="+reference+"\n"\
"##INFO=<ID=cnv_ratio1,Number=1,Type=Float,Description=\"CNV ratio when using reference point 1\">\n"\
"##INFO=<ID=cnv_ratio2,Number=1,Type=Float,Description=\"CNV ratio when using reference point 2\">\n"\
"##INFO=<ID=cnv_ratio3,Number=1,Type=Float,Description=\"CNV ratio when using reference point 3\">\n"\
"##INFO=<ID=avg_window_cov_sample,Number=1,Type=Float,Description=\"Sample average sample coverage\">\n"\
"##INFO=<ID=min_bb_ratio_sample,Number=1,Type=Float,Description=\"Sample minimum Bowtie/Bwa ratio\">\n"\
"##INFO=<ID=max_bb_ratio_sample,Number=1,Type=Float,Description=\"Sample maximum Bowtie/Bwa ratio\">\n"\
"##INFO=<ID=avg_window_cov_control,Number=1,Type=Float,Description=\"Control average sample coverage\">\n"\
"##INFO=<ID=min_bb_ratio_control,Number=1,Type=Float,Description=\"Control minimum Bowtie/Bwa ratio\">\n"\
"##INFO=<ID=max_bb_ratio_control,Number=1,Type=Float,Description=\"Control maximum Bowtie/Bwa ratio\">\n"\
"##INFO=<ID=cnv_called,Number=1,Type=String,Description=\"Classified as variant using filters\">\n"\
"##INFO=<ID=cnv_rf,Number=1,Type=String,Description=\"Classified as variant by CNV-RF\">\n"\
"##INFO=<ID=cnv_type,Number=1,Type=String,Description=\"Type of variant: het = heterozygous deletion, hom=homozygous deletion, gain = copy gain\">\n"\
"#CHROM\tPOS\tID\tREF\tALT\tQUAL\tFILTER\tINFO\tFORMAT\tsample"

for line in ifp:
	items = line.rstrip().split('\t')
	try:
		if items[cnv_type_column] != 'gain' and items[cnv_type_column] != 'hom' and items[cnv_type_column] != 'het':
			continue
	except:
		continue
	chr = items[window_id_column].split('_')[0]
	if items[cnv_type_column] == 'hom' or items[cnv_type_column] == 'het':
		start = int(items[window_id_column].split('_')[1]) - 2
	else:
		start = int(items[window_id_column].split('_')[1]) - 1
	end = items[window_id_column].split('_')[2]
	name = chr+'_'+str(start)+'_'+items[cnv_type_column]+'_'+items[cnv_rf_call_column]
	print >> ofp, chr+'\t'+str(start)+'\t'+end+'\t'+name
	print >> ofp2, line.rstrip()
ifp.close()
ofp.close()
ofp2.close()
os.system('fastaFromBed -fi '+reference+' -bed temp.vcf.bed -name -tab -fo temp.seq.txt')
print header
ifp = open('temp.seq.txt')
ifp2 = open('temp.cnv.txt')
for line,line2 in zip(ifp,ifp2):
	items = line.rstrip().split('\t')
	items2 = line2.rstrip().split('\t')
	chr,start,name,cnvrf = items[0].split('_')
	if name == 'gain':
		ref = items[1]
		alt = items[1]*2
		gt = 'GT\t0/1'
	elif name == 'het':
		alt = items[1][0] 
		ref = items[1]
		gt = 'GT\t0/1'
	elif name == 'hom':
		alt = items[1][0]
		ref = items[1]
		gt = 'GT\t1/1'
	else:
		print 'type error: not gain or hom or het!'
		sys.exit(1)
	info = ''
	for i in range(start_index,len(headers)):
		info += headers[i]+'='+items2[i]+';'
	info = info[:-1]
	print chr+'\t'+str(int(start)+1)+'\t.\t'+ref.upper()+'\t'+alt.upper()+'\t'+'\t'.join(['.']*2)+'\t'+info+'\t'+gt
os.remove('temp.seq.txt')
os.remove('temp.vcf.bed')
os.remove('temp.cnv.txt')
