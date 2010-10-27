#!/usr/bin/perl

#http://hk.finance.yahoo.com/q/hp?s=2330.TW&a=0&b=4&c=2000&d=11&e=1&f=2009&g=d&z=66&y=0

package NET::YahooDailyData;
use Data::Dumper;
use LWP::UserAgent;
use strict;
use Switch;

$NET::YahooDailyData::GbStockWebInf = "http://hk.finance.yahoo.com/q/hp?s=";
%NET::YahooDailyData::MyDyHashPtr   =();

sub get_help{
   my $case = (@_);

   switch($case) {
     case "get_date_info" { printf ("<E1> get the date time format error ...\
                                          please check the date time format \
                                          ex: 2010/01/01\n");                        }

   }
}

sub new {
my $self = shift;

return bless {};	
}

sub get_history_data{
  my ($self,$MyStockID,$MyStartTime,$MyEndTime) = (@_);

  if( $MyStartTime !~ /[0-9\/]/ || $MyEndTime !~ /[0-9\/]/ ){
     get_help("get_date_info");
     return -1;
  }
  
  my ($MyStYr,$MyStMn,$MyStDy) = split("\/",$MyStartTime);
  my ($MyEdYr,$MyEdMn,$MyEdDy) = split("\/",$MyEndTime);
  
  my ($MyWebInf,$MyHTMLPtr,$MyTlCot,$MyRange) = {};
  
  if($MyEdYr==$MyStYr){ $MyTlCot=int(($MyEdMn-$MyStMn+1)*31/66); }
  else{
  	   $MyTlCot = ((($MyEdMn+1)*31 + (12-$MyStMn+1)*31) + ($MyEdYr-$MyStYr-1)*365)/66;
  	   $MyTlCot = int($MyTlCot);
  }
  
  --$MyEdMn;
  --$MyStMn;
  	
# Create a user agent object
  my $ua = LWP::UserAgent->new;
     $ua->agent("MyApp/0.1");
  
  for(my $i=0; $i<=$MyTlCot; $i++){ 
   $MyRange = $i*66;
  
  $MyWebInf = $NET::YahooDailyData::GbStockWebInf.$MyStockID."&a=".$MyStMn."&b=".$MyStDy."&c=".$MyStYr."&d=".$MyEdMn."&e=".$MyEdDy."&f=".$MyEdYr."&g=d&z=66&y=".$MyRange;
  
  # Create a request
  my $req = HTTP::Request->new(GET => $MyWebInf);
  #$req->content_type('application/x-www-form-urlencoded');
  #$req->content('query=libwww-perl&mode=dist');

  # Pass request to the user agent and get a response back
  my $res = $ua->request($req);

  # Check the outcome of the response
  if ($res->is_success) {
       $MyHTMLPtr = $res->content;
       GetHTMLStockDailyData($MyHTMLPtr,$MyStockID);
  }
  else {
      print $res->status_line, "\n";
    }
  }
  
}

sub exp_history_data{
	
    my ($self,$MyStockID,$MyFile) = (@_);
	
    my ($MyOpen,$MyHigh,$MyLow,$MyClose,$MyVolume,$MyTime) ={};
	
    open(oFilePtr, ">$MyFile") or die "$!\n";
	
	foreach(sort keys %{$NET::YahooDailyData::MyDyHashPtr{$MyStockID}} ){
	 $MyTime = $_;
	 $MyOpen  = $NET::YahooDailyData::MyDyHashPtr{$MyStockID}{$MyTime}{"OPEN"};
	 $MyHigh  = $NET::YahooDailyData::MyDyHashPtr{$MyStockID}{$MyTime}{"HIGH"};
	 $MyLow   = $NET::YahooDailyData::MyDyHashPtr{$MyStockID}{$MyTime}{"LOW"};
	 $MyClose = $NET::YahooDailyData::MyDyHashPtr{$MyStockID}{$MyTime}{"CLOSE"};
	 $MyVolume= $NET::YahooDailyData::MyDyHashPtr{$MyStockID}{$MyTime}{"VOLUME"};

	 printf oFilePtr "$MyTime,$MyOpen,$MyHigh,$MyLow,$MyClose,$MyVolume\n";

	}
}

sub GetHTMLStockDailyData{
	my ($MyHTMLPtr,$MyStockID) = (@_);
	
	my (@MyStArrPtr,@MyStArrPtr2) = ();
	my ($MyTradeDate,$MyOpen,$MyHigh,$MyLow,$MyClose,$MyVolume,$MyAdjClose,$MyStatus) ={};
	
	@MyStArrPtr = split("\n",$MyHTMLPtr);
  
    foreach(@MyStArrPtr){
    	if(/^\s+\<\/td\>\<\/tr\>\<\/thead\>\<tbody\>\<tr\>/){
             s/^\s+\<\/td\>\<\/tr\>\<\/thead\>\<tbody\>\<tr\>//g;
             
             @MyStArrPtr2 = split("\<\/td\>",$_);
             
             foreach(@MyStArrPtr2){
               s/\<\/tr\>\<tr class=\"even\"\>//g;
               s/\<\/tr\>\<tr\>//g;
               s/\,//g;   
                  $MyStatus =0;
                  
                  if(/\<td class=\"c1\"\>(\S+)/){ $MyTradeDate =$1; }
               elsif(/\<td class=\"c2\"\>(\S+)/){ $MyOpen      =$1; }
               elsif(/\<td class=\"c3\"\>(\S+)/){ $MyHigh      =$1; }
               elsif(/\<td class=\"c4\"\>(\S+)/){ $MyLow       =$1; }
               elsif(/\<td class=\"c5\"\>(\S+)/){ $MyClose     =$1; }
               elsif(/\<td class=\"c6\"\>(\S+)/){ $MyVolume    =$1/1000; }
               elsif(/\<td class=\"c7\"\>(\S+)/){ $MyAdjClose  =$1; $MyStatus=1; }
               
               $MyTradeDate =~ s/\-/\//g;
            
               if($MyStatus==1 && $MyVolume!=0){
               	  $NET::YahooDailyData::MyDyHashPtr{$MyStockID}{$MyTradeDate} = {
               	  	 "OPEN"     => "$MyOpen",
               	  	 "HIGH"     => "$MyHigh",
               	  	 "LOW"      => "$MyLow",
               	  	 "CLOSE"    => "$MyClose",
               	  	 "VOLUME"   => "$MyVolume",
               	  	 "ADJCLOSE" => "$MyAdjClose",
               	  }
               }
             }
    		 
    	}
    }
	
}


sub TsFmLlTimeFm2YahooFm{
	  
	  my ($iMyMonth) = (@_);
	  my $MyMonth = ${$iMyMonth};
	  
	  my %MyMonthPtr =();
	  %MyMonthPtr = (
	             "Jan" => "0",
	             "Feb" => "1", 
	             "Mar" => "2",
	             "Apr" => "3",
	             "May" => "4",
	             "Jun" => "5", 
	             "Jul" => "6", 
	             "Aug" => "7", 
	             "Sep" => "8",
	             "Oct" => "9", 
	             "Nov" => "10",
	             "Dec" => "11" 
	             );
	             
	             
	     if( defined($MyMonthPtr{$MyMonth})) { return \$MyMonthPtr{$MyMonth}; }        
	     else{ print "<DD1> Daily Data Internal Month 2 Yahoo Error\n"; }
	                       	             
}

1;
