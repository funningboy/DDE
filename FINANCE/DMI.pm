#!/usr/bin/perl -W

# Ref DMI 
# http://www.funddj.com/kmdj/wiki/wikiviewer.aspx?keyid=6025aa7c-7df6-4da0-9703-0ce6a7ff562c

package FINANCE::DMI;
use FINANCE::HISTORY_INFO;
use FINANCE::UTIL;
use Data::Dumper;
use strict;
use Switch

$FINANCE::DMI::util;
%FINANCE::DMI::table;

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

$FINANCE::DMI::util = FINANCE::UTIL->new($hslist);
%FINANCE::DMI::table = ();
  
return bless {};	
}


sub get_DM_by_inx{
       my ($inx) = (@_); 
       
       my $hg_diff = $FINANCE::DMI::util->get_hg_pric_by_inx($inx) - $FINANCE::DMI::util->get_hg_pric_by_inx($inx-1);  
       my $lw_diff = $FINANCE::DMI::util->get_lw_pric_by_inx($inx) - $FINANCE::DMI::util->get_lw_pric_by_inx($inx-1);

       my ($pos_DM,$neg_DM) =0;
         
           # define the postive DMI        	  
           if( ($hg_diff>0) && ($hg_diff>$lw_diff) ){ $pos_DM=$hg_diff; $neg_DM=0; }
    
           # define the negative DMI
        elsif( ($lw_diff>0) && ($hg_diff<$lw_diff) ){ $neg_DM=$lw_diff; $pos_DM=0; }
      	
       my %DMHs = ();  
          %DMHs = (
	         "POS" => $pos_DM,
	         "NEG" => $neg_DM,
	         ); 
     
     return \%DMHs;    	   
}


sub get_TR_by_inx {
	   my ($inx) = (@_);
        
           my (@tr) =[];
           
	         #H_[t] - L_[t]
	          push(@tr, abs($FINANCE::DMI::util->get_hg_pric_by_inx($inx) - $FINANCE::DMI::util->get_lw_pric_by_inx($inx)));  
	         #H_[t] - C_[t-1]
	          push(@tr, abs($FINANCE::DMI::util->get_hg_pric_by_inx($inx) - $FINANCE::DMI::util->get_cl_pric_by_inx($inx-1)));	
	         #L_[t] - C_[t-1]  
	          push(@tr, abs($FINANCE::DMI::util->get_lw_pric_by_inx($inx) - $FINANCE::DMI::util->get_cl_pric_by_inx($inx-1)));	
	          
	          @tr = reverse sort {$a<=>$b} @tr;
	          
	   return $tr[0];
}


sub get_all_DMI_by_inx {
	   my ($len,$inx) = (@_);
	   
	   my  $bg_inx = $len;
	   
     my ($pos_dm,$neg_dm,$tr) = 0;  

         for(my $i= $bg_inx; $i<=$inx; $i++){
	     my $cur_dm = get_DM_by_inx($i);      
	     my %cur_dm = %{$cur_dm};
	     	
	     $pos_dm += $cur_dm{POS};
	     $neg_dm += $cur_dm{NEG};
	     $tr      += get_TR_by_inx($i);
      }
	   
	      $tr     = ($len!=0)? $tr/$len           : 0; 
	   my $pos_di = ($len!=0)? $pos_dm/($len*$tr) : 0; 
	   my $neg_di = ($len!=0)? $neg_dm/($len*$tr) : 0;
	   my $dx     = abs($pos_di -$neg_di)/($pos_di+$neg_di);
	    
      my  %DIHs =();  
	    my  %DIHs= (
             	       "POS_DI" => $pos_di,
                     "NEG_DI" => $neg_di,
	           ); 
	      
    return \%DIHs;
}

sub run_all{
    my ($self,$len) = (@_);
    
    my $ed_inx = $FINANCE::DMI::util->get_end_inx();

    get_all_DMI_by_inx($len,$ed_inx);
}

sub get_DMI {
  my ($self,$fast,$slow,$time) = (@_);

  my $inx = $FINANCE::DMI::util->get_inx_by_time($time);
	
	my $dmi_fast = get_DMI_by_inx($fast,$inx);
	my $dmi_slow = get_DMI_by_inx($slow,$inx);
	
	    my  %DMIHs =();  
	    my  %DMIHs= (
             	       "DMI_FAST" => $dmi_fast,
                     "DMI_SLOW" => $dmi_slow,
	           ); 
	      
    return \%DMIHs;
}
1;
