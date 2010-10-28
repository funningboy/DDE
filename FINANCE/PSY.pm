#!/usr/bin/perl -W

# Ref 
# http://www.funddj.com/kmdj/wiki/wikiviewer.aspx?keyid=4395d6a3-524e-479b-b2c7-ac3d5c9b5ffd

package FINANCE::PSY;
use FINANCE::HISTORY_INFO;
use FINANCE::UTIL;
use Data::Dumper;
use strict;
use Switch

$FINANCE::PSY::util;
$FINANCE::PSY::table;

sub get_help{
   my ($case,@in) = (@_);
   switch($case){
      case "get_input_info" { printf("@ input hash table error                            \
                                   please check the %hash in new*( had already exist \n"); }
   }
die;
}

sub new {
my ($self,$hslist) = (@_);

if( !keys %{$hslist}){ get_help("get_input_info"); }

$FINANCE::PSY::util  = FINANCE::UTIL->new($hslist);
%FINANCE::PSY::table = ();
   
return bless {};	
}


sub run_all {
	   my ($slef,$len) = (@_);
	   
           my $ed_inx = $FINANCE::PSY::util->get_end_inx();

	   get_ALL_PSY_by_inx($len,$ed_inx);
	   
}

sub get_fact_by_inx{
    my ($len,$inx) = (@_);
    
     my $bg_inx = $inx - $len +1;
     my $cot = 0;

    for(my $i=$bg_inx; $i<=$inx; $i++){
      my  $fact = $FINANCE::PSY::util->get_cl_pric_by_inx($i)- $FINANCE::PSY::util->get_cl_pric_by_inx($i-1);
          if($fact>0){ $cot++; }  
   }

return $cot; 
}

sub get_ALL_PSY_by_inx{
	   my ($len,$inx) = (@_);  
	
	   my $bg_inx = $len;
       
       for(my $i=$bg_inx; $i<=$inx; $i++){
           my $cot = get_fact_by_inx($len,$i);
           my $psy = ($len!=0)? ($cot/$len)*100 : 0;

            $FINANCE::PSY::table{$len}{$i} = {
                      PSY => $psy,
             };
     }		   
}

sub get_PSY_by_inx{
     my ($len,$inx) = (@_);

return $FINANCE::PSY::table{$len}{$inx}; 
}

sub get_PSY{
    my ($self,$len,$time) = (@_);

    my $inx = $FINANCE::PSY::util->get_inx_by_time($time);
    my $psy = get_PSY_by_inx($len,$inx);

return $psy;     
}

1;
