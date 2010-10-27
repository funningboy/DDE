
#!/usr/bin/perl -w

package WinDLL;
use Win32::DDE::Client;
use Win32::DDE;
use Data::Dumper;
#use strict;

my %stockListHashPtr;
my %StockHashPtr;
my $Client;
my $DebugMode = 'false';

sub new {
   my $self = shift;
   
   return bless {};
}



sub WinDLLDDE{

my $self = shift;
my ($MySerNm,$MyHostNm) = (@_);

GetStockIdListFmLoc();
SetInitialDDELinkServer($MySerNm,$MyHostNm);

while(){

GetStockInfFmDDEServer();

if($DebugMode eq 'true') { DisplayStockHashPtr(); }

print localtime()."\n";

SetExportSrockInf2Loc();
SetReleaseMem();

 }
 
}

sub SetImPortStockInf2Loc{
	
	my ($StockIdPtr,$StockNmPtr,$StockTmPtr,$StockPrPtr,$StockHgPtr,$StockLwPtr,$StockVlPtr,$StockTotVlPtr);
	
	foreach( sort keys %StockHashPtr){
		 $StockIdPtr = $_;
		 foreach( sort keys %{$StockHashPtr{$StockIdPtr}} ){
		 	$StockTmPtr = $_;
		 	
		 	$StockNmPtr    = $StockHashPtr{$StockIdPtr}{$StockTmPtr}{"NAME"};
		 	$StockPrPtr    = $StockHashPtr{$StockIdPtr}{$StockTmPtr}{"PRICE"};
		    $StockHgPtr    = $StockHashPtr{$StockIdPtr}{$StockTmPtr}{"HIGH"};
		    $StockLwPtr    = $StockHashPtr{$StockIdPtr}{$StockTmPtr}{"LOW"};
		    $StockVlPtr    = $StockHashPtr{$StockIdPtr}{$StockTmPtr}{"VOL"};
		    $StockTotVlPtr = $StockHashPtr{$StockIdPtr}{$StockTmPtr}{"TOTVOL"};
		    print "$StockIdPtr,$StockNmPtr,$StockTmPtr,$StockPrPtr,$StockHgPtr,$StockLwPtr,$StockVlPtr,$StockTotVlPtr\n";
		 }
	}
}

sub SetExportSrockInf2Loc{
    
    my ($StockIdPtr,$StockNmPtr,$StockTmPtr,$StockPrPtr,$StockHgPtr,$StockLwPtr,$StockVlPtr,$StockTotVlPtr);
	my ($iStockListFile);
	
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
    $year += 1900;
	$mon  += 1;
	if($mon<10){  $mon="0".$mon;   }
	if($mday<10){ $mday="0".$mday; }
	
	my $MyTradeDate = $year."_".$mon."_".$mday;
  
	foreach( sort keys %StockHashPtr){
		 $StockIdPtr = $_;
		 
		 $iStockListFile = "../../data_on/$MyTradeDate/$StockIdPtr.csv";
		  	   
		 if (-e $iStockListFile) { open(iStockListPtr, ">>$iStockListFile") or die "$!\n"; }
         else{                     open(iStockListPtr, ">$iStockListFile") or die "$!\n";  }

		 foreach( sort keys %{$StockHashPtr{$StockIdPtr}} ){
		 	$StockTmPtr = $_;
		 	
		 	$StockNmPtr    = $StockHashPtr{$StockIdPtr}{$StockTmPtr}{"NAME"};
		 	$StockPrPtr    = $StockHashPtr{$StockIdPtr}{$StockTmPtr}{"PRICE"};
		    $StockHgPtr    = $StockHashPtr{$StockIdPtr}{$StockTmPtr}{"HIGH"};
		    $StockLwPtr    = $StockHashPtr{$StockIdPtr}{$StockTmPtr}{"LOW"};
		    $StockVlPtr    = $StockHashPtr{$StockIdPtr}{$StockTmPtr}{"VOL"};
		    $StockTotVlPtr = $StockHashPtr{$StockIdPtr}{$StockTmPtr}{"TOTVOL"};
		    printf iStockListPtr "$StockTmPtr,$StockPrPtr,$StockHgPtr,$StockLwPtr,$StockPrPtr,$StockVlPtr\n";
		 }
	}
}

