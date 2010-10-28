#!usr/bin/perl

#==================================================
#author: sean chen mail: funningboy@gmail.com
#publish 2010/10/27
#License: BSD
#==================================================

use SYS::GLB;
use NET::GoogleDailyData;
use NET::YahooDailyData;
use NET::TraderDetail;
use NET::Market;
use NET::Trader4BuySellDetail;
use NET::FINANCE_BILL;
use Data::Dumper;

#my $google = NET::GoogleDailyData->new();
#   $google->get_history_data('2330.TW','2010/01/01','2010/10/10');
#   $google->exp_history_data('2330.TW',"./data_off/stock/2330.TW.csv");
#
#my $google = NET::GoogleDailyData->new();
#   $google->get_history_data('2409.TW','2010/01/01','2010/10/10');
#   $google->exp_history_data('2409.TW',"./data_off/stock/2409.TW.csv");
#
#my $google = NET::GoogleDailyData->new();
#   $google->get_history_data('2317.TW','2010/01/01','2010/10/10');
#   $google->exp_history_data('2317.TW',"./data_off/stock/2317.TW.csv");
#

#my $yahoo  = NET::YahooDailyData->new();
#   $yahoo->get_history_data('2330.TW','2010/01/01','2010/10/15');
#   $yahoo->exp_history_data('2330.TW',"2330.TW.csv");

#my $trader = NET::TraderDetail->new();
#   $trader->get_trader_data();
#   $trader->exp_trader_data("2010_10_20_trader_detail.csv"); 

my  $fin_bill = NET::FINANCE_BILL->new();
    $fin_bill->get_fin_bill_data('2330.TW');
    $fin_bill->exp_fin_bill_data('2330.TW',"2330.TW.fin_bill.csv");
#===========================================
#  
# get super buy/sell[1,5,10,30] info from web
# get trader [1,5,30] info from web
#
#============================================
#my $global = SYS::GLB->new();
#my $market_super_hstable = $global->get_market_super_hstable;
##  printf Dumper($market_super_hstable);
#my $market = NET::Market->new($market_super_hstable);
#   $market->get_market_super_buyer_seller_data();
#   $market->exp_market_data();
#
#my $market_trader_hstable = $global->get_market_trader_hstable;
##printf Dumper($market_trader_hstable);
#my $td4bysel = NET::Trader4BuySellDetail->new($market_trader_hstable);
#   $td4bysel->get_market_trader_data();
#   $td4bysel->exp_market_trader_data();
#

#my $market_stock_hstable = $global->get_market_stock_hstable;
