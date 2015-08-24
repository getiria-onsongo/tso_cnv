#!/bin/bash

c_S1_R1=c_s1r1Fastq
c_S1_R2=c_s1r2Fastq
c_S2_R1=c_s2r1Fastq
c_S2_R2=c_s2r2Fastq

# Check to see if fastq files are compressed. If they are
# uncompress them into the working directory
#
# NOTE: The copying in the ELSE clause is not necessary. The files should be readable from data release. However, 
# there are instances where files permission are not set properly and user is unable to read files from data release. 
# This copying is a precautionary measure to make sure the program does not break if that happens. 

if [[ $c_S1_R1 = *.gz ]] ; then
    gunzip -c $c_S1_R1 > c_S1_R1.fastq
    c_S1_R1=c_S1_R1.fastq
else
    cp $c_S1_R1 c_S1_R1.fastq
    c_S1_R1=c_S1_R1.fastq
fi	

if [[ $c_S1_R2 = *.gz ]] ; then
    gunzip -c $c_S1_R2 > c_S1_R2.fastq
    c_S1_R2=c_S1_R2.fastq
else 
    cp $c_S1_R2 c_S1_R2.fastq
    c_S1_R2=c_S1_R2.fastq
fi

if [[ $c_S2_R1 = *.gz ]] ; then
    gunzip -c $c_S2_R1 > c_S2_R1.fastq
    c_S2_R1=c_S2_R1.fastq
else
    cp $c_S2_R1 c_S2_R1.fastq
    c_S2_R1=c_S2_R1.fastq
fi	

if [[ $c_S2_R2 = *.gz ]] ; then
    gunzip -c $c_S2_R2 > c_S2_R2.fastq
    c_S2_R2=c_S2_R2.fastq
else
    cp $c_S2_R2 c_S2_R2.fastq
    c_S2_R2=c_S2_R2.fastq
fi   

BWA_DB=bwa_db_value
BOWTIE2_DB=bowtie2_db_value
S_DB=seq_db

bwa mem -M -t 24 $BWA_DB $c_S1_R1 $c_S1_R2 > c_bwa_s1.sam
bwa mem -M -t 24 $BWA_DB $c_S2_R1 $c_S2_R2 > c_bwa_s2.sam
bowtie2 -p 24 -k 5 -x $BOWTIE2_DB -1 $c_S1_R1 -2 $c_S1_R2 -S c_bowtie2_s1.sam
bowtie2 -p 24 -k 5 -x $BOWTIE2_DB -1 $c_S2_R1 -2 $c_S2_R2 -S c_bowtie2_s2.sam

samtools view -q 10 -bS c_bwa_s1.sam > c_bwa_s1.bam
samtools view -q 10 -bS c_bwa_s2.sam > c_bwa_s2.bam
samtools view -q 10 -bS c_bowtie2_s1.sam > c_bowtie2_s1.bam
samtools view -q 10 -bS c_bowtie2_s2.sam > c_bowtie2_s2.bam

samtools merge c_bwa.bam c_bwa_s1.bam c_bwa_s2.bam
samtools merge c_bowtie2.bam c_bowtie2_s1.bam c_bowtie2_s2.bam

java -Xmx4g -jar  $CLASSPATH/picard.jar FixMateInformation SORT_ORDER=coordinate INPUT=c_bwa.bam OUTPUT=c_bwa.fixed.bam
java -Xmx4g -jar  $CLASSPATH/picard.jar MarkDuplicates REMOVE_DUPLICATES=true ASSUME_SORTED=true METRICS_FILE=c_bwa_duplicate_stats.txt INPUT=c_bwa.fixed.bam OUTPUT=c_bwa.fixed_nodup.bam
java -Xmx4g -jar  $CLASSPATH/picard.jar FixMateInformation SORT_ORDER=coordinate INPUT=c_bowtie2.bam OUTPUT=c_bowtie2.fixed.bam

samtools mpileup -f $S_DB -d 10000 -q 1 c_bwa.fixed.bam | cut -f 1,2,4 > cnv_control_name_bwa_pileup.txt
samtools mpileup -f $S_DB -d 10000 -q 1 c_bwa.fixed_nodup.bam | cut -f 1,2,4 > cnv_control_name_bwa_pileup_no_dup.txt
samtools mpileup -f $S_DB -d 10000 -q 1 c_bowtie2.fixed.bam | cut -f 1,2,4 > cnv_control_name_bowtie2_pileup.txt

rm -rf *.bam
rm -rf *.sam

