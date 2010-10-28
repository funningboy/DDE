#!/usr/bin/perl 


package TRADER::UTIL;
use SYS::GLB;
use SYS::Time;
use Data::Dumper;
use strict;
use Switch;
use Class::Struct;

%TRADER::UTIL::SuperHsTable;
%TRADER::UTIL::TraderHsTable;
$TRADER::UTIL::SYS_GLB;
$TRADER::UTIL::SYS_Time;

struct MARKET => [
        STID   => '$', 
        STNAME => '$', 
        CLOSE  => '$', 
        DIFF   => '$', 
        DIFFPER=> '$', 
        COUNT  => '$', 
];

struct TRADER => [
        STID  => '$',
        STNMME=> '$',
        BYCOT => '$',
        SLCOT => '$',
        TOCOT => '$',
];

struct STOCK => [

];

sub new{
my ($self) = (@_);

%TRADER::UTIL::SuperHsTable  =();
%TRADER::UTIL::TraderHsTable =();

#$TRADER::UTIL::SYS_GLB  = SYS::GLB->new();
#$TRADER::UTIL::SYS_Time = SYS::Time->new();

return bless {};        
}

sub get_help{
  my ($case,@in) = (@_);

  switch($case){
    case "get_super_info" { printf("please check the SYS::GLB @ get_market_super_hstable return ok\n");  }
    case "get_trader_info"{ printf("please check the SYS::GLB @ get_market_trader_hstable return ok\n"); }
    case "get_path_info"  { printf("please check the path already exist @ $in[0]\n");                    }
  }
die;
}

sub set_market_super_hstable{
   my ($self,$super) = (@_);

   if( !keys %{$super} ){ get_help("get_super_info"); }

   %TRADER::UTIL::SuperHsTable = %{$super};
}

sub set_market_trader_hstable{
   my ($self,$trader) = (@_);

   if( !keys %{$trader} ){ get_help("get_trader_info"); }
 
   %TRADER::UTIL::TraderHsTable = %{$trader};
} 

sub get_exp_sys_time {
    my $time = SYS::Time->new();
    my $sys_time = $time->get_system_time();
    my ($year,$mon,$mday) = split("\/",$sys_time);

    return $year."_".$mon."_".$mday;
}

sub get_exp_time {
    my ($time) = (@_); 

    my ($year,$mon,$mday) = split("\/",$time);
    return $year."_".$mon."_".$mday;
}

sub get_market_super_path_dec{
    my ($name,$typ,$day,$time) = (@_);
   
    my $key = $name."_".$typ."_".$day;

    if( !defined($TRADER::UTIL::SuperHsTable{expf}{$key}) ){ get_help("get_super_info",($key)); }
      my $path  = $TRADER::UTIL::SuperHsTable{expf}{$key};
      my $etime = get_exp_time($time);
       
         $path = $path.$etime.".csv";  
    if( !-e $path ){ get_help("get_path_info",($path)); }

   return $path;
}

sub get_market_trader_path_dec{
    my ($name,$id,$posit,$day,$time) = (@_);
    
    my $path; 
    my $etime = get_exp_time($time);
 
    foreach my $iid (sort keys  %{$TRADER::UTIL::TraderHsTable{LIST}{$name}} ){
           my @arr =  @{$TRADER::UTIL::TraderHsTable{LIST}{$name}{$iid}};

           if($arr[0] == $id){
              $path = $arr[1].$posit."_".$day."\/".$etime.".csv";
              if( !-e $path ){ get_help("get_path_info",($path)); }
            
              return $path;
          }
    }

 get_help("get_trader_info",($path)); 
}

sub call_back_market_super_file{
    my ($path) = (@_);

    open (ifile,"$path") or die "open $path error\n";
 
    my $rec   =0;
    my %super =();

   while(<ifile>){
     chomp;
     my ($MyStockID,$MuStockNm,$MyClose,$MyDiff,$MyDiffPer,$MyTicketCot)= split("\,",$_);
    
     my $market = MARKET->new(
                      STID   => $MyStockID,
                      STNAME => $MuStockNm,
                      CLOSE  => $MyClose,
                      DIFF   => $MyDiff,
                      DIFFPER=> $MyDiffPer,
                      COUNT  => $MyTicketCot,
       );

      $super{$rec} = $market; 
      $rec++;
   }

close(ifile);
return \%super;
}

