#!/usr/bin/perl


package NET::Market;

use LWP::UserAgent;
use Data::Dumper;
use SYS::Time;
use strict;
use Class::Struct;
use Switch;
use File::Path qw(make_path remove_tree);

#use utf8;
#use encoding 'big5', STDIN => 'big5', STDOUT => 'big5';

# example Web connect inf
# http://justdata.yuanta.com.tw/z/zg/zg_FA_0_30.djhtm

# External 外資買賣超
$NET::Market::GbWebInfExternalBuyer  ="http://justdata.yuanta.com.tw/z/zg/zg_D_0_";
$NET::Market::GbWebInfExternalSeller ="http://justdata.yuanta.com.tw/z/zg/zg_DA_0_";
$NET::Market::GbWebInf =".djhtm";

# Internal 投信買賣超
$NET::Market::GbWebInfInternalBuyer  ="http://justdata.yuanta.com.tw/z/zg/zg_DD_0_";
$NET::Market::GbWebInfInternalSeller ="http://justdata.yuanta.com.tw/z/zg/zg_DE_0_";

# self 自營商買賣超
$NET::Market::GbWebInfSelfBuyer      ="http://justdata.yuanta.com.tw/z/zg/zg_DB_0_";
$NET::Market::GbWebInfSelfSeller     ="http://justdata.yuanta.com.tw/z/zg/zg_DC_0_";

#main 主力買賣超
$NET::Market::GbWebInfMainBuyer  ="http://justdata.yuanta.com.tw/z/zg/zg_F_0_";
$NET::Market::GbWebInfMainSeller ="http://justdata.yuanta.com.tw/z/zg/zg_FA_0_";

# http://justdata.yuanta.com.tw/z/zg/zgb/zgb0_5650_5.djhtm
$NET::Market::GbWebStTder ="http://justdata.yuanta.com.tw/z/zg/zgb/zgb0_";

struct MARKET => [
        STID   => '$', 
        STNAME => '$', 
        CLOSE  => '$', 
        DIFF   => '$', 
        DIFFPER=> '$', 
        COUNT  => '$', 
];

%NET::Market::HashTable;
%NET::Market::SuperTable;

sub get_help{
    my ($case,@in) = (@_);

    switch($case){
      case "name"          { printf("please check the hash table in \"name\"  key @ \"external\",\" internal\",\"self\",\"main\""); }
      case "posit"         { printf("please check the hash table in \"posit\" key @ \"buyer\",\"seller\"");                          }
      case "get_date_info" { printf("<E1> the system time not match trader data time error ...                  \
                                          please check the system time @ env or check the trader data in yuanta \
                                          system time @ $in[0],  yuanta time @ $in[1]\n");                                           }
      case "get_exp_info"  { printf("please check the hash table in expf @ day = $in[0], posit = $in[1], name = $in[2]\n");          } 
      case "get_int_info"  { printf("please check the exp decoder path is ok @ encoder = $in[0]\n"); }
      case "get_input_info"{ printf("please check the SYS::GLB @ get_maket_super_hstable fun return ok\n");                          }
   }
die;
}

sub new {
my ($self,$super) = (@_);

if( !keys %{$super} ){ get_help("get_input_info"); }

%NET::Market::SuperTable = %{$super};

%NET::Market::HashTable =();

return bless {};	
}




