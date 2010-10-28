#!/usr/bin/perl

#==================================================
#author: sean chen mail: funningboy@gmail.com
#publish 2010/10/27
#License: BSD
#
# 進場策略 rules
# R1. ( T[0]_K(9) cross over T[0]_D(9) ) && ( T[-1]_K(9) < T[0]_K(9) && T[-1]_D(9) < T[-1]_D(9)
#     當日 KD 交差 且 K(9) > D(9). 且 昨日 KD 必須小於 今日 KD
#
# R2. T[0]_MACD_DIF(12-26) > 0 && T[0]_MACD_DIFF(12-26) > T[1]_MACD_DIFF(12-26)
#     當日 MACD-DIFF > 0 且 必須大於昨日的 MACD-DIFF
#
# R3. 外資連續買超1日 
#   
#==================================================

use SYS::GLB;

use FINANCE::KD;
use FINANCE::MACD;

use TRADER::UTIL;
use Data::Dumper;
use strict;

my $pre_time   = "2010/10/25";
my $cur_time   = "2010/10/26"; 

my %stock_list =( 
                   "STOCKID" => ["2330.TW",
                                 "2409.TW",
                                 "2317.TW",],
                   "PATH"    => ["./data_off/stock/2330.TW.csv",
                                 "./data_off/stock/2409.TW.csv",
                                 "./data_off/stock/2317.TW.csv",],
                   "KD"      => ["-1",
                                 "-1",
                                 "-1",],
                   "MACD"    => ["-1",
                                 "-1",
                                 "-1",],
                   "EXTERNAL"=> ["-1",
                                 "-1",
                                 "-1",],
);

#printf Dumper(\%stock_list);

my $global = SYS::GLB->new();
my $market_super_hstable  = $global->get_market_super_hstable;
my $market_trader_hstable = $global->get_market_trader_hstable;

my $trader = TRADER::UTIL->new();
   $trader->set_market_super_hstable($market_super_hstable);
   $trader->set_market_trader_hstable($market_trader_hstable);

#==========================================================
# step 1 get KD value && Check R1
#==========================================================
my @KD_Arr =();

foreach my $path ( @{$stock_list{PATH}} ){
  my $info   = FINANCE::HISTORY_INFO->new();
  my $hslist = $info->get_file_info($path);

  my $ikd = FINANCE::KD->new($hslist);
            $ikd->run_all('9');
 
  my $pre_kd  = $ikd->get_KD('9',$pre_time); my %pre_kd = %{$pre_kd};
  my $cur_kd  = $ikd->get_KD('9',$cur_time); my %cur_kd = %{$cur_kd};

#printf Dumper($pre_kd);
#printf Dumper($cur_kd);
  
     if( ($cur_kd{K} > $cur_kd{D} )&& 
         ($cur_kd{K} > $pre_kd{K} )&&
         ($cur_kd{D} > $pre_kd{D} )   ){
           push(@KD_Arr,1);
   } else{ push(@KD_Arr,-1); }

}

@{$stock_list{KD}} = @KD_Arr;

#==========================================================
# step 2 get MACD value && Check R2
#==========================================================
my @MACD_Arr =();

foreach my $path ( @{$stock_list{PATH}} ){
  my $info   = FINANCE::HISTORY_INFO->new();
  my $hslist = $info->get_file_info($path);

  my $imacd = FINANCE::MACD->new($hslist);
              $imacd->run_all('9');

  my $pre_macd  = $imacd->get_MACD('9',$pre_time); my %pre_macd = %{$pre_macd};
  my $cur_macd  = $imacd->get_MACD('9',$cur_time); my %cur_macd = %{$cur_macd};

#printf Dumper($pre_macd);
#printf Dumper($cur_macd);

     if( ($cur_macd{DIF} > 0 )&& 
         ($cur_macd{DIF} > $pre_macd{DIF} ) ){
           push(@MACD_Arr,1);
   } else{ push(@MACD_Arr,-1); }

}

@{$stock_list{MACD}} = @MACD_Arr;

#========================================
# step 3. get super buy info && check R3
#========================================
my @Super_Arr =();

my $super = $trader->get_bk_external_super_buy_hstable('1','2010/10/26'); my %super = %{$super};
#print Dumper($super);

foreach my $sid (@{$stock_list{STOCKID}} ){
  my $ch =0;
  foreach my $id (keys %super ){
     if( $super{$id}->STID eq $sid ){
         $ch =1;
     } 
  }

 if( $ch==1 ){ push(@Super_Arr,1);  }
 else{         push(@Super_Arr,-1); }
 }
     
@{$stock_list{EXTERNAL}} = @Super_Arr;

#=====================================
# Dumper results
#=====================================
printf Dumper(\%stock_list);


