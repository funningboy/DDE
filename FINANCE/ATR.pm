#!/usr/bin/perl -W

# Ref ATR 
# http://www.funddj.com/KMDJ/wiki/WikiViewer.aspx?Title=ATR%u6307%u6A19

package FINANCE::ATR;
use FINANCE::HISTORY_INFO;
use FINANCE::UTIL;
use Data::Dumper;
use strict;
use Switch

$FINANCE::ATR::util;
%FINANCE::ATR::table;

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

$FINANCE::ATR::util  = FINANCE::UTIL->new($hslist);
%FINANCE::ATR::table = ();
   
return bless {};	
}

sub get_TR_by_inx {
     my ($inx) = (@_);
     my (@tr) =[];
    #H_[t] - L_[t]
     push(@tr, abs($FINANCE::ATR::util->get_hg_pric_by_inx($inx) - $FINANCE::ATR::util->get_lw_pric_by_inx($inx)));  
     #H_[t] - C_[t-1]
     push(@tr, abs($FINANCE::ATR::util->get_hg_pric_by_inx($inx) - $FINANCE::ATR::util->get_cl_pric_by_inx($inx-1)));	
     #L_[t] - C_[t-1]  
     push(@tr, abs($FINANCE::ATR::util->get_lw_pric_by_inx($inx) - $FINANCE::ATR::util->get_cl_pric_by_inx($inx-1)));	
	          
     @tr = reverse sort {$a<=>$b} @tr;
	          
     return $tr[0];
}

sub get_TRMA_by_inx {
    my ($len,$inx) = (@_);
        
    my ($rma,$tr) =0;
      
    my $bg_inx = $inx - $len +1;
   
    for(my $i=$bg_inx; $i<=$inx; $i++){
    	  $tr += get_TR_by_inx($i);
     }
	  
    $rma = ($len!=0)? $tr/$len : 0;

return $rma;	  
}

sub get_all_ETRM_by_inx {
    my ($len,$inx) = (@_);
       	  
    my $bg_inx = $len+1;
    my $rma = get_TRMA_by_inx($len,$bg_inx);

    for(my $i=$bg_inx; $i<=$inx; $i++){	  
        my $rma = get_TRMA_by_inx($len,$i-1) + ($rma - get_TRMA_by_inx($len,$i))/$len;

       $FINANCE::ATR::table{$len}{$i} = {
                 ATR => $rma,
       };   
   } 	
}

sub run_all{
   my ($self,$len) = (@_);

   my $ed_inx = $FINANCE::ATR::util->get_end_inx();

   get_all_ETRM_by_inx($len,$ed_inx); 
}

sub get_ETRM_by_inx{
    my ($len,$inx) = (@_);
 
#   printf Dumper(\%FINANCE::ATR::table); 
   return $FINANCE::ATR::table{$len}{$inx};
}

sub get_ATR {
	my ($self,$len,$time) = (@_);
	
	my $inx = $FINANCE::ATR::util->get_inx_by_time($time);
	   
	my $atr = get_ETRM_by_inx($len,$inx);
	
  return $atr;  
}


1;
