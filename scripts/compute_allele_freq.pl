#!/usr/bin/env perl -w

####################################################################################################
# Copyright: (c) 2015 Getiria Onsongo
# All Rights Reserved.
#
####################################################################################################
# 
use strict;
use warnings;
use Math::BigFloat;

my $input_file;
my $output_file;
my $count = 0;
my $numArgs = $#ARGV + 1;

$|++; # force auto flush of output buffer

while($count < $numArgs){
    if($ARGV[$count] =~ m/-i/){
        $input_file = $ARGV[$count +1 ];
    }elsif($ARGV[$count] =~ m/-o/){
        $output_file = $ARGV[$count +1 ];
    }else{
        
    }
    $count = $count + 1;
}

my $INPUT;
my $OUT;

# Open a new file. If a file exists with same name it will be overwritten 
open ($OUT, ">", $output_file) || die "Could not open file >  $output_file $!";

# Open file for reading
open($INPUT, "<", $input_file)  || die "cannot open < $input_file: $!";

while(<$INPUT>) {
    chomp; # Remove newline character at the end of line
    my $line = $_;
    my @cols = split(/\t/,$line );
    my $chr = $cols[0];
    my $pos = $cols[1]; 
    my $ref_base = $cols[2];
    my $coverage = $cols[3];
    my $A = $cols[6]; my $C = $cols[7]; my $G = $cols[8];  my $T = $cols[9];
    my $A_freq = 0;   my $C_freq = 0;   my $G_freq = 0;    my $T_freq = 0;
    if ($coverage > 0) {
	$A_freq = $A / $coverage;
	$C_freq = $C / $coverage;
	$G_freq = $G / $coverage;
	$T_freq = $T / $coverage;
	if($A_freq > 0){
	    print $OUT $chr."\t".$pos."\t".$ref_base."\t".$coverage."\tA\t".$A_freq."\n";
	}
	if($C_freq > 0){
            print $OUT $chr."\t".$pos."\t".$ref_base."\t".$coverage."\tC\t".$C_freq."\n";
	}
	if($G_freq > 0){
            print $OUT $chr."\t".$pos."\t".$ref_base."\t".$coverage."\tG\t".$G_freq."\n";
	}
	if($T_freq > 0){
            print $OUT $chr."\t".$pos."\t".$ref_base."\t".$coverage."\tT\t".$T_freq."\n";
	}
    }
}
close($INPUT) || die("$$: Error: failed to close file: $INPUT \n");
close($OUT) || die("$$: Error: failed to close file: $OUT \n");
