#/usr/bin/perl

package FINANCE::HISTORY_INFO;
use Data::Dumper;
use Class::Struct;
use strict;
use Switch;

struct INFO => [
	date  => '$',
	opric => '$',
	hpric => '$',
	lpric => '$',
	cpric => '$',
	vol   => '$',
];

%FINANCE::HISTORY_INFO::hsptr;

sub get_help{
    my ($case) = (@_);   

   switch($case) {    
    case "get_file_info" {  printf(" @ <E1> FINANCE::HISTORY_INFO \"get_file_info\" Error ...   \
                                       please using \"YY/MM/DD,OP,HP,LP,CP,VL\" format in csv   \
                                       ex: 2009/10/01,45.40,46.25,45.40,46.15,8456              \
                                       2009/10/02,45.25,45.25,44.20,44.35,15211\n" ); }

    case "get_date_info" {  printf(" @ <E2> FINANCE::HISTORY_INFO \"get_date_info\" Error ...   \
                                       please check the date in csv\n"             ); }
   }
}

sub new {
    my ($class) = (@_);
    my $self  = INFO->new(); 
    bless $self, $class;
    return $self;
} 
 
sub del_date_info{
    my ($self,$date) = (@_);
   
    if( !defined($FINANCE::HISTORY_INFO::hsptr{DAT}{$date}) ){
         get_help("get_date_info");       
         return -1;
      }

    my $inx = $FINANCE::HISTORY_INFO::hsptr{DAT}{$date};

    delete $FINANCE::HISTORY_INFO::hsptr{DAT}{$date};
    delete $FINANCE::HISTORY_INFO::hsptr{REF}{$inx};
}

sub cls_file_info{
    my ($self) = (@_);

        %FINANCE::HISTORY_INFO::hsptr = ();
}

sub get_date_info{
    my ($self,$date) = (@_);
 
       if( !defined($FINANCE::HISTORY_INFO::hsptr{DAT}{$date}) ){
            get_help("get_date_info");       
            return -1;
       }

    my $inx = $FINANCE::HISTORY_INFO::hsptr{DAT}{$date};
    return    $FINANCE::HISTORY_INFO::hsptr{REF}{$inx};
}

sub get_file_info{
    my ($self,$iFile) = (@_);
    my $inx =0;

    open ( iFilePtr, "$iFile") or die "open $iFile error\n";

    while( <iFilePtr> ){
       chomp;
       my ($dt,$op,$hp,$lp,$cp,$vl) = split("\,");

       if( $dt !~ /[0-9\/]/ || $op !~ /[0-9\/]/ ){
           get_help("get_file_info");
           return -1;
       }

       my $info =  INFO->new( date  => $dt,
                              opric => $op,
                              hpric => $hp,
                              lpric => $lp,
                              cpric => $cp,
                              vol   => $vl);

         $FINANCE::HISTORY_INFO::hsptr{DAT}{$dt}    = $inx;
         $FINANCE::HISTORY_INFO::hsptr{REF}{$inx++} = $info;
   }

  return \%FINANCE::HISTORY_INFO::hsptr;
}


1;


