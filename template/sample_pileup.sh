#!/bin/bash

S1_R1=s_s1r1Fastq
S1_R2=s_s1r2Fastq
S2_R1=s_s2r1Fastq
S2_R2=s_s2r2Fastq

# Check to see if fastq files are compressed. If they are                                                                         
# uncompress them into the working directory                                                                                      
#                                                                                                                                 
# NOTE: The copying in the ELSE clause is not necessary. The files should be readable from data release. However,                 
# there are instances where files permission are not set properly and user is unable to read files from data release.             
# This copying is a precautionary measure to make sure the program does not break if that happens.                                

if [[ $S1_R1 = *.gz ]] ; then
    gunzip -c $S1_R1 > S1_R1.fastq
    S1_R1=S1_R1.fastq
else
    cp $S1_R1 S1_R1.fastq
fi

if [[ $S1_R2 = *.gz ]] ; then
    gunzip -c $S1_R2 > S1_R2.fastq
    S1_R2=S1_R2.fastq
else
    cp $S1_R2 S1_R2.fastq
fi

if [[ $S2_R1 = *.gz ]] ; then
    gunzip -c $S2_R1 > S2_R1.fastq
    S2_R1=S2_R1.fastq
else
    cp $S2_R1 S2_R1.fastq
fi

if [[ $S2_R2 = *.gz ]] ; then
    gunzip -c $S2_R2 > S2_R2.fastq
    S2_R2=S2_R2.fastq
else
    cp $S2_R2 S2_R2.fastq
fi

BWA_DB=bwa_db_value
BOWTIE2_DB=bowtie2_db_value
S_DB=seq_db

bwa mem -M -t 24 $BWA_DB $S1_R1 $S1_R2 > bwa_s1.sam
bwa mem -M -t 24 $BWA_DB $S2_R1 $S2_R2 > bwa_s2.sam
bowtie2 -p 24 -k 5 -x $BOWTIE2_DB -1 $S1_R1 -2 $S1_R2 -S bowtie2_s1.sam
bowtie2 -p 24 -k 5 -x $BOWTIE2_DB -1 $S2_R1 -2 $S2_R2 -S bowtie2_s2.sam

samtools view -bS bwa_s1.sam > bwa_s1.bam
samtools view -bS bwa_s2.sam > bwa_s2.bam
samtools view -bS bowtie2_s1.sam > bowtie2_s1.bam
samtools view -bS bowtie2_s2.sam > bowtie2_s2.bam

samtools merge bwa.bam bwa_s1.bam bwa_s2.bam
samtools merge bowtie2.bam bowtie2_s1.bam bowtie2_s2.bam

java -Xmx4g -jar  $CLASSPATH/picard.jar FixMateInformation SORT_ORDER=coordinate INPUT=bwa.bam OUTPUT=bwa.fixed.bam
java -Xmx4g -jar  $CLASSPATH/picard.jar MarkDuplicates REMOVE_DUPLICATES=true ASSUME_SORTED=true METRICS_FILE=bwa_duplicate_stats.txt INPUT=bwa.fixed.bam OUTPUT=bwa.fixed_nodup.bam
java -Xmx4g -jar  $CLASSPATH/picard.jar FixMateInformation SORT_ORDER=coordinate INPUT=bowtie2.bam OUTPUT=bowtie2.fixed.bam

samtools mpileup -f $S_DB -d 10000 -q 1 bwa.fixed.bam | cut -f 1,2,4 > cnv_sample_name_bwa_pileup.txt
samtools mpileup -f $S_DB -d 10000 -q 1 bwa.fixed_nodup.bam | cut -f 1,2,4 > cnv_sample_name_bwa_pileup_no_dup.txt
samtools mpileup -f $S_DB -d 10000 -q 1 bowtie2.fixed.bam | cut -f 1,2,4 > cnv_sample_name_bowtie2_pileup.txt

rm -rf *.bam
rm -rf *.sam

