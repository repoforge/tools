#!/usr/bin/perl

use strict;
use CPANPLUS;
use CPAN;

use Carp;

use constant DEBUG  => 0;

sub version_from_spec;
sub release_from_spec;
sub cpan_package;
sub cpan_name;

my $ignore = { 
	'perl-XML-LibXSLT' => 1, # need libxslt 1.1.18
	'perl-Wx' => 1 , # doesn't compile
	'perl-Sys-Virt' => 1 , # doesn't compile
	'perl-SVK' => 1 , # deps conflict with base
	'perl-Spread' => 1 , # needs libspread
	'perl-POE-Component-SNMP' => 1 , # version
	'perl-Perl-Critic' => 1 , # doesn't compile
	'perl-PBS' => 1 , # needs libtorque
	'perl-Net-SMTP-Multipart' => 1, # we have 1.5.4 but cpan only has 1.5!
	'perl-MQSeries' => 1, # need mqseries to build
	'perl-Jifty' => 1, # needs new CGI, File::Spec etc
	'perl-Inline-Python' => 1, # does not build
	'perl-ExtUtils-ParseXS' => 1, # real version
	'perl-version' => 1, # real version
	'perl-Statistics-Descriptive' => 1, # real version
	'perl-DBD-Oracle' => 1, # needs oracle
	'perl-List-MoreUtils' => 1, # devel 
	'perl-Coro' => 1, # version 
};




# change this to a rpmforgre svn checkout
my $directory = '/home/cmr/workspace/rpmforge/rpms';
#my $directory = '/home/cmr';

my $cb = CPANPLUS::Backend->new();

opendir(DIR,$directory);
my @rpmnames = grep { /^perl-/ } readdir(DIR);


my $crap;
foreach my $name (@rpmnames) {
	
	# skip packages in ignore-list
	next if $ignore->{$name}; 


	my $mod;
	if ( $mod = CPAN::Shell->expand("Module",cpan_name($name) ) ) {

		# compare if distribution name is same as filename
		my $d;
		if( $d = $mod->distribution() ) {
			my $dist = $mod->distribution()->base_id;
			$dist =~ s/(.*)-.*/$1/;
		 	if ( "perl-".$dist ne $name ) {
				print "WARNING: wrong distname: $name belongs to $dist\n";
				next;
				}
		} else {
			print "WARNING: mod->distribution() failed on $name\n";
			next;
		}

		#my $cpan_version = version->new($mod->cpan_version);
		my $cpan_version = $mod->distribution()->base_id;
		$cpan_version =~ s/.*-(.*)/$1/;
		my $filename = "$directory/$name/$name.spec";
		
		if ( -e  $filename ){
			my $localverison = version->new(version_from_spec($filename));
			my $release =  release_from_spec($filename);

		if ( $cpan_version gt $localverison ) {
				printf("%-30.30s | Localversion: %s (%s) | Cpanversion %s (%s)\n",cpan_name($name), $localverison, version_from_spec($filename), $cpan_version, $mod->cpan_version);
			}

		}

	} else { 
		print "WARNING: Cannot resolve $name\n";
		next;
	}
	
} 


sub version_from_spec() {
	
	my $file = shift;
	my $name;
	my $version;
	open my $fh, $file or croak "Cannot open $file: $!\n";
	 while (<$fh>) {
    	/^Version:\s*(\S+)/      and $version   = $1;
	  }
	 return($version);	
}

sub release_from_spec() {

        my $file = shift;
        my $name;
        my $release;
        open my $fh, $file or croak "Cannot open $file: $!\n";
         while (<$fh>) {
        /^Release:\s*(\S+)/      and $release   = $1;
          }
         return($release);
}

sub cpan_name() {
		my $name = shift;
		my $cpan_name = $name;
		$cpan_name =~ s/^perl-//g;
		$cpan_name =~ s/-/::/g;
		return($cpan_name);
		
}
sub cpan_package() {
	
	my $name = shift;
	my $mod;
	if ( $mod = $cb->module_tree($name) ) {
		print "$name resolves to ".  $mod->package_name ."\n " if DEBUG;
		return($mod->package_name);
	} else {
		return("NA");
	}
	
}
