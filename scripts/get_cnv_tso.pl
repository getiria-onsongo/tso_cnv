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
my $partial_table = "";
my $count = 0;
my $num_exon_threshold = 0;
my $num_windows_threshold = 0;
my $min_cnv_ratio = -1;
my $max_cnv_ratio = -1;
my $type = "";
my $db = "";
my $host = "";
my $user ="";
my $socket="";


while($count < $numArgs){
    if($ARGV[$count] =~ m/-s/){
	    $table = $ARGV[$count +1 ];
    }elsif($ARGV[$count] =~ m/-e/){
        $num_exon_threshold = $ARGV[$count +1 ]; 
    }elsif($ARGV[$count] =~ m/-w/){
        $num_windows_threshold = $ARGV[$count +1 ]; 
    }elsif($ARGV[$count] =~ m/-o/){
        $sample_name = $ARGV[$count +1 ]; 
    }elsif($ARGV[$count] =~ m/-cmin/){
        $min_cnv_ratio = $ARGV[$count +1 ];
    }elsif($ARGV[$count] =~ m/-cmax/){
        $max_cnv_ratio = $ARGV[$count +1 ];
    }elsif($ARGV[$count] =~ m/-t/){
        $type = $ARGV[$count +1 ];
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

my $dbh = DBI->connect("DBI:mysql:$db;host=$host;mysql_socket=$socket",$user, undef,{ RaiseError => 1 } ) or die ( "Couldn't connect to database: " . DBI->errstr );

my $drop_sql = "DROP TABLE IF EXISTS  ".$sample_name.";";
my $drop_tbl = $dbh->prepare($drop_sql);
$drop_tbl->execute or die "SQL Error: $DBI::errstr\n";

my $create_sql = "CREATE TABLE ".$sample_name."(gene_symbol VARCHAR(32), type VARCHAR(32));";
my $create_tbl = $dbh->prepare($create_sql);
$create_tbl->execute or die "SQL Error: $DBI::errstr\n";

my $insert_gene_stmt = "";
my $insert_gene;

my $select_sql = "SELECT DISTINCT gene_symbol,exon_number, window_id, window_number FROM ".$table." WHERE cnv_ratio >= ".$min_cnv_ratio." AND cnv_ratio <= ".$max_cnv_ratio." ORDER BY gene_symbol, window_number ASC;";

my $select = $dbh->prepare($select_sql);
$select->execute or die "SQL Error: $DBI::errstr\n";

my @row = ();

my $gene_symbol = ""; 
my $exon_number = 1; 
my $window_id = 1; 
my $window_number = 1; 

my @gene_symbol_array = ();
my @exon_number_array = ();
my @window_id_array = ();
my @window_number_array = ();

while (@row = $select->fetchrow_array) { 
	$gene_symbol = $row[0]; 
	$exon_number = $row[1]; 
	$window_id = $row[2]; 
	$window_number = $row[3]; 

	push(@gene_symbol_array,$gene_symbol);
	push(@exon_number_array,$exon_number);
	push(@window_id_array,$window_id);
	push(@window_number_array,$window_number);
}

my $array_length = @gene_symbol_array;
my $num_contiguous_windows = 0;
my $num_contiguous_exons = 0;
my $update_array = 0;
my @exons = ();
my @windows = ();
my @genes = ();

for (my $cnt = 0; $cnt < ($array_length - 1); $cnt++) {
    if($gene_symbol_array[$cnt] ne $gene_symbol_array[$cnt + 1]){
	$update_array = 1;
    }else{
	$update_array = 0;
    }
    
    push(@exons,$exon_number_array[$cnt]);
    push(@windows,$window_number_array[$cnt]);

    if($window_number_array[$cnt] == ($window_number_array[$cnt + 1] - 1)){
	push(@exons,$exon_number_array[$cnt + 1]);
	push(@windows,$window_number_array[$cnt + 1]);
    }else{
	$update_array = 1;
    }

    $num_contiguous_windows = uniq @windows;
    $num_contiguous_exons = uniq @exons;

    if (($num_contiguous_windows >=  $num_windows_threshold) && ($num_contiguous_exons >= $num_exon_threshold)){
	push(@genes, $gene_symbol_array[$cnt]);
    }
    
    if($update_array == 1){
	@exons = ();
        @windows = ();
    }
}

my @uniq_genes = uniq @genes;
my $genes_length = @uniq_genes;
for (my $cnt = 0; $cnt < $genes_length; $cnt++) {
    $insert_gene_stmt = "INSERT INTO ".$sample_name."(gene_symbol, type) values('".$uniq_genes[$cnt]."','".$type."');";
    $insert_gene = $dbh->prepare($insert_gene_stmt);
    $insert_gene->execute or die "SQL Error: $DBI::errstr\n";
}