sub check_file_exists{
     my (%super) = (@_);
     
  #   printf Dumper(\%super);
      if( !-e $super{expf}{external_buyer_1} ){ make_path( $super{expf}{external_buyer_1} ); }
      if( !-e $super{expf}{internal_buyer_1} ){ make_path( $super{expf}{internal_buyer_1} ); }
      if( !-e $super{expf}{self_buyer_1} )    { make_path( $super{expf}{self_buyer_1} );     }
      if( !-e $super{expf}{main_buyer_1} )    { make_path( $super{expf}{main_buyer_1} );     }

      if( !-e $super{expf}{external_buyer_5} ){ make_path( $super{expf}{external_buyer_5} ); }
      if( !-e $super{expf}{internal_buyer_5} ){ make_path( $super{expf}{internal_buyer_5} ); }
      if( !-e $super{expf}{self_buyer_5} )    { make_path( $super{expf}{self_buyer_5} );     }
      if( !-e $super{expf}{main_buyer_5} )    { make_path( $super{expf}{main_buyer_5} );     }

      if( !-e $super{expf}{external_buyer_10} ){ make_path( $super{expf}{external_buyer_10} ); }
      if( !-e $super{expf}{internal_buyer_10} ){ make_path( $super{expf}{internal_buyer_10} ); }
      if( !-e $super{expf}{self_buyer_10} )    { make_path( $super{expf}{self_buyer_10} );     }
      if( !-e $super{expf}{main_buyer_10} )    { make_path( $super{expf}{main_buyer_10} );     }

      if( !-e $super{expf}{external_buyer_30} ){ make_path( $super{expf}{external_buyer_30} ); }
      if( !-e $super{expf}{internal_buyer_30} ){ make_path( $super{expf}{internal_buyer_30} ); }
      if( !-e $super{expf}{self_buyer_30} )    { make_path( $super{expf}{self_buyer_30} );     }
      if( !-e $super{expf}{main_buyer_30} )    { make_path( $super{expf}{main_buyer_30} );     }

      if( !-e $super{expf}{external_seller_1} ){ make_path( $super{expf}{external_seller_1} ); }
      if( !-e $super{expf}{internal_seller_1} ){ make_path( $super{expf}{internal_seller_1} ); }
      if( !-e $super{expf}{self_seller_1} )    { make_path( $super{expf}{self_seller_1} );     }
      if( !-e $super{expf}{main_seller_1} )    { make_path( $super{expf}{main_seller_1} );     }

      if( !-e $super{expf}{external_seller_5} ){ make_path( $super{expf}{external_seller_5} ); }
      if( !-e $super{expf}{internal_seller_5} ){ make_path( $super{expf}{internal_seller_5} ); }
      if( !-e $super{expf}{self_seller_5} )    { make_path( $super{expf}{self_seller_5} );     }
      if( !-e $super{expf}{main_seller_5} )    { make_path( $super{expf}{main_seller_5} );     }

      if( !-e $super{expf}{external_seller_10} ){ make_path( $super{expf}{external_seller_10} ); }
      if( !-e $super{expf}{internal_seller_10} ){ make_path( $super{expf}{internal_seller_10} ); }
      if( !-e $super{expf}{self_seller_10} )    { make_path( $super{expf}{self_seller_10} );     }
      if( !-e $super{expf}{main_seller_10} )    { make_path( $super{expf}{main_seller_10} );     }

      if( !-e $super{expf}{external_seller_30} ){ make_path( $super{expf}{external_seller_30} ); }
      if( !-e $super{expf}{internal_seller_30} ){ make_path( $super{expf}{internal_seller_30} ); }
      if( !-e $super{expf}{self_seller_30} )    { make_path( $super{expf}{self_seller_30} );     }
      if( !-e $super{expf}{main_seller_30} )    { make_path( $super{expf}{main_seller_30} );     }

}

sub exp_encoder_path{
   my ($day,$posit,$name) = (@_);
 
      if($day == 1 && $posit eq "buyer" && $name eq "external" ){return "external_buyer_1"; }
   elsif($day == 1 && $posit eq "buyer" && $name eq "internal" ){return "internal_buyer_1"; }
   elsif($day == 1 && $posit eq "buyer" && $name eq "self"     ){return "self_buyer_1";     }
   elsif($day == 1 && $posit eq "buyer" && $name eq "main"    ){return "main_buyer_1";     }

   elsif($day == 5 && $posit eq "buyer" && $name eq "external" ){return "external_buyer_5"; }
   elsif($day == 5 && $posit eq "buyer" && $name eq "internal" ){return "internal_buyer_5"; }
   elsif($day == 5 && $posit eq "buyer" && $name eq "self"     ){return "self_buyer_5";     }
   elsif($day == 5 && $posit eq "buyer" && $name eq "main"    ){return "main_buyer_5";     }

   elsif($day == 10 && $posit eq "buyer" && $name eq "external" ){return "external_buyer_10"; }
   elsif($day == 10 && $posit eq "buyer" && $name eq "internal" ){return "internal_buyer_10"; }
   elsif($day == 10 && $posit eq "buyer" && $name eq "self"     ){return "self_buyer_10";     }
   elsif($day == 10 && $posit eq "buyer" && $name eq "main"    ){return "main_buyer_10";     }

   elsif($day == 30 && $posit eq "buyer" && $name eq "external" ){return "external_buyer_30"; }
   elsif($day == 30 && $posit eq "buyer" && $name eq "internal" ){return "internal_buyer_30"; }
   elsif($day == 30 && $posit eq "buyer" && $name eq "self"     ){return "self_buyer_30";     }
   elsif($day == 30 && $posit eq "buyer" && $name eq "main"    ){return "main_buyer_30";     }

   elsif($day == 1 && $posit eq "seller" && $name eq "external" ){return "external_seller_1"; }
   elsif($day == 1 && $posit eq "seller" && $name eq "internal" ){return "internal_seller_1"; }
   elsif($day == 1 && $posit eq "seller" && $name eq "self"     ){return "self_seller_1";     }
   elsif($day == 1 && $posit eq "seller" && $name eq "main"    ){return "main_seller_1";     }

   elsif($day == 5 && $posit eq "seller" && $name eq "external" ){return "external_seller_5"; }
   elsif($day == 5 && $posit eq "seller" && $name eq "internal" ){return "internal_seller_5"; }
   elsif($day == 5 && $posit eq "seller" && $name eq "self"     ){return "self_seller_5";     }
   elsif($day == 5 && $posit eq "seller" && $name eq "main"    ){return "main_seller_5";     }

   elsif($day == 10 && $posit eq "seller" && $name eq "external" ){return "external_seller_10"; }
   elsif($day == 10 && $posit eq "seller" && $name eq "internal" ){return "internal_seller_10"; }
   elsif($day == 10 && $posit eq "seller" && $name eq "self"     ){return "self_seller_10";     }
   elsif($day == 10 && $posit eq "seller" && $name eq "main"    ){return "main_seller_10";     }

   elsif($day == 30 && $posit eq "seller" && $name eq "external" ){return "external_seller_30"; }
   elsif($day == 30 && $posit eq "seller" && $name eq "internal" ){return "internal_seller_30"; }
   elsif($day == 30 && $posit eq "seller" && $name eq "self"     ){return "self_seller_30";     }
   elsif($day == 30 && $posit eq "seller" && $name eq "main"    ){return "main_seller_30";     }

   else { get_help("get_exp_info",($day,$posit,$name)); } 
}

