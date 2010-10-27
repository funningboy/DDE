#! /usr/bin/perl -W

package SYS::Time;
use strict;

sub new {
my $self = shift;
  return bless {};
}

sub get_system_time {

   my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
             $year += 1900;
             $mon  += 1;
           
           if($mon<10){  $mon="0".$mon;   }
           if($mday<10){ $mday="0".$mday; }

   return $year."\/".$mon."\/".$mday."\/".$hour."::".$min;
}

1;
