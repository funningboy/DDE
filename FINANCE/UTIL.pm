#!/usr/bib/perl -w

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
print $case;
die;
}

sub new {
    my ($class,$hslist) = (@_);
    %FINANCE::UTIL::hslist = ();
    %FINANCE::UTIL::hslist = %{$hslist};
    unless( keys %FINANCE::UTIL::hslist ){ 
        get_help("get_hslist_info");
        return -1;
    }

    my $self  = FINANCE::HISTORY_INFO->new(); 
    bless $self, $class;
    return $self;
}

sub get_inx_by_time{
  my ($self,$enddate) = (@_);
  if( !defined($FINANCE::UTIL::hslist{DAT}{$enddate}) ){ get_help("get_date_info"); }
  return $FINANCE::UTIL::hslist{DAT}{$enddate};
}

sub get_time_by_inx{
  my ($self,$inx) = (@_);
   
  my $info = INFO->new();
  my $info = $FINANCE::UTIL::hslist{REF}{$inx};
  my $time = $info->date;
  return $time;
}

sub get_end_inx{
  my ($self) = (@_);

  my $info = INFO->new();
  my @arr  = reverse sort {$a<=>$b} keys %{$FINANCE::UTIL::hslist{REF}};
  
  return $arr[0];
}

sub get_op_pric_by_inx{
   my ($self,$inx) = (@_);
   my $info  = INFO->new();
      $info  = $FINANCE::UTIL::hslist{REF}{$inx};
   my $opric = $info->opric;
 return $opric;
}

sub get_cl_pric_by_inx{
   my ($self,$inx) = (@_);
   my $info  = INFO->new();
      $info  = $FINANCE::UTIL::hslist{REF}{$inx};
   my $cpric = $info->cpric;
 return $cpric;
}

sub get_lw_pric_by_inx{
   my ($self,$inx) = (@_);
   my $info  = INFO->new();
      $info  = $FINANCE::UTIL::hslist{REF}{$inx};
   my $lpric = $info->lpric;
 return $lpric;
}

sub get_hg_pric_by_inx{
   my ($self,$inx) = (@_);
   my $info  = INFO->new();
      $info  = $FINANCE::UTIL::hslist{REF}{$inx};
   my $hgpric= $info->hpric;
 return $hgpric;
}

sub get_vol_by_inx{
   my ($self,$inx) = (@_);
   my $info  = INFO->new();
      $info  = $FINANCE::UTIL::hslist{REF}{$inx};
   my $vol   = $info->vol;
 return $vol;
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
    my $lwest = $info->lpric;

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

sub get_bk_avg_open_pric{
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
          $avg += $info->opric;
    } 
  
    $avg /= $perid;

$info = ();   
return $avg;
}

sub get_fw_avg_open_pric{
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
          $avg += $info->opric;
    } 
  
    $avg /= $perid;

$info = ();   
return $avg;
}

sub get_bk_avg_close_pric{
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
          $avg += $info->cpric;
    } 
  
    $avg /= $perid;

$info = ();   
return $avg;
}

sub get_fw_avg_close_pric{
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
          $avg += $info->cpric;
    } 
  
    $avg /= $perid;

$info = ();   
return $avg;
}

#----------------
# sean add
#
#
#---------------
sub get_bk_avg_open_pric_by_inx{
    my ($self,$perid,$inx) = (@_);

    my $bg  = $inx - $perid +1;   
    if ( $bg < 0 || $perid ==0 ){ 
            get_help("get_inx_info",$inx,$perid); 
            return -1;
       }

    my $info  = INFO->new();
    my $avg   = 0;

   for(my $i=$bg; $i<=$inx; $i++){
          $info = $FINANCE::UTIL::hslist{REF}{$i};
          $avg += $info->opric;
    } 
    
    $avg /= $perid;

$info = ();   
return $avg;
}

sub get_fw_avg_open_pric_by_inx{
    my ($self,$perid,$inx) = (@_);
 
    my $ed  = $inx + $perid -1;   
    if ( !defined($FINANCE::UTIL::hslist{REF}{$ed}) || $perid ==0 ){ 
            get_help("get_fw_inx_info",$inx,$perid,$ed); 
            return -1;
       }

    my $info =  INFO->new();
    my $avg  =  0;

   for(my $i=$inx; $i<=$ed; $i++){
          $info = $FINANCE::UTIL::hslist{REF}{$i};
          $avg += $info->opric;
    } 
  
    $avg /= $perid;

$info = ();   
return $avg;
}

