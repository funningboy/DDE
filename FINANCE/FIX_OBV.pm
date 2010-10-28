#!/usr/bin/perl -W

#Ref
# http://www.funddj.com/kmdj/wiki/wikiviewer.aspx?keyid=f3aa847e-50ec-44d4-b675-6587a066ba9e

package FINANCE::FIX_OBV;
use FINANCE::HISTORY_INFO;
use FINANCE::UTIL;
use Data::Dumper;
use strict;
use Switch

$FINANCE::FIX_OBV::util;
%FINANCE::FIX_OBV::table;

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

$FINANCE::FIX_OBV::util  = FINANCE::UTIL->new($hslist);
%FINANCE::FIX_OBV::table = ();
   
return bless {};	
}

sub get_all_FIX_OBV_by_inx{
	   my ($len,$inx) = (@_);
	  
           my $bg_inx = $len; 	   
	    
           my $obv = $FINANCE::FIX_OBV::util->get_bk_avg_vol_by_inx($len,$bg_inx);
           my $fact;

	   for(my $i=$bg_inx; $i<=$inx; $i++){

 	        $fact = 0;
	         if ($FINANCE::FIX_OBV::util->get_hg_pric_by_inx($i) != $FINANCE::FIX_OBV::util->get_lw_pric_by_inx($i)   ){
	         $fact = ($FINANCE::FIX_OBV::util->get_cl_pric_by_inx($i) - $FINANCE::FIX_OBV::util->get_lw_pric_by_inx($i)) /
	                 ($FINANCE::FIX_OBV::util->get_hg_pric_by_inx($i) - $FINANCE::FIX_OBV::util->get_lw_pric_by_inx($i));	
	         }
	        
                my $dri = $FINANCE::OBV::util->get_cl_pric_by_inx($i) - $FINANCE::OBV::util->get_cl_pric_by_inx($i-1); 

	        if($dri >0 ){
                    $obv += $fact * $FINANCE::FIX_OBV::util->get_vol_by_inx($i);
                }elsif( $dri <0 ){
                    $obv -= $fact * $FINANCE::FIX_OBV::util->get_vol_by_inx($i);
                 }

                $FINANCE::FIX_OBV::table{$len}{$i} ={
                        FIX_OBV => $obv,
                   }; 
	 } 
}

sub run_all{
   my ($self,$len) = (@_);
 
   my $ed_inx = $FINANCE::FIX_OBV::util->get_end_inx(); 

   get_all_FIX_OBV_by_inx($len,$ed_inx);

}

sub get_FIX_OBV_by_inx{
   my ($len,$inx) = (@_);

  return $FINANCE::FIX_OBV::table{$len}{$inx};
} 

sub get_FIX_OBV{
  my ($self,$len,$time) = (@_);

  my $inx = $FINANCE::FIX_OBV::util->get_inx_by_time($time);

  my $fix_obv = get_FIX_OBV_by_inx($len,$inx);

return $fix_obv;
}


1;
