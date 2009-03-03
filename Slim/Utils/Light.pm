package Slim::Utils::Light;

# $Id:  $

# SqueezeCenter Copyright 2001-2009 Logitech.
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License, 
# version 2.

# This module provides some functions compatible with functions
# from the core SqueezeCenter code, without their overhead.
# These functions are called by helper applications like SqueezeTray
# or the control panel.

use Exporter;
@ISA = qw(Exporter);
use File::Spec::Functions;

use Slim::Utils::OSDetect;

our @EXPORT = qw(string getPref);
my ($os, $language, %strings);

BEGIN {
	Slim::Utils::OSDetect::init();
	$os = Slim::Utils::OSDetect->getOS();
	$language = $os->getSystemLanguage();
}


# return localised version of string token
sub string {
	my $name = shift;
	$strings{ $name }->{ $language } || $strings{ $name }->{'EN'} || $name;
}

sub loadStrings {
	my $string     = '';
	my $language   = '';
	my $stringname = '';

	# server string file
	my $path = $os->dirsFor('strings');
	my $file = catdir($path, 'strings.txt');
	
	open(STRINGS, "<:utf8", $file) || do {
		die "Couldn't open $file - FATAL!";
	};

	foreach my $line (<STRINGS>) {

		chomp($line);
		
		next if $line =~ /^#/;
		next if $line !~ /\S/;

		if ($line =~ /^(\S+)$/) {

			$stringname = $1;
			$string = '';
			next;

		} elsif ($line =~ /^\t(\S*)\t(.+)$/) {

			$language = uc($1);
			$string   = $2;

			$strings{$stringname}->{$language} = $string;
		}
	}

	close STRINGS;
}

# Read pref from the server preference file - lighter weight than loading YAML
# don't call this too often, it's in no way optimized for speed
sub getPref {
	my $pref = shift;

	my $prefFile = catdir( $os->dirsFor('prefs'), 'server.prefs' );

	my $ret;

	if (-r $prefFile) {

		if (open(PREF, $prefFile)) {

			while (<PREF>) {
			
				# read YAML (server) and old style prefs (installer)
				if (/^$pref(:| \=)? (.+)$/) {
					$ret = $2;
					last;
				}
			}

			close(PREF);
		}
	}

	return $ret;
}

loadStrings();


1;