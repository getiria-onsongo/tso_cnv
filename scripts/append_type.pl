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
my $header=0;
# Open a new file. If a file exists with same name it will be overwritten 
open ($OUT, ">", $output_file) || die "Could not open file >  $output_file $!";

# Open file for reading
open($INPUT, "<", $input_file)  || die "cannot open < $input_file: $!";

while(<$INPUT>) {
    my $type = 'unknown';
    if($header == 0){
	print $OUT $_;
	$header = $header + 1;
    }else{
	chomp; # Remove newline character at the end of line
	my $line = $_;
	my @cols = split(/\t/,$line );
	my $type;
	my $cnv = $cols[6];
	if($cnv < 0.3){
	    $type = 'hom';
	}elsif($cnv >= 0.3 && $cnv <= 0.7){
	    $type = 'het';
	}elsif($cnv > 0.7 && $cnv <= 1.4){
	    $type = 'norm';
	}elsif($cnv > 1.4){
	    $type = 'gain';
	}else{
	    # Do nothing
	}
	print $OUT $line."\t".$type."\n";
    }
}
close($INPUT) || die("$$: Error: failed to close file: $INPUT \n");
close($OUT) || die("$$: Error: failed to close file: $OUT \n");
