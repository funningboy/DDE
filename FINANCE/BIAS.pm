#!/usr/bin/perl -W

# Ref
# http://www.funddj.com/kmdj/wiki/wikiviewer.aspx?keyid=c100882c-66e3-4708-9e38-c6dc24b024a5

package FINANCE::BIAS;
use FINANCE::HISTORY_INFO;
use FINANCE::UTIL;
use Data::Dumper;
use strict;
use Switch

$FINANCE::BIAS::util;
%FINANCE::BIAS::table;

sub get_help{
   my ($case,@in) = (@_);
   switch($case){
      case "get_input_info" { printf("@ input hash table error                            \
                                   please check the %hash in new*( had already exist...
                                   in HISTORY_INFO.pm definition \n");                         }
   }

die;
}

sub new {
my ($self,$hslist) = (@_);

if( !keys %{$hslist}){ get_help("get_input_info"); }

$FINANCE::BIAS::util = FINANCE::UTIL->new($hslist);
%FINANCE::BIAS::table = ();
 
return bless {};	
}

sub get_all_BIAS_by_inx{
           my ($len,$inx) = (@_);
 
           my $bg_inx = $len;

           for(my $i=$bg_inx; $i<=$inx; $i++ ){
	      my $avg_close = $FINANCE::BIAS::util->get_bk_avg_close_pric_by_inx($len,$i);	   
	      my $bias = ($avg_close!=0)? ($FINANCE::BIAS::util->get_cl_pric_by_inx($i) - $avg_close)/$avg_close : 0;
                 $bias *= 100;

              $FINANCE::BIAS::table{$len}{$i} = {
                                 BIAS => $bias,
                 };
         }
}

sub run_all {
     my ($self,$len) =(@_);
  
     my $ed_inx = $FINANCE::BIAS::util->get_end_inx();

     get_all_BIAS_by_inx($len,$ed_inx);
}

sub get_BIAS{
    my ($self,$len,$time) = (@_);
    
    my $inx  = $FINANCE::BIAS::util->get_inx_by_time($time); 
    my $bias = get_BIAS_by_inx($len,$inx);
	   
   return $bias;
}

sub get_BIAS_by_inx{
	 my ($len,$inx) = (@_); 
	 return  $FINANCE::BIAS::table{$len}{$inx};
}


1;
