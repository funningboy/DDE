#!/usr/bin/perl -W

# Ref
#

package FINANCE::WR;
use FINANCE::HISTORY_INFO;
use FINANCE::UTIL;
use Data::Dumper;
use strict;
use Switch

$FINANCE::WR::util;
%FINANCE::WR::table;

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

$FINANCE::WR::util  = FINANCE::UTIL->new($hslist);
%FINANCE::WR::table =();
   
return bless {};	
}

sub get_WR_by_inx{
   my ($len,$inx) = (@_);

   return $FINANCE::WR::table{$len}{$inx};
}

sub get_WR{
        my ($self,$len,$time) = (@_);

        my $inx = $FINANCE::WR::util->get_inx_by_time($time);
	
	my $wr = get_WR_by_inx($len,$inx);
   
     return $wr;
}

sub get_all_WR_by_inx{
    my ($len,$inx) = (@_);
   
    my $bg_inx = $len;

    for(my $i=$bg_inx; $i<=$inx; $i++){	
        my $highest = $FINANCE::WR::util->get_bk_highest_pric_by_inx($len,$i);
        my $lowest  = $FINANCE::WR::util->get_bk_lowest_pric_by_inx($len,$i);
    
        my $wr = ($highest!=$lowest) ? 100 - ($highest - $FINANCE::WR::util->get_cl_pric_by_inx($inx))/($highest - $lowest)*100 : 0;     
    
       $FINANCE::WR::table{$len}{$i} = {
                 WR => $wr,      
        };
    }
}

sub run_all{
    my ($self,$len) = (@_);

    my $ed_inx = $FINANCE::WR::util->get_end_inx();
 
     get_all_WR_by_inx($len,$ed_inx);
}


1;
