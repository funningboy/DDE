#!/usr/bin/perl -W

# Ref
# http://www.funddj.com/kmdj/wiki/wikiviewer.aspx?keyid=08c472a2-9da9-4de2-a904-834bf70a79ba
# http://www.funddj.com/KMDJ/wiki/wikiviewer.aspx?keyid=ea368946-3325-46b0-8c67-eead6baafec7

package FINANCE::SAR;
use FINANCE::HISTORY_INFO;
use FINANCE::UTIL;
use Data::Dumper;
use strict;
use Switch

$FINANCE::SAR::util;
$FINANCE::SAR::table;

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

$FINANCE::SAR::util  = FINANCE::UTIL->new($hslist);
%FINANCE::SAR::table = ();
   
return bless {};	
}


sub get_SAR_by_inx{
           my ($len,$inx) = (@_);

           return $FINANCE::SAR::table{$len}{$inx};
}

sub get_SAR {
	   my ($self,$len,$time) = (@_);

	   my $inx = $FINANCE::SAR::util->get_inx_by_time($time);

	   my $sar = get_SAR_by_inx($len,$inx);
	   
  return $sar;
}

sub get_trend_sar_by_inx{
           my ($len,$inx) = (@_);
   
           my $bg_inx = $inx - $len +1;

           my ($fact,$up_cot,$dn_cot,$sar) =0;
 
            #find the trend for up or down
	  for(my $i=$bg_inx; $i<=$inx; $i++){
	  	  $fact = $FINANCE::SAR::util->get_cl_pric_by_inx($i) - $FINANCE::SAR::util->get_cl_pric_by_inx($i-1);

	  	     if($fact >0){ $up_cot++; }
	  	  elsif($fact <0){ $dn_cot++; } 
	  } 
	     
          #the first SAR value
          if($up_cot>$dn_cot){ 
            $sar = "UP"; 	
         } else{
            $sar = "DN";
         }

  return $sar; 
}

sub get_all_SAR_by_inx{
	   my ($len,$inx) = (@_);
	
	   my $bg_inx = $len;

	   my $inc_fact =0.02;
           my ($fact,$up_cot,$dn_cot,$sar) = 0;

           my $fact = get_trend_sar_by_inx($len,$bg_inx);

           if($fact eq "UP"){
                 $sar = $FINANCE::SAR::util->get_bk_lowest_pric_by_inx($len,$inx);  $up_cot =1; $dn_cot =0;
           } else {  
                 $sar = $FINANCE::SAR::util->get_bk_highest_pric_by_inx($len,$inx); $up_cot =0; $dn_cot =1; 
           }
         
        #find Each SAR value 
        for(my $j=$bg_inx; $j<=$inx; $j++){
        
              if($up_cot > $dn_cot){ 
            	$sar += $inc_fact*($FINANCE::SAR::util->get_bk_highest_pric_by_inx($len,$j-1)-$sar); 
            	
            	if($FINANCE::SAR::util->get_hg_pric_by_inx($j) > $FINANCE::SAR::util->get_hg_pric_by_inx($j-1)) {
                   if($inc_fact>=0.2){ $inc_fact  =0.2;  }
                   else{               $inc_fact +=0.02; }
            	}
            	
            	if($sar > $FINANCE::SAR::util->get_cl_pric_by_inx($j)){
            		$up_cot   =0;
            		$dn_cot   =1;
            		$inc_fact =0.02;
            	} 
            }
            else{                    
            	$sar += $inc_fact*($sar-$FINANCE::SAR::util->get_bk_lowest_pric_by_inx($len,$j-1));  
               
                if($FINANCE::SAR::util->get_lw_pric_by_inx($j) < $FINANCE::SAR::util->get_lw_pric_by_inx($j-1)){
                      if($inc_fact>=0.2){ $inc_fact =0.2;    }
                    else{                 $inc_fact +=0.02;  }           	
                 }
                 
                 if($sar < $FINANCE::SAR::util->get_cl_pric_by_inx($j)){
                 	 $up_cot   =1;
                 	 $dn_cot   =0;
                 	 $inc_fact =0.02;
                 }
            }

             $FINANCE::SAR::table{$len}{$j} = {
                       SAR => $sar,
             };
        }
}


sub run_all {
   my ($self,$len) = (@_);
 
   my $ed_inx = $FINANCE::SAR::util->get_end_inx();

   get_all_SAR_by_inx($len,$ed_inx);

}

1;
