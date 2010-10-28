#!/usr/bin/perl

#==================================================
#author: sean chen mail: funningboy@gmail.com
#publish 2010/10/27
#License: BSD
#==================================================

use SYS::GLB;

use FINANCE::HISTORY_INFO;
use FINANCE::UTIL;
use FINANCE::KD;
use FINANCE::BIAS;
use FINANCE::EMA;
#use FINANCE::DMI;
use FINANCE::MACD;
use FINANCE::MA;
use FINANCE::OBV;
use FINANCE::FIX_OBV;
use FINANCE::PSY;
use FINANCE::RSI;
use FINANCE::SAR;
use FINANCE::VR;
use FINANCE::WR;
use FINANCE::ATR;

use TRADER::UTIL;
use Data::Dumper;
use strict;

#==================================================
# trader or market info parts
#
#=================================================

my $global = SYS::GLB->new();
my $market_super_hstable  = $global->get_market_super_hstable;
my $market_trader_hstable = $global->get_market_trader_hstable;

my $trader = TRADER::UTIL->new();
   $trader->set_market_super_hstable($market_super_hstable);
   $trader->set_market_trader_hstable($market_trader_hstable);

my $rst = $trader->get_bk_external_super_buy_hstable('1','2010/10/26');
printf Dumper($rst);

   $rst = $trader->get_bk_main_super_sell_hstable('5','2010/10/27');
printf Dumper($rst);  

   $rst = $trader->get_bk_external_trader_buy_hstable('1','2010/10/27','1440');
printf Dumper($rst);

   $rst = $trader->get_bk_external_trader_sell_hstable('5','2010/10/27','1440');
printf Dumper($rst);

#=====================================================
# indicator parts
# 
#=====================================================
 
my $info   = FINANCE::HISTORY_INFO->new();
my $hslist = $info->get_file_info('./data_off/stock/2330.TW.csv');

my $ikd = FINANCE::KD->new($hslist);
          $ikd->run_all('9'); 
my $kd  = $ikd->get_KD('9','2010/08/12');
print Dumper($kd);

my $ibias = FINANCE::BIAS->new($hslist);
            $ibias->run_all('9');
my $bias  = $ibias->get_BIAS('9','2010/08/12');
printf Dumper($bias);

my $iema  = FINANCE::EMA->new($hslist);
            $iema->run_all('9');
my $ema   = $iema->get_EMA('9','2010/08/12');
printf Dumper($ema); 
#
#my $idmi = FINANCE::DMI->new($hslist);
#           $idmi->run_all('9');
#my $dmi  = $idmi->get_DMI('9','2010/08/12');
#printf Dumper($dmi);
#
my $imacd = FINANCE::MACD->new($hslist);
            $imacd->run_all('9');
my $macd  = $imacd->get_MACD('9','2010/08/12');
printf Dumper($macd);

my $ima   = FINANCE::MA->new($hslist);
            $ima->run_all('9');
my $ma    = $ima->get_MA('9','2010/08/12');
printf Dumper($ma);

my $iobv  = FINANCE::OBV->new($hslist);
            $iobv->run_all('1');
my $obv   = $iobv->get_OBV('1','2010/08/12');
printf Dumper($obv);

my $ifix_obv = FINANCE::FIX_OBV->new($hslist);
               $ifix_obv->run_all('1');
my $fix_obv  = $ifix_obv->get_FIX_OBV('1','2010/08/12');
printf Dumper($fix_obv);

my $ipsy  = FINANCE::PSY->new($hslist);
            $ipsy->run_all('9');
my $psy   = $ipsy->get_PSY('9','2010/08/12');
printf Dumper($psy);

my $irsi = FINANCE::RSI->new($hslist);
           $irsi->run_all('9');
my $rsi  = $irsi->get_RSI('9','2010/08/12');
printf Dumper($rsi);

my $isar = FINANCE::SAR->new($hslist);
           $isar->run_all('9'); 
my $sar  = $isar->get_SAR('9','2010/08/12');
printf Dumper($sar);

my $ivr = FINANCE::VR->new($hslist);
          $ivr->run_all('9');
my $vr  = $ivr->get_VR('9','2010/08/12');
printf Dumper($vr);

my $iwr = FINANCE::WR->new($hslist);
          $iwr->run_all('9');
my $wr  = $iwr->get_WR('9','2010/08/12');
printf Dumper($wr);

my $iatr = FINANCE::ATR->new($hslist);
           $iatr->run_all('9');
my $atr  = $iatr->get_ATR('9','2010/08/12');
printf Dumper($atr);
