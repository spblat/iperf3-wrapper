#!/usr/bin/perl
 
use strict;
use Getopt::Std;
use JSON;
#use Data::Dumper;
use Statistics::Basic qw(:all);
 
sub HELP_MESSAGE {
##############################################################################
# ABOUT THIS SCRIPT ##########################################################
##############################################################################
        print <<EOF;

This is $0 version 0.1.

Copyright (C) 2015. Licensed under the General Public License (GPL) v3.0.
 
This script invokes iperf3 and produces a tab delimited line you might want
to append to a file for purposes of making a wifi site survey.

The main reason it exists is that you might want to record standard deviation
values, which can indicate an unreliable connection or a testing anomaly. 
 
Flags:
 
    -v              Verbose. Lots of debugging information, if applicable.
    -h              This message.
    -s [ip]			iPerf3 server IP. Must be running iPerf3 in server mode.
    -t [title]      (Optional) label this session, say with a location.

Maybe you want to use the "screen" command to make a split screen. Then
Maybe you want to tail -f myresults.tab. Then maybe you want to do this:

$0 -s 193.168.215.23 -t bedroom_ethernet >> myresults.tab

...then, if it works, you'll see a line appended to the file in your tail
pane that looks a little something like this:

Sun, 06 Sep 2015 21:31:14 GMT	bedroom_ethernet	192.168.215.59	192.168.215.23	942.1	2.09

The fields are:
 - timestamp
 - your session title, given with -t
 - your client IP
 - your server IP, given by -s
 - mean bitrate, in Mbps
 - standard deviation, also in Mbps

VERSION HISTORY
2015-09-06      Will Irace      First Version.
 
EOF
        exit();
}
 
##############################################################################
# TO DO/BUGS #################################################################
##############################################################################
# We don't do much input checking.
# If iPerf3 isn't there we just die.
# If iPerf3 changes its JSON output format we're toast.
# If you supply an invalid server IP nothing much will happen.
 
 
##############################################################################
# MAIN CODE ##################################################################
##############################################################################
 
# getopts('vhi:') means v and h are flags, and i is a parameter
getopts('vht:s:');
HELP_MESSAGE() if $main::opt_h;
HELP_MESSAGE() unless $main::opt_s;
my $HOST = $main::opt_s;
$main::DEBUG = 1 if ($main::opt_v);
debug("well hi there");

my $title = $main::opt_t ? $main::opt_t : '...';
my $cmd = "iperf3 -c $HOST -J";
my $json = decode_json `$cmd` || die $!;
print $json->{start}->{timestamp}->{time} . "\t" . $title . "\t";
print $json->{start}->{connected}[0]->{local_host} . "\t";
print $json->{start}->{connected}[0]->{remote_host} . "\t";
my $intervals = $json->{intervals};
my @results;
foreach (@{$intervals}) {
    push @results, ($_->{sum}->{bits_per_second});
}
printf ("%.1f\t%.2f\n", mean(@results) / 1000000,stddev(@results) / 1000000);


##############################################################################
##### SUBROUTINES ############################################################
##############################################################################
 
sub debug {
        my $info = shift;
        print "DEBUG: " . $info . "\n" if $main::DEBUG;
}
