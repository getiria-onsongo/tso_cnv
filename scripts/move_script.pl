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
my $cnv_table = "";
my $script_name = "";
my $path = "";
my $count = 0;
my $OUTFILE;
my $db = "";
my $host = "";
my $user = "";
my $socket="";

while($count < $numArgs){
    if($ARGV[$count] =~ m/-c/){
        $cnv_table = $ARGV[$count +1 ];
    }elsif($ARGV[$count] =~ m/-o/){
        $script_name = $ARGV[$count +1 ];
    }elsif($ARGV[$count] =~ m/-p/){
	$path = $ARGV[$count +1 ];
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

open($OUTFILE, '>', $script_name) or die "Could not open file '$script_name' $!";

my $dbh = DBI->connect("DBI:mysql:$db;host=$host;mysql_socket=$socket",$user, undef,{ RaiseError => 1 } ) or die ( "Couldn't connect to database: " . DBI->errstr );

my $select_sql = "";
   $select_sql = "SELECT DISTINCT gene_symbol FROM `".$cnv_table."`;";

my $select = $dbh->prepare($select_sql);
$select->execute or die "SQL Error: $DBI::errstr\n";

my @row = ();
my $gene_symbol = ""; 

while (@row = $select->fetchrow_array) { 
	$gene_symbol = $row[0];

	print $OUTFILE "ls -1 ".$gene_symbol."\*\.png > /dev/null 2>\&1 \n";
	print $OUTFILE "if [ \"\$\?\" = \"0\" ]; \n";
	print $OUTFILE "   then \n"; 
	print $OUTFILE "    cp  ".$gene_symbol."\*\.png  ".$path."\n";
	print $OUTFILE "else \n";
	print $OUTFILE "    echo \"Plot for ".$gene_symbol." not found\" \n";
	print $OUTFILE "fi \n";
}

close $OUTFILE;
