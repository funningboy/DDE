 
 #! /usr/bin/perl -W

package NET::FINANCE_BILL;

use LWP::UserAgent;
use strict;
use Data::Dumper;
use HTML::TableExtract;
use XML::Simple;


sub new{

}
  
sub GetFmWeb2Html {
	 my ($MyStockID) = (@_);
	
     $MyStockID =~ s/\.TW//g;	

     my $ua = LWP::UserAgent->new;
        $ua->agent("MyApp/0.1");
     
     my $MyWebInf = "http://justdata.yuanta.com.tw/z/zc/zcn/zcn_$MyStockID.asp.htm";

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
    my @Arr;
    
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
   	       	 push (@Arr,$row);
   	       	}
   	       	$i++;
   	    }
   	}
  return @Arr; 
 } 	
 
 sub ParseArr2OurDataBase{
 	   my $ArrPtr     = $_[0];
 	   my $MyStockID  = $_[1];
 	   my $Locfile    = $_[2];
 	   
 	   my @Arr    = @{$ArrPtr}; 
          
 	  if( -e $Locfile){ open( oFilePtr, ">>$Locfile") or die "$!\n"; }
 	  else{            open( oFilePtr, ">$Locfile") or die "$!\n"; }
 	  
 	   #print Dumper(\@Arr);
 	   my $i;
 	   my ($Date,$FnBuy,$FnSel,$FnDif,$FnRem,$FnUp,$FnUsg,$BsSel,$BsBuy,$BsDif,$BsRem,$BsUsg,$FnBs);
 	   
 	   my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
 	       $year += 1900;
 	       $mon  += 1;
 	        
 	   if($mon<10){  $mon="0".$mon;   }
 	   if($mday<10){ $mday="0".$mday; }
 	        
 	   my $CDate = $mon."/".$mday;
 	   my $ok=0;
 	     
 	   foreach $i (@Arr){
 	   	 ($Date,$FnBuy,$FnSel,$FnDif,$FnRem,$FnUp,$FnUsg,$BsSel,$BsBuy,$BsDif,$BsRem,$BsUsg,$FnBs) = (@{$i});
 	   	     
 	   	     #if(int($BsUsg) eq "63"){ print "ccc"; }
 	   	     
 	   	  if( $Date eq $CDate){
 	   	  	  $CDate = $year."/".$Date;
 	   	  	 
 	   	  	  if(hex($FnUsg) eq 0){ $FnUsg="0.00%"; }
 	   	  	  if(hex($BsUsg) eq 0){ $BsUsg="0.00%"; }
 	   	  	  
 	   	  	  #print "$CDate,$FnBuy,$FnSel,$FnDif,$FnRem,$FnUp,$FnUsg,$BsSel,$BsBuy,$BsDif,$BsRem,$BsUsg,$FnBs\n";
 	   	      printf oFilePtr ("$CDate,$FnBuy,$FnSel,$FnDif,$FnRem,$FnUp,$FnUsg,$BsSel,$BsBuy,$BsDif,$BsRem,$BsUsg,$FnBs\n");
 	   	      $ok =1;
 	   	   }
 	   	}
 	   	
 	   unless( $ok==1 ){ print "FnceBesh Catch Failed";  return "-1"; die; }
 	   
 	   return "0";	
 	}
 
sub new {
  my $self = shift;
return bless {};	
}
 
 
 sub ExpFnceBesh2Loc{
   my $self = shift;
   my ($StockID) = (@_);
   
   my $oExpFileLoc = "../../data_off/fncebesh/$StockID"."_FB.csv";
       
   my $MyHtml    = &GetFmWeb2Html($StockID);
   my @MyArr     = &ParseHtml2Arr($MyHtml);
   my $MyArr2Loc = &ParseArr2OurDataBase(\@MyArr,$StockID,$oExpFileLoc);
      
      #print Dumper(\@MyArr);
 }

 1;