sub SetReleaseMem{
	%StockHashPtr =();
}

sub SetInitialDDELinkServer{
	my ($MySerNm,$MyHostNm) = (@_);
	
    $Client = new Win32::DDE::Client ($MySerNm, $MyHostNm);
    die "Unable to initiate conversation" if $Client->Error;
}

sub SetCloseDDELinkServer{
	 $Client->Disconnect;
}

sub GetStockIdListFmLoc{
	my $iStockListFile = "../../StockList.csv";
    open(iStockListPtr, "$iStockListFile") or die "$!\n";

   while(<iStockListPtr>){
      chomp;	
      $StockListHashPtr{$_} = $_;
   }
}

sub GetStockInfFmDDEServer{
	
my ($StockId,$StockNm,$StockTm,$StockPr,$StockOp,$StockHg,$StockLw,$StockVl,$StockTotVl);
my ($StockNmPtr,$StockTmPtr,$StockPrPtr,$StockHgPtr,$StockLwPtr,$StockVlPtr,$StockTotVlPtr);

foreach( keys %StockListHashPtr){

$StockId = $_;
$StockNm = $StockId."-Name";
$StockTm = $StockId."-Time";
$StockPr = $StockId."-Price";
$StockHg = $StockId."-High";
$StockLw = $StockId."-Low";
$StockVl = $StockId."-Volume";
$StockTotVl = $StockId."-TotalVolume";

defined ($StockNmPtr   = $Client->Request ($StockNm))   ||  die "DDE request Name        failed";		
defined ($StockTmPtr   = $Client->Request ($StockTm))   ||  die "DDE request Time        failed";
defined ($StockPrPtr   = $Client->Request ($StockPr))   ||  die "DDE request Price       failed";
defined ($StockHgPtr   = $Client->Request ($StockHg))   ||  die "DDE request High        failed";
defined ($StockLwPtr   = $Client->Request ($StockLw))   ||  die "DDE request Low         failed";
defined ($StockVlPtr   = $Client->Request ($StockVl))   ||  die "DDE request Volume      failed";
defined ($StockTotVlPtr= $Client->Request ($StockTotVl))||  die "DDE request TotalVolume failed";

#print $StockNmPtr."\n";

$StockHashPtr{$StockId}{$StockTmPtr} = {
	         "NAME"    => $StockNmPtr,
 	         "PRICE"   => $StockPrPtr,
             "HIGH"	   => $StockHgPtr,
             "LOW"     => $StockLwPtr,
             "VOL"     => $StockVlPtr,
             "TOTVOL"  => $StockTotVlPtr,
};

$Client->Execute('');
sleep 1;
}

}

sub DisplayStockHashPtr{
	
my ($StockIdPtr,$StockNmPtr,$StockTmPtr,$StockPrPtr,$StockHgPtr,$StockLwPtr,$StockVlPtr,$StockTotVlPtr);
	
	foreach( sort keys %StockHashPtr){
		 $StockIdPtr = $_;
		 foreach( sort keys %{$StockHashPtr{$StockIdPtr}} ){
		 	$StockTmPtr = $_;
		 	
		 	$StockNmPtr    = $StockHashPtr{$StockIdPtr}{$StockTmPtr}{"NAME"};
		 	$StockPrPtr    = $StockHashPtr{$StockIdPtr}{$StockTmPtr}{"PRICE"};
		    $StockHgPtr    = $StockHashPtr{$StockIdPtr}{$StockTmPtr}{"HIGH"};
		    $StockLwPtr    = $StockHashPtr{$StockIdPtr}{$StockTmPtr}{"LOW"};
		    $StockVlPtr    = $StockHashPtr{$StockIdPtr}{$StockTmPtr}{"VOL"};
		    $StockTotVlPtr = $StockHashPtr{$StockIdPtr}{$StockTmPtr}{"TOTVOL"};
		    print "$StockIdPtr,$StockNmPtr,$StockTmPtr,$StockPrPtr,$StockHgPtr,$StockLwPtr,$StockVlPtr,$StockTotVlPtr\n";
		 }
	}
}
1;