sub call_back_market_trader_file{
    my ($path) = (@_);

    open (ifile,"$path") or die "open $path error\n";
 
    my $rec    =0;
    my %trader =();

   while(<ifile>){
     chomp;
     my ($MyRec,$MyStockID,$MyBuyCot,$MySellCot,$MyTotCot)= split("\,",$_);
    
     my $trader = TRADER->new(
                      STID   => $MyStockID,
                    #  STNAME => $MyStockNm,
                      BYCOT  => $MyBuyCot,
                      SLCOT  => $MySellCot,
                      TOCOT  => $MyTotCot,
       );

      $trader{$rec} = $trader; 
      $rec++;
   }

close(ifile);
return \%trader;
}

sub get_bk_external_super_buy_hstable{
   my ($self,$day,$time) = (@_);

   my $path  = get_market_super_path_dec("external","buyer",$day,$time);
   my $super = call_back_market_super_file($path);

return $super; 
}

sub get_bk_external_super_sell_hstable{
   my ($self,$day,$time) = (@_);

   my $path  = get_market_super_path_dec("external","seller",$day,$time);
   my $super = call_back_market_super_file($path);

return $super; 
}

sub get_bk_internal_super_buy_hstable{
   my ($self,$day,$time) = (@_);

   my $path  = get_market_super_path_dec("internal","buyer",$day,$time);
   my $super = call_back_market_super_file($path);

return $super; 
}

sub get_bk_internal_super_sell_hstable{
   my ($self,$day,$time) = (@_);

   my $path  = get_market_super_path_dec("internal","seller",$day,$time);
   my $super = call_back_market_super_file($path);

return $super; 
}

sub get_bk_self_super_buy_hstable{
   my ($self,$day,$time) = (@_);

   my $path  = get_market_super_path_dec("self","buyer",$day,$time);
   my $super = call_back_market_super_file($path);

return $super; 
}

sub get_bk_self_super_sell_hstable{
   my ($self,$day,$time) = (@_);

   my $path  = get_market_super_path_dec("self","seller",$day,$time);
   my $super = call_back_market_super_file($path);

return $super; 
}

sub get_bk_main_super_buy_hstable{
   my ($self,$day,$time) = (@_);

   my $path  = get_market_super_path_dec("main","buyer",$day,$time);
   my $super = call_back_market_super_file($path);

return $super; 
}

sub get_bk_main_super_sell_hstable{
   my ($self,$day,$time) = (@_);

   my $path  = get_market_super_path_dec("main","seller",$day,$time);
   my $super = call_back_market_super_file($path);

return $super; 
}

sub get_bk_external_trader_buy_hstable{
    my ($self,$day,$time,$id) = (@_);

    my $path   = get_market_trader_path_dec("EXTERNAL",$id,'buy',$day,$time);
    my $trader = call_back_market_trader_file($path);

return $trader;
}

sub get_bk_external_trader_sell_hstable{
    my ($self,$day,$time,$id) = (@_);

    my $path   = get_market_trader_path_dec("EXTERNAL",$id,'sell',$day,$time);
    my $trader = call_back_market_trader_file($path);

return $trader;
}

sub get_bk_internal_trader_buy_hstable{
    my ($self,$day,$time,$id) = (@_);

    my $path   = get_market_trader_path_dec("INTERNAL",$id,'buy',$day,$time);
    my $trader = call_back_market_trader_file($path);

return $trader;
}

sub get_bk_internal_trader_sell_hstable{
    my ($self,$day,$time,$id) = (@_);

    my $path   = get_market_trader_path_dec("INTERNAL",$id,'sell',$day,$time);
    my $trader = call_back_market_trader_file($path);

return $trader;
}

#sub get_bk_finance_bill_hstable

1;
