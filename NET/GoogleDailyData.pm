#!/usr/bin/perl

package NET::GoogleDailyData;

use Data::Dumper;
use HTML::TableExtract;
use Switch;
use LWP::UserAgent;
use strict;

#http://www.google.com/finance/historical?q=TPE%3A2330&start=0&num=100
$NET::GoogleDailyData::GbStockWebInf = "http://www.google.com/finance/historical?q=";
%NET::GoogleDailyData::MyDyHashPtr   = ();

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
  
  my ($MyWebInf,$MyHTMLPtr,$MyTlCot,$MyRange) ={};
  
  if($MyEdYr==$MyStYr){ $MyTlCot=int(($MyEdMn-$MyStMn+1)*31/66); }
  else{
  	   $MyTlCot = ((($MyEdMn+1)*31 + (12-$MyStMn+1)*31) + ($MyEdYr-$MyStYr-1)*365)/66;
  	   $MyTlCot = int($MyTlCot);
  }
  
  --$MyEdMn;
  --$MyStMn;
  
  my $MyStockID2 = $MyStockID;
     $MyStockID2 =~ s/\.TW//g;	
# Create a user agent object
  my $ua = LWP::UserAgent->new;
     $ua->agent("MyApp/0.1");
  
  for(my $i=0; $i<=$MyTlCot; $i++){ 
   $MyRange = $i*66;

  $MyWebInf = $NET::GoogleDailyData::GbStockWebInf."TPE\%3A".$MyStockID2."\&start=$MyRange\&num=66";
  
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

sub GetHTMLStockDailyData{
	my ($MyHTMLPtr,$MyStockID) = (@_);
	
	my @MyStArrPtr = ();
	my ($MyTradeDate,$MyOpen,$MyHigh,$MyLow,$MyClose,$MyVolume) = {};
	
    my $te = HTML::TableExtract->new( headers => [qw(Date Open High Low Close Volume)] );
       $te->parse($MyHTMLPtr);

 # Examine all matching tables
 foreach my $ts ($te->tables) {
   #print "Table (", join(',', $ts->coords), "):\n";
   foreach my $row ($ts->rows) {
           my @MyStArrPtr = @{$row};
      
      ($MyTradeDate,$MyOpen,$MyHigh,$MyLow,$MyClose,$MyVolume) = (@MyStArrPtr);
       chop ($MyTradeDate,$MyOpen,$MyHigh,$MyLow,$MyClose,$MyVolume); 
       
       $MyVolume =~ s/\,//g;
       $MyVolume = int($MyVolume/1000);
       $MyTradeDate = GetDayInf2OurDataBased($MyTradeDate);
       
       unless($MyVolume==0){
       $NET::GoogleDailyData::MyDyHashPtr{$MyStockID}{$MyTradeDate} = {
               	  	 "OPEN"     => "$MyOpen",
               	  	 "HIGH"     => "$MyHigh",
               	  	 "LOW"      => "$MyLow",
               	  	 "CLOSE"    => "$MyClose",
               	  	 "VOLUME"   => "$MyVolume",
               	  };
        }
      }
    }
 
}

sub GetDayInf2OurDataBased{
	my ($MyStrPtr) = (@_);
       
       $MyStrPtr =~ s/\,//g;
       
    my ($MyMon,$MyDy,$MyYear) = split(" ",$MyStrPtr); 
       
    my %MyMonthPtr = (
	             "Jan" => "01",
	             "Feb" => "02", 
	             "Mar" => "03",
	             "Apr" => "04",
	             "May" => "05",
	             "Jun" => "06", 
	             "Jul" => "07", 
	             "Aug" => "08", 
	             "Sep" => "09",
	             "Oct" => "10", 
	             "Nov" => "11",
	             "Dec" => "12", 
	             );
    
    if(defined($MyMonthPtr{$MyMon})){ $MyMon=$MyMonthPtr{$MyMon}; }
    if($MyDy<10){ $MyDy="0".$MyDy; }
    
    my $MyTradeDate = $MyYear."/".$MyMon."/".$MyDy;
    return $MyTradeDate;
}

sub exp_history_data{
	my ($self,$MyStockID,$MyFile) = (@_);

	my ($MyOpen,$MyHigh,$MyLow,$MyClose,$MyVolume,$MyTime)={};
	
        open(oFilePtr, ">$MyFile") or die "$!\n";
	
	foreach(sort keys %{$NET::GoogleDailyData::MyDyHashPtr{$MyStockID}} ){
	 $MyTime = $_;
	 $MyOpen  = $NET::GoogleDailyData::MyDyHashPtr{$MyStockID}{$MyTime}{"OPEN"};
	 $MyHigh  = $NET::GoogleDailyData::MyDyHashPtr{$MyStockID}{$MyTime}{"HIGH"};
	 $MyLow   = $NET::GoogleDailyData::MyDyHashPtr{$MyStockID}{$MyTime}{"LOW"};
	 $MyClose = $NET::GoogleDailyData::MyDyHashPtr{$MyStockID}{$MyTime}{"CLOSE"};
	 $MyVolume= $NET::GoogleDailyData::MyDyHashPtr{$MyStockID}{$MyTime}{"VOLUME"};
	 
	 printf oFilePtr "$MyTime,$MyOpen,$MyHigh,$MyLow,$MyClose,$MyVolume\n";
	 
	}
}

1;
