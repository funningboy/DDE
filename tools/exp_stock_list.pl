#! /usr/bin/perl -W

use strict;

my $file = "stock_id.csv";
 
open(ifile,"<$file") or die "open $file error\n";

while(<ifile>){
  chomp;
   my $id = $_;
      $id =~ s/\.TW//g;

   print "   \"$id\"    =>  \[\"$_\"\,\"\.\/data_off\/stock\/$id\/\"\]\,\n";
}
