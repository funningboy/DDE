#/usr/bib/perl

package FINANCE::UTIL;
use FINANCE::HISTORY_INFO;
use Data::Dumper;
use strict;
use Switch;

%FINANCE::UTIL::hslist;

sub get_help{
    my ($case,$inx,$perid,$ed) = (@_);
 
    switch($case) {
      case "get_hslist_info" { printf("@ <E1> FINANCE::UTIL \"new\" Error ...             \
                                        please check the %hash in new() had already exist \
                                        ex : FINANCE::UTIL->new(%hash)\n");                   }

      case "get_data_info"   { printf("@ <E2> FINANCE::UTIL \"date\" Error...             \
                                       please check the date in %hash had already exist\n");  } 

      case "get_bk_inx_info" { printf("@ <E3> FINANCE::UTIL \"inx\" Error...              \
                                       please check the (inx - period + 1)>0
                                       cur @            ($inx - $perid + 1)\n");              }

      case "get_fw_inx_info" { printf("@ <E4> FINANCE::UTIL \"inx\" Error...              \
                                       please check the (inx + period - 1)<max_inx
                                       cur @            ($inx + $perid - 1)< $ed\n");         }
   }
}

sub new {
    my ($class,$hslist) = (@_);
 
    %FINANCE::UTIL::hslist = %{$hslist};
    unless( keys %FINANCE::UTIL::hslist ){ 
        get_help("get_hslist_info");
        return -1;
    }

    my $self  = FINANCE::HISTORY_INFO->new(); 
    bless $self, $class;
    return $self;
}

sub get_bk_highest_pric{
    my ($self,$perid,$enddate) = (@_);
   
    if( !defined($FINANCE::UTIL::hslist{DAT}{$enddate}) ){
         get_help("get_date_info");
         return -1;
    }
 
    my $inx = $FINANCE::UTIL::hslist{DAT}{$enddate};
    my $bg  = $inx - $perid +1;   
    if ( $bg < 0 ){ 
            get_help("get_bk_inx_info",$inx,$perid); 
            return -1;
       }

    my $info  = INFO->new();
       $info = $FINANCE::UTIL::hslist{REF}{$bg};
    my $hgest = $info->hpric;

   for(my $i=$bg; $i<=$inx; $i++){
          $info = $FINANCE::UTIL::hslist{REF}{$i};
          if( $info->hpric > $hgest ){ $hgest = $info->hpric; }
    } 

$info = ();   
return $hgest;
}

sub get_fw_highest_pric{
    my ($self,$perid,$enddate) = (@_);
   
    if( !defined($FINANCE::UTIL::hslist{DAT}{$enddate}) ){
         get_help("get_date_info");
         return -1;
    }
 
    my $inx = $FINANCE::UTIL::hslist{DAT}{$enddate};
    my $ed  = $inx + $perid -1;   
    if ( !defined($FINANCE::UTIL::hslist{REF}{$ed})  ){ 
            get_help("get_fw_inx_info",$inx,$perid,$ed); 
            return -1;
       }

    my $info  = INFO->new();
       $info = $FINANCE::UTIL::hslist{REF}{$ed};
    my $hgest = $info->hpric;

   for(my $i=$inx; $i<=$ed; $i++){
          $info = $FINANCE::UTIL::hslist{REF}{$i};
          if( $info->hpric > $hgest ){ $hgest = $info->hpric; }
    } 

$info = ();   
return $hgest;
}

sub get_bk_lowest_pric{
    my ($self,$perid,$enddate) = (@_);
   
    if( !defined($FINANCE::UTIL::hslist{DAT}{$enddate}) ){
         get_help("get_date_info");
         return -1;
    }
 
    my $inx = $FINANCE::UTIL::hslist{DAT}{$enddate};
    my $bg  = $inx - $perid +1;   
    if ( $bg < 0 ){ 
            get_help("get_inx_info",$inx,$perid); 
            return -1;
       }

    my $info  = INFO->new();
       $info = $FINANCE::UTIL::hslist{REF}{$bg};
    my $lwest = $info->lpric;

   for(my $i=$bg; $i<=$inx; $i++){
          $info = $FINANCE::UTIL::hslist{REF}{$i};
          if( $info->lpric < $lwest ){ $lwest = $info->lpric; }
    } 

$info = ();   
return $lwest;
}

sub get_fw_lowest_pric{
    my ($self,$perid,$enddate) = (@_);
   
    if( !defined($FINANCE::UTIL::hslist{DAT}{$enddate}) ){
         get_help("get_date_info");
         return -1;
    }
 
    my $inx = $FINANCE::UTIL::hslist{DAT}{$enddate};
    my $ed  = $inx + $perid -1;   
    if ( !defined($FINANCE::UTIL::hslist{REF}{$ed})  ){ 
            get_help("get_fw_inx_info",$inx,$perid,$ed); 
            return -1;
       }

    my $info  = INFO->new();
       $info = $FINANCE::UTIL::hslist{REF}{$ed};
    my $lwest = $info->hpric;

   for(my $i=$inx; $i<=$ed; $i++){
          $info = $FINANCE::UTIL::hslist{REF}{$i};
          if( $info->lpric < $lwest ){ $lwest = $info->lpric; }
    } 

$info = ();   
return $lwest;
}

sub get_bk_avg_high_pric{
    my ($self,$perid,$enddate) = (@_);
   
    if( !defined($FINANCE::UTIL::hslist{DAT}{$enddate}) ){
         get_help("get_date_info");
         return -1;
    }
 
    my $inx = $FINANCE::UTIL::hslist{DAT}{$enddate};
    my $bg  = $inx - $perid +1;   
    if ( $bg < 0 || $perid ==0 ){ 
            get_help("get_inx_info",$inx,$perid); 
            return -1;
       }

    my $info  = INFO->new();
    my $avg   = 0;

   for(my $i=$bg; $i<=$inx; $i++){
          $info = $FINANCE::UTIL::hslist{REF}{$i};
          $avg += $info->hpric;
    } 
    
    $avg /= $perid;

$info = ();   
return $avg;
}


sub get_fw_avg_high_pric{
    my ($self,$perid,$enddate) = (@_);
   
    if( !defined($FINANCE::UTIL::hslist{DAT}{$enddate}) ){
         get_help("get_date_info");
         return -1;
    }
 
    my $inx = $FINANCE::UTIL::hslist{DAT}{$enddate};
    my $ed  = $inx + $perid -1;   
    if ( !defined($FINANCE::UTIL::hslist{REF}{$ed}) || $perid ==0 ){ 
            get_help("get_fw_inx_info",$inx,$perid,$ed); 
            return -1;
       }

    my $info =  INFO->new();
    my $avg  =  0;

   for(my $i=$inx; $i<=$ed; $i++){
          $info = $FINANCE::UTIL::hslist{REF}{$i};
          $avg += $info->hpric;
    } 
  
    $avg /= $perid;

$info = ();   
return $avg;
}

sub get_bk_avg_low_pric{
    my ($self,$perid,$enddate) = (@_);
   
    if( !defined($FINANCE::UTIL::hslist{DAT}{$enddate}) ){
         get_help("get_date_info");
         return -1;
    }
 
    my $inx = $FINANCE::UTIL::hslist{DAT}{$enddate};
    my $bg  = $inx - $perid +1;   
    if ( $bg < 0 || $perid ==0 ){ 
            get_help("get_inx_info",$inx,$perid); 
            return -1;
       }

    my $info =  INFO->new();
    my $avg  =  0;

   for(my $i=$bg; $i<=$inx; $i++){
          $info = $FINANCE::UTIL::hslist{REF}{$i};
          $avg += $info->lpric;
    } 
  
    $avg /= $perid;

$info = ();   
return $avg;
}

sub get_fw_avg_low_pric{
    my ($self,$perid,$enddate) = (@_);
   
    if( !defined($FINANCE::UTIL::hslist{DAT}{$enddate}) ){
         get_help("get_date_info");
         return -1;
    }
 
    my $inx = $FINANCE::UTIL::hslist{DAT}{$enddate};
    my $ed  = $inx + $perid -1;   
    if ( !defined($FINANCE::UTIL::hslist{REF}{$ed}) || $perid ==0 ){ 
            get_help("get_fw_inx_info",$inx,$perid,$ed); 
            return -1;
       }

    my $info =  INFO->new();
    my $avg  =  0;

   for(my $i=$inx; $i<=$ed; $i++){
          $info = $FINANCE::UTIL::hslist{REF}{$i};
          $avg += $info->lpric;
    } 
  
    $avg /= $perid;

$info = ();   
return $avg;
}



1;

