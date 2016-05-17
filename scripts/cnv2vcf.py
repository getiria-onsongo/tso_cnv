#!/usr/bin/python
#-*- coding: utf-8 -*-
#===============================================================================
#
#         FILE: test.py
#
#        USAGE: ./test.py  
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
header = "##fileformat=VCFv4.1\n##reference=/panfs/roc/rissdb/genomes/Homo_sapiens/hg19_canonical/seq/hg19_canonical.fa\n##INFO=<ID=CNVRF,Number=1,Type=String,Description=\"Classified as variant by CNV-RF\">\n#CHROM\tPOS\tID\tREF\tALT\tQUAL\tFILTER\tINFO\tFORMAT\tsample"
ifp = open(sys.argv[1])
ofp = open('temp.vcf.bed','w')
window_id_column=int(sys.argv[2])
cnv_type_column=int(sys.argv[3])
cnv_rf_call_column=int(sys.argv[4])

for line in ifp:
	items = line.rstrip().split()
	if items[cnv_type_column] != 'gain' and items[cnv_type_column] != 'hom' and items[cnv_type_column] != 'het':
		continue
	chr = items[window_id_column].split('_')[0]
	if items[cnv_type_column] == 'hom' or items[cnv_type_column] == 'het':
		start = int(items[window_id_column].split('_')[1]) - 2
	else:
		start = int(items[window_id_column].split('_')[1]) - 1
	end = items[window_id_column].split('_')[2]
	name = chr+'_'+str(start)+'_'+items[cnv_type_column]+'_'+items[cnv_rf_call_column]
	print >> ofp, chr+'\t'+str(start)+'\t'+end+'\t'+name
ifp.close()
ofp.close()
os.system('fastaFromBed -fi /panfs/roc/rissdb/genomes/Homo_sapiens/hg19_canonical/seq/hg19_canonical.fa -bed temp.vcf.bed -name -tab -fo temp.seq.txt')
print header
ifp = open('temp.seq.txt')
for line in ifp:
	items = line.rstrip().split()
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
	print chr+'\t'+str(int(start)+1)+'\t.\t'+ref.upper()+'\t'+alt.upper()+'\t'+'\t'.join(['.']*2)+'\t'+'CNVRF='+cnvrf+'\t'+gt
# os.remove('temp.seq.txt')
# os.remove('temp.vcf.bed')
