 #!/usr/bin/perl 

package NET::TraderDetail;
  use LWP::UserAgent;
  use Data::Dumper;
  use HTML::TableExtract;
  use XML::Simple;
  use SYS::Time;
  use strict;
  use Switch;
  
  @NET::TraderDetail::Arr;
  $NET::TraderDetail::Web =  "http://justdata.yuanta.com.tw/z/ze/zee/zee.asp.htm";

sub get_help{
    my ($case,@in) = (@_);
    
    switch($case){
      case "get_date_info" { printf("<E1> the system time not match trader data time error ...                  \
                                          please check the system time @ env or check the trader data in yuanta \
                                          system time @ $in[0],  yuanta time @ $in[1]\n");                         }
   }

die;
}

sub new {
  my $self = shift;
  return bless {};	
} 

sub get_trader_data {
  
     my $ua = LWP::UserAgent->new;
        $ua->agent("MyApp/0.1");
    
      my $MyWebInf = $NET::TraderDetail::Web;
  # Create a request
     my $req = HTTP::Request->new(GET => $MyWebInf);
  
   # Pass request to the user agent and get a response back
     my $res = $ua->request($req);

  # Check the outcome of the response
     my $MyHTMLPtr;
     
     if ($res->is_success) {
        $MyHTMLPtr = $res->content;
        ParseHtml2Arr($MyHTMLPtr); 
 
     }else {
     	  print  $res->status_line."\n";
          die;
    }
}

sub ParseHtml2Arr {  
    my ($MyHTMLPtr) = (@_);
  
    my $CDate = get_sys_time();
    my $Date;
 
    if($MyHTMLPtr=~ m/最後更新日: (\w+)\/(\w+)/){
    	 $Date = $1."\/".$2;
      }

    unless($CDate eq $Date){ get_help("get_date_info",($CDate,$Date)); }
     
    $MyHTMLPtr =~ s/\,//g;
     
    my $te = HTML::TableExtract->new(depth => 2, count => 0);
       $te->parse($MyHTMLPtr);
    
     my ($ts,$row,$i) = {};
     
     foreach $ts ($te->tables) {
       #print "Table (", join(',', $ts->coords), "):\n";
         foreach $row ($ts->rows) {
         # print Dumper(\$row);
          if($i>=2){
             push(@NET::TraderDetail::Arr,$row);
          }
           $i++;
          }
   	}
 } 	
 
sub exp_trader_data {
 	  my ($self,$Locfile) = (@_);
 	  
 	  open( oFilePtr, ">$Locfile") or die "$!\n"; 
  
 	  my ($STID,$STNM,$BySlTC,$HDTC,$PCTC) = {};
 	  
 	   foreach my $i (@NET::TraderDetail::Arr){
 	   	  ($STID,$BySlTC,$HDTC,$PCTC) = (@{$i});
 	   	   if( $STID=~ m/(\d+)/){ ($STID,$STNM) = ($1,$2); $STID=$STID.".TW"; }
 	   	  	  printf  oFilePtr ("$STID,$BySlTC,$HDTC,$PCTC\n");  
 	   	}

         close(oFilePtr);
}
 
sub get_sys_time {
   
   my $time = SYS::Time->new();
   my $sys_time = $time->get_system_time();
   my ($year,$mon,$mday) = split("\/",$sys_time);

   return $mon."\/".$mday; 
}


1;