sub get_bk_avg_high_pric_by_inx{
    my ($self,$perid,$inx) = (@_);

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

sub get_fw_avg_high_pric_by_inx{
    my ($self,$perid,$inx) = (@_);
 
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


sub get_bk_avg_low_pric_by_inx{
    my ($self,$perid,$inx) = (@_);

    my $bg  = $inx - $perid +1;   
    if ( $bg < 0 || $perid ==0 ){ 
            get_help("get_inx_info",$inx,$perid); 
            return -1;
       }

    my $info  = INFO->new();
    my $avg   = 0;

   for(my $i=$bg; $i<=$inx; $i++){
          $info = $FINANCE::UTIL::hslist{REF}{$i};
          $avg += $info->lpric;
    } 
    
    $avg /= $perid;

$info = ();   
return $avg;
}

sub get_fw_avg_low_pric_by_inx{
    my ($self,$perid,$inx) = (@_);
 
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

sub get_bk_avg_close_pric_by_inx{
    my ($self,$perid,$inx) = (@_);

    my $bg  = $inx - $perid +1;   
    if ( $bg < 0 || $perid ==0 ){ 
            get_help("get_inx_info",$inx,$perid); 
            return -1;
       }

    my $info  = INFO->new();
    my $avg   = 0;

   for(my $i=$bg; $i<=$inx; $i++){
          $info = $FINANCE::UTIL::hslist{REF}{$i};
          $avg += $info->cpric;
    } 
    
    $avg /= $perid;

$info = ();   
return $avg;
}

sub get_fw_avg_close_pric_by_inx{
    my ($self,$perid,$inx) = (@_);
 
    my $ed  = $inx + $perid -1;   
    if ( !defined($FINANCE::UTIL::hslist{REF}{$ed}) || $perid ==0 ){ 
            get_help("get_fw_inx_info",$inx,$perid,$ed); 
            return -1;
       }

    my $info =  INFO->new();
    my $avg  =  0;

   for(my $i=$inx; $i<=$ed; $i++){
          $info = $FINANCE::UTIL::hslist{REF}{$i};
          $avg += $info->cpric;
    } 
  
    $avg /= $perid;

$info = ();   
return $avg;
}

sub get_bk_avg_vol_by_inx{
    my ($self,$perid,$inx) = (@_);

    my $bg  = $inx - $perid +1;   
    if ( $bg < 0 || $perid ==0 ){ 
            get_help("get_inx_info",$inx,$perid); 
            return -1;
       }

    my $info  = INFO->new();
    my $avg   = 0;

   for(my $i=$bg; $i<=$inx; $i++){
          $info = $FINANCE::UTIL::hslist{REF}{$i};
          $avg += $info->vol;
    } 
    
    $avg /= $perid;

$info = ();   
return $avg;
}

sub get_fw_avg_vol_by_inx{
    my ($self,$perid,$inx) = (@_);
 
    my $ed  = $inx + $perid -1;   
    if ( !defined($FINANCE::UTIL::hslist{REF}{$ed}) || $perid ==0 ){ 
            get_help("get_fw_inx_info",$inx,$perid,$ed); 
            return -1;
       }

    my $info =  INFO->new();
    my $avg  =  0;

   for(my $i=$inx; $i<=$ed; $i++){
          $info = $FINANCE::UTIL::hslist{REF}{$i};
          $avg += $info->vol;
    } 
  
    $avg /= $perid;

$info = ();   
return $avg;
}

sub get_bk_highest_pric_by_inx{
    my ($self,$perid,$inx) = (@_);
   
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

return $hgest;
}

sub get_fw_highest_pric_by_inx{
    my ($self,$perid,$inx) = (@_);
   
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

sub get_bk_lowest_pric_by_inx{
    my ($self,$perid,$inx) = (@_);
   
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

return $lwest;
}

sub get_fw_lowest_pric_by_inx{
    my ($self,$perid,$inx) = (@_);
   
    my $ed  = $inx + $perid -1;   
    if ( !defined($FINANCE::UTIL::hslist{REF}{$ed})  ){ 
            get_help("get_fw_inx_info",$inx,$perid,$ed); 
            return -1;
       }

    my $info  = INFO->new();
       $info = $FINANCE::UTIL::hslist{REF}{$ed};
    my $lwest = $info->lpric;

   for(my $i=$inx; $i<=$ed; $i++){
          $info = $FINANCE::UTIL::hslist{REF}{$i};
          if( $info->lpric < $lwest ){ $lwest = $info->lpric; }
    } 

$info = ();   
return $lwest;
}

1;

