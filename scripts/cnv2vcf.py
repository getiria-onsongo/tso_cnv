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
#       AUTHOR: Getiria Onsongo (getiria.onsongo@gmail.com), 
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
headers = ifp.readline().rstrip().split()
start_index = headers.index('cnv_ratio1')

window_id_column=int(sys.argv[2])
cnv_type_column=int(sys.argv[3])
cnv_rf_call_column=int(sys.argv[4])
reference = sys.argv[-1]
header = "##fileformat=VCFv4.1\n##reference="+reference+"\n##INFO=<ID=CNVRF,Number=1,Type=String,Description=\"Classified as variant by CNV-RF\">\n#CHROM\tPOS\tID\tREF\tALT\tQUAL\tFILTER\tINFO\tFORMAT\tsample"

for line in ifp:
	items = line.rstrip().split()
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
	items = line.rstrip().split()
	items2 = line2.rstrip().split()
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
