#!/usr/bin/perl -W


package NET::Trader4BuySellDetail;

use LWP::UserAgent;
use SYS::Time;
use Switch;
use Data::Dumper;
use strict;
use Class::Struct;
use File::Path qw(make_path remove_tree);
#use utf8;
#use encoding 'big5', STDIN => 'big5', STDOUT => 'big5';

# ex:
# http://justdata.yuanta.com.tw/z/zg/zgb/zgb0_5650_5.djhtm

$NET::Trader4BuySellDetail::Web_tail =".djhtm";
$NET::Trader4BuySellDetail::Web_head ="http://justdata.yuanta.com.tw/z/zg/zgb/zgb0_";

struct TRADER => [
        STID  => '$',
        STNMME=> '$',
        BYCOT => '$',
        SLCOT => '$',
        TOCOT => '$',
];

%NET::Trader4BuySellDetail::Hashtable;
%NET::Trader4BuySellDetail::trader;

sub get_help{
  my ($case,@in) = (@_);
 
  switch($case){
    case "get_input_info" { printf("\n"); }

  }
}

sub new {
my ($self,$trader) = (@_);

%NET::Trader4BuySellDetail::Hashtable =();

if( !keys %{$trader} ){ get_help("get_input_info"); }

%NET::Trader4BuySellDetail::trader = %{$trader};

check_path_exists($trader);

return bless {};	
}


sub get_exp_sys_time {
    my $time = SYS::Time->new();
    my $sys_time = $time->get_system_time();
    my ($year,$mon,$mday) = split("\/",$sys_time);

    return $year."_".$mon."_".$mday;
}

sub check_path_exists{
    my ($trader) = (@_);
    my %trader = %{$trader};
   
    foreach my $id ( sort keys %{$trader{LIST}} ){
     foreach my $i ( sort keys %{$trader{LIST}{$id}} ){
       foreach my $day ( @{$trader{DAY}} ){ 
         foreach my $pos ( @{$trader{POSIT}} ){
           my @path_arr = @{$trader{LIST}{$id}{$i}};
           my $path = $path_arr[1].$pos."_".$day;
           if(!-e $path){ make_path($path); }
       }
      }
    }
  }
}

sub get_html_info{
      my ($HTMLPtr,$id,$day) = (@_);
      
      my ($MyCot,$MyCot2) =(0,0);
      my ($MyCase,$MyStockID,$MyStockNm,$MyBuyCot,$MySellCot,$MyTotCot,$MyTmpPtr)={};
      my $MyRank =2;
      
      my @MyTmpArrPtr = split("\n",$HTMLPtr);

      foreach(@MyTmpArrPtr){
        s/\,//g;
      	if(/\<TD class=\"[t41n3]*\" nowrap\>\<a href=\"javascript\:Link2Stk\(\'(\S+)\'\)\;\"\>(\S+)\<\/a\>\<\/TD\>/){
            $MyStockID =$1;
            $MyStockNm =$2;
            $MyStockNm =~ s/[0-9]*//g;
             
            if( ($MyCot % 2)==0 ){ $MyCase="buy"; }    # keep the saem @ SYS::GLB  market_trader->POSIT->buy define 
            else{                  $MyCase="sell"; }   # keep the saem @ SYS::GLB  market_trader->POSIT->sell define
            
          $MyCot ++;		
      } elsif(/\<TD class=\"[t41n3]*\"\>(\S+)\<\/TD\>/){  $MyTmpPtr =$1; ++$MyCot2;  }
           if($MyCot2==1){ $MyBuyCot =$MyTmpPtr; }
        elsif($MyCot2==2){ $MySellCot=$MyTmpPtr; }
        elsif($MyCot2==3){ $MyTotCot =$MyTmpPtr; 

                my $trader = TRADER->new(
       		         STID  => $MyStockID,
        		 STNAME=> $MyStockNm,
        		 BYCOT => $MyBuyCot,
        		 SLCOT => $MySellCot,
        		 TOCOT => $MyTotCot,
                  );
        
                $NET::Trader4BuySellDetail::Hashtable{$id}{$day}{$MyCase}{int($MyRank/2)} = $trader; 

        	$MyRank++;
        	$MyCot2=0;
        }
      }

}

sub get_path_decoder{
    my ($iid,$case,$day) =(@_);
 
    foreach my $id (sort keys %{$NET::Trader4BuySellDetail::trader{LIST}} ){
      foreach my $i (sort keys %{$NET::Trader4BuySellDetail::trader{LIST}{$id}} ){
       my @arr = @{$NET::Trader4BuySellDetail::trader{LIST}{$id}{$i}};
     
        if( $arr[0] == $iid){
           return $arr[1].$case."_".$day."\/";
          }
      }
   }
}

sub exp_market_trader_data{
	  my ($self) = (@_);
	  
	  my $time = get_exp_sys_time();
	  my $path = {};
  
	  foreach my $id ( sort keys %NET::Trader4BuySellDetail::Hashtable ){
           foreach my $day ( sort keys %{$NET::Trader4BuySellDetail::Hashtable{$id}} ){
             foreach my $case ( sort keys %{$NET::Trader4BuySellDetail::Hashtable{$id}{$day}} ){

             $path  = get_path_decoder($id,$case,$day);

             my $path1 = $path.$time.".csv";
             open(ofile, ">$path1" ) or die "open export $path error...\n";

              foreach my $i  ( sort {$a<=>$b} keys %{$NET::Trader4BuySellDetail::Hashtable{$id}{$day}{$case}} ){
                my $trader = TRADER->new(); 
	  	   $trader = $NET::Trader4BuySellDetail::Hashtable{$id}{$day}{$case}{$i};
	  	printf ofile $i.",".
                             $trader->STID.",".
                            # $trader->STNAME.",".
                             $trader->BYCOT.",".
                             $trader->SLCOT.",".
                             $trader->TOCOT."\n";
	      }
             close(ofile);	
          }
       }
    }
}



sub get_trader_info{
  my ($id,$day) = (@_);
  
  my $ua = LWP::UserAgent->new;
     $ua->agent("MyApp/0.1");
  
  my $web_info = $NET::Trader4BuySellDetail::Web_head.$id."_".$day.$NET::Trader4BuySellDetail::Web_tail;
 # print $web_info."\n";
  my $req = HTTP::Request->new(GET => $web_info);
  #$req->content_type('application/x-www-form-urlencoded');
  #$req->content('query=libwww-perl&mode=dist');

  # Pass request to the user agent and get a response back
  my $res = $ua->request($req);

  # Check the outcome of the response
  if ($res->is_success) {
       my $HTMLPtr = $res->content;
       get_html_info($HTMLPtr,$id,$day);       

 } else {
      print $res->status_line, "\n";
  }	
  
}

sub get_market_trader_data{
   my ($self) = (@_);

   foreach my $id (sort keys %{$NET::Trader4BuySellDetail::trader{LIST}} ){
     foreach my $i ( sort keys %{$NET::Trader4BuySellDetail::trader{LIST}{$id}} ){
       foreach my $day (@{$NET::Trader4BuySellDetail::trader{DAY}} ){
         my @path_arr = @{$NET::Trader4BuySellDetail::trader{LIST}{$id}{$i}};
           get_trader_info($path_arr[0],$day);
        }
      }
     }  
#printf Dumper(\%NET::Trader4BuySellDetail::Hashtable);
}


1;
