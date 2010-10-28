#!/usr/bin/perl -W

# Ref KD
# http://www.funddj.com/kmdj/wiki/wikiviewer.aspx?keyid=02e9d1fa-499f-4952-9f5b-e7cad942c97b

package FINANCE::KD;
use FINANCE::HISTORY_INFO;
use FINANCE::UTIL;
use Data::Dumper;
use strict;
use Switch

$FINANCE::KD::util;
%FINANCE::KD::table;

sub get_help {
   my ($case,@in) = (@_);
   switch($case){
      case "get_input_info" { printf("@ input hash table error                            \
                                   please check the %hash in new*( had already exist...
                                   in HISTORY_INFO.pm definition\n");                          }
   }

die;
}

sub new {
my ($self,$hslist) = (@_);

if( !keys %{$hslist}){ get_help("get_input_info"); }

$FINANCE::KD::util  = FINANCE::UTIL->new($hslist);
%FINANCE::KD::table = ();

return bless {};	
}

sub get_rsv_by_inx {
       my ($len,$inx) = (@_);

       my $higest_prc = $FINANCE::KD::util->get_bk_highest_pric_by_inx($len,$inx);
       my $lowest_prc = $FINANCE::KD::util->get_bk_lowest_pric_by_inx($len,$inx);
       my $rsv;

       if($higest_prc != $lowest_prc){ 
	      $rsv = ($FINANCE::KD::util->get_cl_pric_by_inx($inx) - $lowest_prc)/($higest_prc-$lowest_prc)*100; 
       }

    return $rsv;
}

sub get_all_KD_by_inx {
      my ($len,$inx) = (@_);
  
      my ($K,$D,$rsv) = (50,50,0);
	
      my $bg_inx = $len;
	    
     for( my $i=$bg_inx; $i<=$inx; $i++ ){
	     	$rsv = get_rsv_by_inx($len,$i);
	     	
	     	$K = 2/3*$K + 1/3*$rsv;
	     	$D = 2/3*$D + 1/3*$K;
 
                $FINANCE::KD::table{$len}{$i} = { 
                                     K => $K,
                                     D => $D,              
                   };
      } 

#print Dumper(\%FINANCE::KD::table);
}

sub run_all {
	   my ($self,$len) = (@_);
	
	   my $ed_inx = $FINANCE::KD::util->get_end_inx();
           
            get_all_KD_by_inx($len,$ed_inx);
}

sub get_KD_by_inx{
    my ($len,$inx) = (@_);

    return  $FINANCE::KD::table{$len}{$inx};
}

sub get_KD {
	   my ($self,$len,$time) = (@_);
	   
	   my $inx = $FINANCE::KD::util->get_inx_by_time($time);
	   
	   my $kd = get_KD_by_inx($len,$inx); 

return $kd;
}

1;
