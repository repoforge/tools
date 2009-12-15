#!/usr/bin/perl

use strict;
use CPAN;
use Carp;

sub version_from_spec;

# change this to a rpmforgre svn checkout
my $directory = '/home/cmr/workspace/rpmforge/rpms';


opendir(DIR,$directory);
my @rpmnames = grep { /^perl-/ } readdir(DIR);
# list of pakages to ignore
my $ignore = { 'perl-Yahoo-Photos' => 'ignore', 
				'perl-XML-SAX-PurePerl' => 'ignore',
				'perl-XML-LibXSLT' => 'ignore', # need libxslt 1.1.18
				'perl-Wx' => 'ignore',
				'perl-WWW-Search' => 'ignore',
				'perl-WebService-YouTube' => 'ignore',
				'perl-Usage' => 'ignore',
				'perl-URIC' => 'ignore',
				'perl-Unix-PID' => 'ignore', # 0.00015 instead of 0.0.15
				'perl-UNIVERSAL-cant' => 'ignore', # 0.0.1 vs 0.0001
				'perl-Unicode-Escape' => 'ignore', # 0.0.2 vs 0.0002
				'perl-Tie-EncryptedHash' => 'ignore',
				'perl-Text-MediawikiFormat' => 'ignore',
				'perl-Text-Autoformat' => 'ignore',
				'perl-SVK-Util' => 'ignore', # Part of SVK
				'perl-SVK' => 'ignore', # cyclic dep: svn-mirror -> svk-util -> building svk-util
				'perl-Statistics-Descriptive' => 'ignore', # 3.0 vs 3.0000
				'perl-SQL-Library' => 'ignore', # 0.0.3 vs v0.0.3
				'perl-SOAP-Lite' => 'ignore', # 
				'perl-Smart-Comments' => 'ignore', # 
				'perl-RPC-XML' => 'ignore', # 
				'perl-Return-Value' => 'ignore', # 
				'perl-Quota-OO' => 'ignore', # v0.0.1 0.0001 
				'perl-Qt' => 'ignore', # Wrong name + no compile
				'perl-Proc-Simple' => 'ignore', # broken version
				'perl-POE-Session-Cascading' => 'ignore', # module version number
				'perl-POE-Component-SNMP' => 'ignore', # module version number
				'perl-POE-API-Peek' => 'ignore', # module version numb
				'perl-PDF-API2' => 'ignore', # module version number
				'perl-Number-Fraction' => 'ignore', # module version number
				'perl-Net-WhoisNG-Person' => 'ignore', # moved to perl-Net-WhoisNG
				'perl-Net-SNMP' => 'ignore', # version
				'perl-Net-Server-Mail-ESMTP-XFORWARD' => 'ignore', # moved to perl-Net-Server-Mail
				'perl-NetPacket' => 'ignore', # version
				'perl-Nagios-Object' => 'ignore', # version
				'perl-MQSeries' => 'ignore', # need mqseries
				'perl-MQSeries-Message' => 'ignore', # need mqseries
				'perl-MQSeries-Queue' => 'ignore', # need mqseries
				'perl-MQSeries-QueueManager' => 'ignore', # need mqseries
				'perl-MooseX-Types' => 'ignore', # Extutils::MakeMaker
				'perl-MooseX-Getopt' => 'ignore', # dependencies in perl core rpm
				'perl-Module-Starter-PBP' => 'ignore', # version
				'perl-Math-Business-SMA' => 'ignore', # moved to stockmoney
				'perl-Math-Business-MACD' => 'ignore', # moved to stockmoney
				'perl-Math-Business-EMA' => 'ignore', # moved to stockmoney
				'perl-Mail-SPF-Query' => 'ignore', # version
				'perl-Mail-SpamAssassin-Plugin-OpenPGP' => 'ignore', # version
				'perl-Mail-GPG' => 'ignore', # version
				'perl-Mail-ClamAV' => 'ignore', # deps (PDL)
				'perl-Lingua-Alphabet-Phonetic' => 'ignore', # version
				'perl-Lemonldap-NG-Manager' => 'ignore', # deps (lasso)
				'perl-Lemonldap-NG-Handler' => 'ignore', # deps (lasso)
				'perl-Kwiki-Attachments' => 'ignore', # upstream broken
				'perl-Jifty' => 'ignore', # deps (oracle)
				'perl-Jifty-DBI' => 'ignore', # deps (oracle)
				'perl-IO-Compress-Bzip2' => 'ignore', # moved 
				'perl-IO-Compress-Base' => 'ignore', # moved 
				'perl-HTML-Latex' => 'ignore', # moved html2latex
				'perl-Games-WoW-Armory' => 'ignore', # version
				'perl-File-HomeDir' => 'ignore', # version
				'perl-ExtUtils-DynaGlue' => 'ignore', # version
				'perl-Error-Dumb' => 'ignore', # version
				'perl-DBIx-SearchBuilder' => 'ignore', # deps makemaker?
				'perl-DBD-Oracle' => 'ignore', # deps ora-devel
				'perl-DBD-File' => 'ignore', # moved to DBI
				'perl-WWW-Curl' => 'ignore', # broken libcurl checks
				'perl-first' => 'ignore', # version
				'perl-Inline-Python' => 'ignore', # does not compile
				'perl-DBIx-HTMLView' => 'ignore', # version
				'perl-Date-Holidays-DE' => 'ignore', # version
				'perl-Cwd' => 'ignore', # moved PathTools
				'perl-Coro' => 'ignore', # version
				'perl-Config-Std' => 'ignore', # version
				'perl-Compress-Zlib' => 'ignore', # moved to IO-Compress
				'perl-Devel-StackTrace' => 'ignore', # version
				'perl-Class-Std-Utils' => 'ignore', # version
				'perl-Class-Std-Fast' => 'ignore', # version
				'perl-Class-Std' => 'ignore', # version
				'perl-Test-Builder-Tester' => 'ignore', # moved to Test-Simple
				'perl-Class-DBI' => 'ignore', # version
				'perl-version' => 'ignore', # version
				'perl-SDL' => 'ignore', # Major upgrade
				'perl-Parse-RecDescent' => 'ignore', # version
				'perl-WWW-Shorten' => 'ignore', # version
				'perl-ExtUtils-ParseXS' => 'ignore', # version
				'perl-ExtUtils-CBuilder' => 'ignore', # version
				'perl-AI-FANN' => 'ignore', # doesn't compile
				'perl-any' => 'ignore', # version
				'perl-WebService-MusicBrainz' => 'ignore', # Requires: perl(XML::LibXML) >= 1.63 really..
				'perl-Test-Class' => 'ignore', # Requires perl(Test::Simple) >= 0.78
				'perl-XML-Compile' => 'ignore', # req XML::Compile::Tester which requires new Sys::Log

	 };


my $crap;
foreach my $name (@rpmnames) {
	next if $ignore->{$name} eq 'ignore' ;
	my $filename = "$directory/$name/$name.spec";
	if ( -e  $filename ){
			my $ok = "OK";
			my $localverison =  version_from_spec($filename);
			my $release =  release_from_spec($filename);
			my $cpan_name = $name;
			$cpan_name =~ s/^perl-//g;
			$cpan_name =~ s/-/::/g;
			my $module = CPAN::Shell->expand("Module",$cpan_name);
			my $cpan_version=0;
			$cpan_version=$module->cpan_version if ( defined($module) );
			if ( $cpan_version =~ m/v(.*)/ ) { $cpan_version = $1 };
			$ok = "UPGRADE" if ( $cpan_version gt $localverison ); 
			$ok = "OK" if ( $cpan_version eq "undef" ); 
			printf("%-30.30s | Localversion: %s - %s | Cpanversion %s | %s \n",$cpan_name, $localverison, $release, $cpan_version, $ok);
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

