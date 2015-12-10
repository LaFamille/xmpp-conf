#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Std;

my $CONFIG = 'host.conf';

&main();

sub main {
    my %opt;
    if (!getopts('he:c:', \%opt) || $opt{h}) {
	print STDERR
	    "Usage:\n$0 [-c CONF] [-e VAR] [FILE...]\n",
	    "Read definitions from CONF file (default $CONFIG) and\n",
	    "print each FILE with variable between \@xyz\@ expanded.\n",
	    "If -e, print expanded VAR and exit\n";
	    ;
	exit 1;
    }

    my $c = read_conf($opt{c} || $CONFIG);

    if ($opt{e}) {
	print expand($c, $e);
	exit 0;
    }

    for (@ARGV) {
	process_file($_, $c);
    }
}

sub read_conf {
    my $fn = shift;

    my %c;
    open my $f, '<', $fn or die "can't read conf $fn: $!";
    while(<$f>) {
	if (/^(.+?)=(.*)$/) {
	    my ($var, $val) = ($1, $2);
	    $var = strip($var);
	    $val = strip($val);
	    $c{$var} = $val;
	}
    }
    return \%c;
}

sub process_file {
    my ($fn, $c) = @_;

    open my $f, '<', $fn or die "can't process file $fn: $!";
    while (<$f>) {
	s/@([0-9A-Za-z_-]+)@/expand($c, $1)/eg;
	print;
    }
}

sub expand {
    my ($c, $var) = @_;
    if (exists $$c{$var}) {
	return $$c{$var};
    }
    die "undefined configuration variable '$var'";
}

sub strip {
    my $s = shift;
    $s =~ s/^\s+//g;
    $s =~ s/\s+$//g;
    return $s;
}
