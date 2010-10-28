#!/usr/bin/perl -W

# Ref
# http://www.funddj.com/kmdj/wiki/wikiviewer.aspx?keyid=71cd44f6-1150-43c1-b064-869b7e8c37a2

package FINANCE::MA;
use FINANCE::HISTORY_INFO;
use FINANCE::UTIL;
use Data::Dumper;
use strict;
use Switch

$FINANCE::MA::util;
$FINANCE::MA::table;

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

$FINANCE::MA::util  = FINANCE::UTIL->new($hslist);
%FINANCE::MA::table = ();
    
return bless {};	
}



sub get_all_MA_by_inx{
  my ($len,$inx) = (@_);
	
  my $bg_inx = $len;

  for(my $i=$bg_inx; $i<=$inx; $i++){       
      my $avg_cl = $FINANCE::MA::util->get_bk_avg_close_pric_by_inx($len,$i);
      my $avg_op = $FINANCE::MA::util->get_bk_avg_open_pric_by_inx($len,$i);
  
      my $avg_p  = ($avg_cl+$avg_op)>>1;
  
      my ($up_p,$lw_p)=($avg_p*1.1,$avg_p*0.9);
  
      $FINANCE::MA::table{$len}{$i} = {
                MA_UP   => $up_p,
                MA_MID  => $avg_p,
                MA_DOWN => $lw_p,
          };
    } 
}

sub run_all {
    my ($self,$len) = (@_);

    my $ed_inx = $FINANCE::MA::util->get_end_inx();

    get_all_MA_by_inx($len,$ed_inx); 
}

sub get_MA_by_inx{
     my ($len,$inx) = (@_);

 #    printf Dumper(\%FINANCE::MA::table);
     return $FINANCE::MA::table{$len}{$inx};
}

sub get_MA{
	my ($self,$len,$time) = (@_);
	  
        my $inx = $FINANCE::MA::util->get_inx_by_time($time); 

        my $ma  = get_MA_by_inx($len,$inx); 
       
return $ma;	
}


1;
