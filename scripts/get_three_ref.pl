#!/usr/bin/perl
use POSIX qw(ceil floor);
use List::MoreUtils qw/ uniq /;
use strict;
use warnings;

# PERL MODULES
use DBI;

#####
# 
# This scripts was written to

my $numArgs = $#ARGV + 1;
my $count = 0;

my $table = "";
my $out_table = "";
my $db = "";
my $host = "";
my $user = "";
my $socket="";

while($count < $numArgs){
    if($ARGV[$count] =~ m/-t/){
        $table = $ARGV[$count +1 ]; 
    }elsif($ARGV[$count] =~ m/-o/){
        $out_table = $ARGV[$count +1 ];
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

my @params;
my $dbh = DBI->connect("DBI:mysql:$db;host=$host;mysql_socket=$socket",$user, undef,{ RaiseError => 1 } ) or die ( "Couldn't connect to database: " . DBI->errstr );

my $out_table1 = $out_table."_ref1";
my $out_table2 = $out_table."_ref2";
my $out_table3 = $out_table."_ref3";

my $drop_sql1 = "DROP TABLE IF EXISTS  ".$out_table1.";";
my $drop_tbl1 = $dbh->prepare($drop_sql1);
$drop_tbl1->execute or die "SQL Error: $DBI::errstr\n";

my $drop_sql2 = "DROP TABLE IF EXISTS  ".$out_table2.";";
my $drop_tbl2 = $dbh->prepare($drop_sql2);
$drop_tbl2->execute or die "SQL Error: $DBI::errstr\n";

my $drop_sql3 = "DROP TABLE IF EXISTS  ".$out_table3.";";
my $drop_tbl3 = $dbh->prepare($drop_sql3);
$drop_tbl3->execute or die "SQL Error: $DBI::errstr\n";


my $select_sql = "SELECT ref_exon_contig_id FROM (SELECT DISTINCT ref_exon_contig_id FROM ".$table.")A ORDER BY RAND() LIMIT 3;";
my $select = $dbh->prepare($select_sql);
$select->execute or die "SQL Error: $DBI::errstr\n";

my @ref_exon_contig_id_list;

my $i = 0;
while (my @row = $select->fetchrow_array) {
	$ref_exon_contig_id_list[$i] = $row[0]; 
	$i++;
}

my $create_out_table_sql1 = "CREATE TABLE ".$out_table1." AS SELECT * FROM ".$table." WHERE ref_exon_contig_id = '".$ref_exon_contig_id_list[0]."';";
my $create_out_table1 = $dbh->prepare($create_out_table_sql1);
$create_out_table1->execute or die "SQL Error: $DBI::errstr\n";
my $create_out_table1_index_sql = "CREATE INDEX ".$out_table1."_1 ON ".$out_table1."(chr,pos);";
my $create_out_table1_index = $dbh->prepare($create_out_table1_index_sql);
$create_out_table1_index->execute or die "SQL Error: $DBI::errstr\n";

my $create_out_table_sql2 = "CREATE TABLE ".$out_table2." AS SELECT * FROM ".$table." WHERE ref_exon_contig_id = '".$ref_exon_contig_id_list[1]."';";
my $create_out_table2 = $dbh->prepare($create_out_table_sql2);
$create_out_table2->execute or die "SQL Error: $DBI::errstr\n";
my $create_out_table2_index_sql = "CREATE INDEX ".$out_table2."_1 ON ".$out_table2."(chr,pos);";
my $create_out_table2_index = $dbh->prepare($create_out_table2_index_sql);
$create_out_table2_index->execute or die "SQL Error: $DBI::errstr\n";

my $create_out_table_sql3 = "CREATE TABLE ".$out_table3." AS SELECT * FROM ".$table." WHERE ref_exon_contig_id = '".$ref_exon_contig_id_list[2]."';";
my $create_out_table3 = $dbh->prepare($create_out_table_sql3);
$create_out_table3->execute or die "SQL Error: $DBI::errstr\n";
my $create_out_table3_index_sql = "CREATE INDEX ".$out_table3."_1 ON ".$out_table3."(chr,pos);";
my $create_out_table3_index = $dbh->prepare($create_out_table3_index_sql);
$create_out_table3_index->execute or die "SQL Error: $DBI::errstr\n";



