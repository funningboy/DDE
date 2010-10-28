#!/usr/bin/perl -W

# Ref
# http://www.funddj.com/kmdj/wiki/wikiviewer.aspx?keyid=23a3c55b-de94-4731-911e-e814469dd2c7

package FINANCE::EMA;
use FINANCE::HISTORY_INFO;
use FINANCE::UTIL;
use Data::Dumper;
use strict;
use Switch

$FINANCE::EMA::util;
%FINANCE::EMA::table;

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

$FINANCE::EMA::util  = FINANCE::UTIL->new($hslist);
%FINANCE::EMA::table = ();
  
return bless {};	
}

sub get_all_EMA_by_inx{
    my ($len,$inx)  = (@_);   
 
    my $bg_inx = $len;

    my $avg_op = $FINANCE::EMA::util->get_bk_avg_open_pric_by_inx($len,$bg_inx);
    my $avg_hg = $FINANCE::EMA::util->get_bk_avg_high_pric_by_inx($len,$bg_inx);
    my $avg_lw = $FINANCE::EMA::util->get_bk_avg_low_pric_by_inx($len,$bg_inx);
    my $avg_cl = $FINANCE::EMA::util->get_bk_avg_close_pric_by_inx($len,$bg_inx);

    for(my $i=$bg_inx+1; $i<=$inx; $i++){
       $avg_op = ($len!=-1)? $avg_op + 2/($len+1) * ($FINANCE::EMA::util->get_op_pric_by_inx($i) - $avg_op) : 0;
       $avg_hg = ($len!=-1)? $avg_hg + 2/($len+1) * ($FINANCE::EMA::util->get_hg_pric_by_inx($i) - $avg_hg) : 0;
       $avg_lw = ($len!=-1)? $avg_lw + 2/($len+1) * ($FINANCE::EMA::util->get_lw_pric_by_inx($i) - $avg_lw) : 0;
       $avg_cl = ($len!=-1)? $avg_cl + 2/($len+1) * ($FINANCE::EMA::util->get_cl_pric_by_inx($i) - $avg_cl) : 0;
   
      $FINANCE::EMA::table{$len}{$i} = {
                   EMA_OPEN => $avg_op,
                   EMA_HIGH => $avg_hg,
                   EMA_LOW  => $avg_lw,
                   EMA_CLOSE=> $avg_cl,
         };
   } 

}

sub run_all{
   my ($self,$len) = (@_);
 
   my $ed_inx = $FINANCE::EMA::util->get_end_inx();

    get_all_EMA_by_inx($len,$ed_inx);
}

sub get_EMA_by_inx{
    my ($len,$inx) = (@_);
 
    return $FINANCE::EMA::table{$len}{$inx};
}

sub get_EMA{
   my ($self,$len,$time) = (@_);

   my $inx = $FINANCE::EMA::util->get_inx_by_time($time);

   my $ema = get_EMA_by_inx($len,$inx);

   return $ema;
}

1;