sub get_encoder_path{
     my ($encoder,%super) = (@_);
     if( !defined($super{expf}{$encoder}) ){ get_help("get_int_info",$encoder); } 
     return $super{expf}{$encoder};
}

sub exp_market_data{
     my ($self) = (@_);

     check_file_exists(%NET::Market::SuperTable);

     my $sys_time = get_exp_sys_time();
    #         printf Dumper(\%NET::Market::HashTable);
    #          die;
    my $market = MARKET->new();   
    
       foreach my $day ( @{$NET::Market::SuperTable{day}} ){
         foreach my $posit ( @{$NET::Market::SuperTable{posit}} ){
           foreach my $name ( @{$NET::Market::SuperTable{name}} ){
            my $encoder = exp_encoder_path($day,$posit,$name);
            my $path    = get_encoder_path($encoder,%NET::Market::SuperTable);
               $path    = $path.$sys_time.".csv";              
                    
              open( oFilePtr, ">$path") or die "$!\n";
              foreach my $rec (sort {$a<=>$b} keys %{$NET::Market::HashTable{$day}{$posit}{$name}} ){
                    $market = $NET::Market::HashTable{$day}{$posit}{$name}{$rec};
                    printf oFilePtr $market->STID.",".
                                    $market->STNAME.",".
                                    $market->CLOSE.",".
                                    $market->DIFF.",".
                                    $market->DIFFPER.",".
                                    $market->COUNT."\n";
        }
             close(oFilePtr);
      }
    }
  }
} 

sub get_market_super_buyer_seller_data{
      my ($self) = (@_);

      foreach my $day ( @{$NET::Market::SuperTable{day}} ){
         foreach my $posit ( @{$NET::Market::SuperTable{posit}} ){
           foreach my $name ( @{$NET::Market::SuperTable{name}} ){
            my $webinfo = get_web_decoder($day,$posit,$name);	
  	                  get_web_info($webinfo,$day,$posit,$name);
             }
           }
       }

#printf Dumper(\%NET::Market::HashTable);
}

sub get_exp_sys_time {
    my $time = SYS::Time->new();
    my $sys_time = $time->get_system_time();
    my ($year,$mon,$mday) = split("\/",$sys_time);

    return $year."_".$mon."_".$mday;
}

sub get_sys_time {

    my $time = SYS::Time->new();
    my $sys_time = $time->get_system_time();
    my ($year,$mon,$mday) = split("\/",$sys_time);

    return $mon."\/".$mday;   
}

