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
my $gene_list = "";
my $sample_data = "";
my $script_name = "";
my $count = 0;
my $OUTFILE;
my $db = "";
my $host = "";
my $user = "";
my $pass = "";
my $socket="";

while($count < $numArgs){
    if($ARGV[$count] =~ m/-t/){
	    $gene_list = $ARGV[$count +1 ];
    }elsif($ARGV[$count] =~ m/-c/){
        $sample_data = $ARGV[$count +1 ];
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
    }else{
		
    }
    $count = $count + 1;
}

open($OUTFILE, '>>', $script_name) or die "Could not open file '$script_name' $!";

my $dbh = DBI->connect("DBI:mysql:$db;host=$host;mysql_socket=$socket",$user, undef,{ RaiseError => 1 } ) or die ( "Couldn't connect to database: " . DBI->errstr );

my $select_sql = "SELECT DISTINCT gene_symbol FROM ".$gene_list.";";
my $select = $dbh->prepare($select_sql);
$select->execute or die "SQL Error: $DBI::errstr\n";

my @row = ();
my $gene_symbol = ""; 

print $OUTFILE "SELECT * FROM ".$sample_data." WHERE \n";

while (@row = $select->fetchrow_array) { 
	$gene_symbol = $row[0];
    print $OUTFILE "gene_symbol = '".$gene_symbol."' OR \n";
}

print $OUTFILE "1 > 2 \n"; # we are printing this to prevent an extra OR in the generated SQL statement. Since this expr evaluates to FALSE, it does not change query meaning
print $OUTFILE "order by window_id; \n";
close $OUTFILE;
