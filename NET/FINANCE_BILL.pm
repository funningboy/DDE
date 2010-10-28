 
 #! /usr/bin/perl -W

package NET::FINANCE_BILL;

use LWP::UserAgent;
use strict;
use Data::Dumper;
use HTML::TableExtract;
use XML::Simple;
use Switch;
use SYS::Time;

$NET::FINANCE_BILL::Head = "http://justdata.yuanta.com.tw/z/zc/zcn/zcn_";
$NET::FINANCE_BILL::Tail = ".asp.htm";
@NET::FINANCE_BILL::Arr;

sub get_help{
   my ($case,@in) = (@_);

   switch($case) {
      case "get_date_info" { printf("<E1> the system time not match trader data time error ...                  \
                                          please check the system time @ env or check the trader data in yuanta \
                                          system time @ $in[0],  yuanta time @ $in[1]\n");                         }
  
   }
die;
}

sub new{
my $self = shift;

@NET::FINANCE_BILL::Arr =();

return bless {};	
}
  
sub GetFmWeb2Html {
     my ($MyStockID) = (@_);
	
     $MyStockID =~ s/\.TW//g;	

     my $ua = LWP::UserAgent->new;
        $ua->agent("MyApp/0.1");
     
     my $MyWebInf = $NET::FINANCE_BILL::Head.$MyStockID.$NET::FINANCE_BILL::Tail;

  # Create a request
     my $req = HTTP::Request->new(GET => $MyWebInf);
  
   # Pass request to the user agent and get a response back
     my $res = $ua->request($req);

  # Check the outcome of the response
     my $MyHTMLPtr;
     
     if ($res->is_success) {
        $MyHTMLPtr = $res->content;
     }else {
     	  print  $res->status_line."\n";
        die;
    }
    
 return $MyHTMLPtr; 
}

sub ParseHtml2Arr {  
    my ($MyHTMLPtr) = (@_);
    
    $MyHTMLPtr =~ s/\,//g;
    
    my $te = HTML::TableExtract->new(depth => 2, count => 0);
    $te->parse($MyHTMLPtr);
    
     my ($ts,$row,$i);
     
     foreach $ts ($te->tables) {
       #print "Table (", join(',', $ts->coords), "):\n";
         $i =0;
         foreach $row ($ts->rows) {
   	       if( $i>=5 ){
   	       	 #print Dumper($row)."\n";
   	       	 push (@NET::FINANCE_BILL::Arr,$row);
   	       	}
   	       	$i++;
   	    }
   	}
 } 	

 sub get_exp_sys_time{
   my $time = SYS::Time->new();
   my $sys_time = $time->get_system_time();
   my ($year,$mon,$mday) = split("\/",$sys_time);

   return $mon."\/".$mday;
 }

 sub get_sys_time{
    my $time = SYS::Time->new();
    my $sys_time = $time->get_system_time();
       
    my ($year,$mon,$mday) = split("\/",$sys_time);
       
    return $year."\/".$mon."\/".$mday;
  }
  
 sub ParseArr2OurDataBase{
   my ($MyStockID,$Locfile) = (@_);
    
   if( -e $Locfile){ open( oFilePtr, ">>$Locfile") or die "$!\n"; }
   else{             open( oFilePtr, ">$Locfile") or die "$!\n"; }
   
    my $i;
    my ($Date,$FnBuy,$FnSel,$FnDif,$FnRem,$FnUp,$FnUsg,$BsSel,$BsBuy,$BsDif,$BsRem,$BsUsg,$FnBs);
    
    my $CDate = get_exp_sys_time();
    my $Time  = get_sys_time();
    my $ok    = 0;

    foreach $i (reverse @NET::FINANCE_BILL::Arr){
    	 ($Date,$FnBuy,$FnSel,$FnDif,$FnRem,$FnUp,$FnUsg,$BsSel,$BsBuy,$BsDif,$BsRem,$BsUsg,$FnBs) = (@{$i});
    	     
    	  if( $Date eq $CDate){
    	  	 
    	  	  if(hex($FnUsg) eq 0){ $FnUsg="0.00%"; }
    	  	  if(hex($BsUsg) eq 0){ $BsUsg="0.00%"; }
                  $ok =1;
     	  	 
    	      printf oFilePtr ("$Date,$FnBuy,$FnSel,$FnDif,$FnRem,$FnUp,$FnUsg,$BsSel,$BsBuy,$BsDif,$BsRem,$BsUsg,$FnBs\n");
    	      }   
 	}
       
       if($ok==0){ get_help("get_date_info",($CDate,$Date)); }
  }
 
 sub get_fin_bill_data{
     my ($self,$id) = (@_); 
     my $MyHtml = GetFmWeb2Html($id);
                  ParseHtml2Arr($MyHtml);
}
 
 sub exp_fin_bill_data {
   my ($self,$id,$path) = (@_);
   
  my $MyArr2Loc = ParseArr2OurDataBase($id,$path);
 #     print Dumper(\@NET::FINANCE_BILL::Arr);
 }

 1;