sub get_web_decoder {
   my ($day,$posit,$name) = (@_);
   my ($WebInf) ={};
   
     if( $posit eq "buyer"){
        switch($name){
  	  case "external" { $WebInf = $NET::Market::GbWebInfExternalBuyer.$day.$NET::Market::GbWebInf; }
  	  case "internal" { $WebInf = $NET::Market::GbWebInfInternalBuyer.$day.$NET::Market::GbWebInf; }
  	  case "self"     { $WebInf = $NET::Market::GbWebInfSelfBuyer.    $day.$NET::Market::GbWebInf; }
  	  case "main"    { $WebInf = $NET::Market::GbWebInfMainBuyer.    $day.$NET::Market::GbWebInf; }
          else            { get_help("name",$name);   }
       } 
    }elsif($posit eq "seller"){
        switch($name){ 
          case "external" { $WebInf = $NET::Market::GbWebInfExternalSeller.$day.$NET::Market::GbWebInf; }
          case "internal" { $WebInf = $NET::Market::GbWebInfInternalSeller.$day.$NET::Market::GbWebInf; }
          case "self"     { $WebInf = $NET::Market::GbWebInfSelfSeller    .$day.$NET::Market::GbWebInf; }
          case "main"    { $WebInf = $NET::Market::GbWebInfMainSeller    .$day.$NET::Market::GbWebInf; }
          else            { get_help("name",$name);   } 
       }
  } else {                 get_help("posit",$posit); } 

return $WebInf;
}

sub get_web_info {
  my ($WebInf,$day,$posit,$name) = (@_);
 
  # Create a user agent object
 my $ua = LWP::UserAgent->new;
    $ua->agent("MyApp/0.1");
  
  # Create a request
  my $req = HTTP::Request->new(GET => $WebInf);

  #$req->content_type('application/x-www-form-urlencoded');
  #$req->content('query=libwww-perl&mode=dist');

  # Pass request to the user agent and get a response back
  my $res = $ua->request($req);

  # Check the outcome of the response
  if ($res->is_success) {
       my $HTMLPtr = $res->content;
          ParseHtml2HashTable($HTMLPtr,$day,$posit,$name);
  }
  else {
      print $res->status_line, "\n";
  } 
}

sub get_sys_time {
   my $time = SYS::Time->new();
   my $sys_time = $time->get_system_time();
   my ($year,$mon,$mday) = split("\/",$sys_time);

   return $mon."\/".$mday; 
}

sub ParseHtml2HashTable{
    my ($HTMLPtr,$day,$posit,$name) = (@_);
    my $CDate = get_sys_time();
    my $Date;
 
     if($HTMLPtr=~ m/最後更新日: (\w+)\/(\w+)/){
    	 $Date = $1."\/".$2;
      }

#    unless($CDate eq $Date){ get_help("get_date_info",($CDate,$Date)); }
 
    my ($MyStockID,$MuStockNm,$MyCotID,$MyTmpPtr,$MyDiff,$MyDiffPer,$MyClose,$MyTicketCot,$MyRecord) ={};
   
    my @MyStPtr = split("\n",$HTMLPtr);
   
    $MyCotID =0;
    $MyRecord =1;

    foreach(@MyStPtr){
            s/\,//g;

         if(/GenLink2stk\(\'(\S+)\'\'(\S+)\'\)\;/)                        { $MyStockID=$1; $MuStockNm=$2; }
      elsif(/^\<td class=\"[a-z0-9]*\"\>[+]*\&[a-z]*\;(\S+)(\%)*\<\/td\>/){ $MyTmpPtr=$1; ++$MyCotID;     }


        if($MyCotID==1){ $MyClose     = $MyTmpPtr; }
     elsif($MyCotID==2){ $MyDiff      = $MyTmpPtr; }
     elsif($MyCotID==3){ $MyDiffPer   = $MyTmpPtr; }
     elsif($MyCotID==4){ $MyTicketCot = $MyTmpPtr; }
     elsif($MyCotID==5){ }
     elsif($MyCotID==6){ $MyTicketCot = $MyTmpPtr; }

    if( ($posit eq "buyer" && $MyCotID==4) ||
        ($posit eq "seller"&& $MyCotID==6) ){

        $MyStockID =~ s/AS//g;
        $MyStockID .=".TW";
 
        my $market = MARKET->new( 
                          STID   => $MyStockID,
                          STNAME => $MuStockNm,
                          CLOSE  => $MyClose,
                          DIFF   => $MyDiff,
                          DIFFPER=> $MyDiffPer,
                          COUNT  => $MyTicketCot,
                        );

        $NET::Market::HashTable{$day}{$posit}{$name}{$MyRecord} = $market;  
        $MyCotID=0;
        $MyRecord++; 
      }
    }
#    print Dumper(\%NET::Market::HashTable);
#    die; 
 }


1;
