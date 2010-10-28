#!/usr/bin/perl -W

# Ref
# http://www.funddj.com/kmdj/wiki/wikiviewer.aspx?keyid=71cd44f6-1150-43c1-b064-869b7e8c37a2

package FINANCE::MACD;
use FINANCE::HISTORY_INFO;
use FINANCE::UTIL;
#use FINANCE::EMA;
use Data::Dumper;
use strict;
use Switch

$FINANCE::MACD::util;
%FINANCE::MACD::table;

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

$FINANCE::MACD::util  = FINANCE::UTIL->new($hslist);

%FINANCE::MACD::table = ();
   
return bless {};	
}

sub get_pt_by_inx{
	 my ($inx) = (@_);
	
	 my $pt = ($FINANCE::MACD::util->get_hg_pric_by_inx($inx) +
                   $FINANCE::MACD::util->get_lw_pric_by_inx($inx) +
                 2*$FINANCE::MACD::util->get_cl_pric_by_inx($inx)   )/4;
return $pt;
}

sub get_avg_dif_by_inx{
    my ($len,$inx) = (@_);
   
    my $bg_inx = $inx - $len +1;
    my $avg = 0;

    for(my $i=$bg_inx; $i<=$inx; $i++){

      $avg += $FINANCE::MACD::table{$len}{$i}{DIF};
    }
   
    $avg = ($len!=0)? $avg/$len : 0;

return $avg; 
}

sub get_dif_by_inx{
    my ($len,$inx) = (@_);
 
    return $FINANCE::MACD::table{$len}{$inx}{DIF};
}

sub get_all_MACD_by_inx{
          my ($len,$inx) = (@_);
          
          my $bg_inx = $len;

          my $macd = get_avg_dif_by_inx($len,$bg_inx);

          for(my $i=$bg_inx; $i<=$inx; $i++){
            $macd = ($len!=-1)? $macd + 2/(1+$len)*( get_dif_by_inx($len,$i)- $macd) : 0;

            $FINANCE::MACD::table{$len}{$i}{MACD} = $macd;
            $FINANCE::MACD::table{$len}{$i}{OSC}  = get_dif_by_inx($len,$i) - $macd;
          }
} 

sub get_all_dif_by_inx{
           my ($len,$inx) = (@_);	
	    
           my $bg_inx   = $len+26;
           my $ema_fast = $FINANCE::MACD::util->get_bk_avg_close_pric_by_inx(12,$bg_inx);
           my $ema_slow = $FINANCE::MACD::util->get_bk_avg_close_pric_by_inx(26,$bg_inx);

           for(my $i=$bg_inx; $i<=$inx; $i++){
             $ema_fast = $ema_fast + 2/(1+12)*(get_pt_by_inx($i) - $ema_fast);
             $ema_slow = $ema_slow + 2/(1+26)*(get_pt_by_inx($i) - $ema_slow);     
	
             my $dif = $ema_fast - $ema_slow;

             $FINANCE::MACD::table{$len}{$i}{DIF} = $dif;

             }         
}

sub run_all {
    my ($self,$len) = (@_);

    my $ed_inx = $FINANCE::MACD::util->get_end_inx();

    get_all_dif_by_inx($len,$ed_inx); 
    get_all_MACD_by_inx($len,$ed_inx);

}

sub get_MACD_by_inx{
    my ($len,$inx) = (@_);

#   printf Dumper(\%FINANCE::MACD::table); 
   return $FINANCE::MACD::table{$len}{$inx};
}

sub get_MACD {
           my ($self,$len,$time) = (@_);  
    
	   my $inx = $FINANCE::MACD::util->get_inx_by_time($time);
           my $macd= get_MACD_by_inx($len,$inx);
	  
return $macd; 
}

1;
