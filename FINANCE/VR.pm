#!/usr/bin/perl

#Ref
#

package FINANCE::VR;
use FINANCE::HISTORY_INFO;
use FINANCE::UTIL;
use Data::Dumper;
use strict;
use Switch

$FINANCE::VR::util;
%FINANCE::VR::table;

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

$FINANCE::VR::util  = FINANCE::UTIL->new($hslist);
%FINANCE::VR::table = ();   

return bless {};	
}

sub get_VR_by_inx{
  my ($len,$inx) = (@_);

  return $FINANCE::VR::table{$len}{$inx};
}

sub get_VR{	
    my ($self,$len,$time) = (@_);

    my $inx = $FINANCE::VR::util->get_inx_by_time($time);

    my $vr = get_VR_by_inx($len,$inx);
    
    return $vr;
}

sub get_cvr_by_inx{
     my ($len,$inx) = (@_);

     my $bg_inx = $inx - $len +1;

     my ($up_vol,$dn_vol,$eq_vol,$vr) =0;
 
     for(my $i=$bg_inx; $i<=$inx; $i++){
    	   
    	   # define the up price day to volume
    	   if( $FINANCE::VR::util->get_cl_pric_by_inx($i) > $FINANCE::VR::util->get_op_pric_by_inx($i)){
    	   	   $up_vol += $FINANCE::VR::util->get_vol_by_inx($i);
    	   
    	   # define the down price day to volume
    	   } elsif( $FINANCE::VR::util->get_cl_pric_by_inx($i) < $FINANCE::VR::util->get_op_pric_by_inx($i) ){
    	   	   $dn_vol += $FINANCE::VR::util->get_vol_by_inx($i);
    	   
    	   # define the up eq down price to volumw
    	   } else {
    	   	   $eq_vol += $FINANCE::VR::util->get_vol_by_inx($i);
    	   }
    } 
         	
      	$vr = ($up_vol + $eq_vol/2)/($dn_vol + $eq_vol/2)*100;
      	
      	return $vr;
}

sub get_all_VR_by_inx{
      my ($len,$inx) = (@_);	
	
      my $bg_inx = $len;
      
    for(my $i=$bg_inx; $i<=$inx; $i++){
      my $vr = get_cvr_by_inx($len,$i);
 
      $FINANCE::VR::table{$len}{$i} = {
                VR => $vr,
     };
    }    	   
}

sub run_all{
       my ($self,$len) = (@_);	
	 
       my $ed_inx = $FINANCE::VR::util->get_end_inx();

       get_all_VR_by_inx($len,$ed_inx);
}


1;
