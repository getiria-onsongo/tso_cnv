#!/usr/bin/perl
use POSIX qw(ceil floor);
use List::MoreUtils qw/ uniq /;
use List::MoreUtils qw(firstidx);
use strict;
use warnings;

# PERL MODULES
use DBI;

#####
# 
# This scripts was written to

my $numArgs = $#ARGV + 1;
my $table = "";
my $sample_name = "";
my $cnv_table = "";
my $cnv_ordered = "";
my $script_name = "";
my $count = 0;
my $OUTFILE;
my $db = "";
my $host = "";
my $user = "";
my $socket="";
my $ordered="";

while($count < $numArgs){
    if($ARGV[$count] =~ m/-t/){
	    $table = $ARGV[$count +1 ];
    }elsif($ARGV[$count] =~ m/-s/){
        $sample_name = $ARGV[$count +1 ];
    }elsif($ARGV[$count] =~ m/-c/){
        $cnv_table = $ARGV[$count +1 ];
    }elsif($ARGV[$count] =~ m/-k/){
        $cnv_ordered = $ARGV[$count +1 ];
    }elsif($ARGV[$count] =~ m/-o/){
        $script_name = $ARGV[$count +1 ];
    }elsif($ARGV[$count] =~ m/-d/){
        $db = $ARGV[$count +1 ];
    }elsif($ARGV[$count] =~ m/-h/){
        $host = $ARGV[$count +1 ];
    }elsif($ARGV[$count] =~ m/-u/){
        $user = $ARGV[$count +1 ];
    }elsif($ARGV[$count] =~ m/-ms/){
        $socket = $ARGV[$count +1 ];
    }elsif($ARGV[$count] =~ m/-ord/){
	$ordered = $ARGV[$count +1 ];
    }else{
		
    }
    $count = $count + 1;
}

open($OUTFILE, '>>', $script_name) or die "Could not open file '$script_name' $!";

my $dbh = DBI->connect("DBI:mysql:$db;host=$host;mysql_socket=$socket",$user, undef,{ RaiseError => 1 } ) or die ( "Couldn't connect to database: " . DBI->errstr );

my $select_sql = "";

if($ordered == 1){
    $select_sql = "SELECT DISTINCT gene_symbol FROM ".$cnv_ordered.";";
}else{
    $select_sql = "SELECT gene_symbol FROM ".$cnv_table." UNION SELECT gene_symbol FROM ".$cnv_ordered.";";
}

my $select = $dbh->prepare($select_sql);
$select->execute or die "SQL Error: $DBI::errstr\n";

my @row = ();
my $gene_symbol = ""; 

while (@row = $select->fetchrow_array) { 
	$gene_symbol = $row[0];
    print $OUTFILE "cnv_plot_all_bowtie_bwa(con, \"".$table."\", \"pos\",\"gene_symbol\", \"".$gene_symbol."\", \"A_over_B_ratio\",\"bowtie_bwa_ratio\",2.0,\"".$gene_symbol."_".$sample_name."_noise_red_ratio\",dir_path);\n";
}

print $OUTFILE "dbDisconnect(con)\n";
close $OUTFILE;
