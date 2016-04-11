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
#       AUTHOR: Rendong Yang (cauyrd@gmail.com), 
# ORGANIZATION: 
#      VERSION: 1.0
#      CREATED: Wed Apr 30 13:27:17 CDT 2014
#     REVISION: ---
#===============================================================================
import sys
import os
# NOTE: the path here does NOT matter
header = "##fileformat=VCFv4.1\n##reference=/mnt/genomes/Homo_sapiens/hg19_canonical/seq/hg19_canonical.fa\n#CHROM\tPOS\tID\tREF\tALT\tQUAL\tFILTER\tINFO\tFORMAT\tsample"
ifp = open(sys.argv[1])
ofp = open('temp.vcf.bed','w')
for line in ifp:
	items = line.rstrip().split()
	if items[-1] != 'gain' and items[-1] != 'hom' and items[-1] != 'het':
		continue
	chr = items[4].split('_')[0]
	if items[-1] == 'hom' or items[-1] == 'het':
		start = int(items[4].split('_')[1]) - 1
	else:
		start = int(items[4].split('_')[1])
	end = items[4].split('_')[2]
	name = chr+'_'+str(start)+'_'+items[-1]
	print >> ofp, chr+'\t'+str(start)+'\t'+end+'\t'+name
ifp.close()
ofp.close()
# NOTE: the path here does matter
os.system('fastaFromBed -fi /mnt/genomes/Homo_sapiens/hg19_canonical/seq/hg19_canonical.fa -bed temp.vcf.bed -name -tab -fo temp.seq.txt')
print header
ifp = open('temp.seq.txt')
for line in ifp:
	items = line.rstrip().split()
	chr,start,name = items[0].split('_')
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
	print chr+'\t'+str(int(start)+1)+'\t.\t'+ref.upper()+'\t'+alt.upper()+'\t'+'\t'.join(['.']*3)+'\t'+gt
os.remove('temp.seq.txt')
os.remove('temp.vcf.bed')



