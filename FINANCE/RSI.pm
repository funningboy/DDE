#!/usr/bin/perl -W

# Ref
# http://www.funddj.com/kmdj/wiki/wikiViewer.aspx?keyid=0f9b61a6-605e-4b16-816a-f6b97c3dd11e

package FINANCE::RSI;
use FINANCE::HISTORY_INFO;
use FINANCE::UTIL;
use Data::Dumper;
use strict;
use Switch

$FINANCE::RSI::util;
$FINANCE::RSI::table;

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

$FINANCE::RSI::util  = FINANCE::UTIL->new($hslist);
%FINANCE::RSI::table = ();
   
return bless {};	
}


sub get_crsi_by_inx {
   my ($len,$inx) = (@_);
  
   my $bg_inx = $inx - $len +1;
  
   my ($up_sum,$dn_sum) = (0,0);
 
   for(my $i=$bg_inx; $i<=$inx; $i++){
	if($FINANCE::RSI::util->get_cl_pric_by_inx($i) >= $FINANCE::RSI::util->get_cl_pric_by_inx($i-1)) {
           $up_sum += $FINANCE::RSI::util->get_cl_pric_by_inx($i) - $FINANCE::RSI::util->get_cl_pric_by_inx($i-1);
	} else{
	   $dn_sum += $FINANCE::RSI::util->get_cl_pric_by_inx($i-1) - $FINANCE::RSI::util->get_cl_pric_by_inx($i);
	}
   }

  my $rsi = ($dn_sum!=0)? $up_sum/$dn_sum : 0;
  
  $rsi = ($rsi!=-1)? 100 - (100/(1+$rsi)) : 0;

 return $rsi; 	
}

sub get_all_RSI_by_inx {
        my ($len,$inx) = (@_);
 
        my $bg_inx = $len;
      
        my ($up_sum,$dn_sum,$rsi) = 0;

	for(my $i=$bg_inx; $i<=$inx; $i++){
            my $rsi = get_crsi_by_inx($len,$i);

             $FINANCE::RSI::table{$len}{$i} = {
                       RSI => $rsi,
           };
    }
}

sub run_all {
   my ($self,$len) = (@_);

   my $ed_inx = $FINANCE::RSI::util->get_end_inx();

   get_all_RSI_by_inx($len,$ed_inx);

}

sub get_RSI_by_inx {
    my ($len,$inx) = (@_);

    return $FINANCE::RSI::table{$len}{$inx};
}

sub get_RSI {
        my ($self,$len,$time) = (@_);

        my $inx = $FINANCE::RSI::util->get_inx_by_time($time); 

        my $rsi = get_RSI_by_inx($len,$inx);
   
   return $rsi;
}


1;
