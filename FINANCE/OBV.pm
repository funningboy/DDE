#!/usr/bin/perl -W

#Ref
# http://www.funddj.com/kmdj/wiki/wikiviewer.aspx?keyid=f3aa847e-50ec-44d4-b675-6587a066ba9e

package FINANCE::OBV;
use FINANCE::HISTORY_INFO;
use FINANCE::UTIL;
use Data::Dumper;
use strict;
use Switch

$FINANCE::OBV::util;
%FINANCE::OBV::table;

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

$FINANCE::OBV::util  = FINANCE::UTIL->new($hslist);
%FINANCE::OBV::table = ();
   
return bless {};	
}

sub get_all_OBV_by_inx{
	   my ($len,$inx)  = (@_);
	   
	   my $bg_inx = $len; 
	   
	   my $obv = $FINANCE::OBV::util->get_bk_avg_vol_by_inx($len,$bg_inx); 
	    
	    #update OBV value
	    for(my $i=$bg_inx; $i<=$inx; $i++){
	         
	       my $fact = $FINANCE::OBV::util->get_cl_pric_by_inx($i) - $FINANCE::OBV::util->get_cl_pric_by_inx($i-1);
	         
	        #update the OBV  
	        if($fact >0 ){
	        	$obv += $FINANCE::OBV::util->get_vol_by_inx($i); 
	       } elsif($fact <0 ){
	       	        $obv -= $FINANCE::OBV::util->get_vol_by_inx($i); 
	       }
               
              $FINANCE::OBV::table{$len}{$i} = {
                    OBV => $obv,
               };

	 }
}

sub run_all{
         my ($self,$len) = (@_);
         
         my $ed_inx = $FINANCE::OBV::util->get_end_inx();

         get_all_OBV_by_inx($len,$ed_inx);

}

sub get_OBV_by_inx {
         my ($len,$inx) = (@_);

# printf Dumper(\%FINANCE::OBV::table);        
return $FINANCE::OBV::table{$len}{$inx};
}

sub get_OBV{
	  my ($self,$len,$time) = (@_);
	 
          my $inx = $FINANCE::OBV::util->get_inx_by_time($time);

	  my $obv = get_OBV_by_inx($len,$inx);

 return $obv;
}

1;
