#!/usr/bin/perl

#==================================================
#author: sean chen mail: funningboy@gmail.com
#publish 2010/10/27
#License: BSD
#
# 進場策略 
# 1. ( T[0]_K(9) cross over T[0]_D(9) ) && ( T[-1]_K(9) < T[0]_K(9) && T[-1]_D(9) < T[-1]_D(9)
#     當日 KD 交差 且 K(9) > D(9). 且 昨日 KD 必須小於 今日 KD
#
# 2. T[0]_MACD_DIF(12-26) > 0 && T[0]_MACD_DIFF(12-26) > T[1]_MACD_DIFF(12-26)
#     當日 MACD-DIFF > 0 且 必須大於昨日的 MACD-DIFF
#
# 3. 外資連續買超1日 
#   
#==================================================

use SYS::GLB;

use FINANCE::KD;
use FINANCE::MACD;

use TRADER::UTIL;
use Data::Dumper;
use strict;

my @stock_list =[ "2330.TW",
                  "2409.TW",
                  "2317.TW",
];

printf "dd";

my $global = SYS::GLB->new();
my $market_super_hstable  = $global->get_market_super_hstable;
my $market_trader_hstable = $global->get_market_trader_hstable;

my $trader = TRADER::UTIL->new();
   $trader->set_market_super_hstable($market_super_hstable);
   $trader->set_market_trader_hstable($market_trader_hstable);

my $rst = $trader->get_bk_external_super_buy_hstable('1','2010/10/27');


