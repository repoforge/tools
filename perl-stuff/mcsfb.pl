# Meiers cpan spec file builder 


use strict;

use CPANPLUS::Backend;
use CPAN::FindDependencies;
use Data::Dumper;
use LWP::Simple;

use POSIX;


#use YAML::Tiny;
use YAML::Syck;
use version;



my $name = $ARGV[0];
$name =~ s/::/-/g;

my $cb      = CPANPLUS::Backend->new or die loc("Could not create new CPANPLUS::Backend object");                
my $module = $cb->parse_module( module => $name ) or die "Cannot make a module object out of $name\n";

my $package_name = $module->package_name();

if ( lc($name) ne lc($package_name)) { die "Given Name does not match package name\nSeareched for $name but found $package_name\n"; };

my $json_url = "http://search.cpan.org/src/" . $module->author->cpanid . "/" . $name . "-" . $module->package_version . "/META.json";
my $yaml_url = "http://search.cpan.org/src/" . $module->author->cpanid . "/" . $name . "-" . $module->package_version . "/META.yml";
my $yaml_file;
$yaml_file = get($json_url) or $yaml_file = get($yaml_url);
print "DEBUG: $yaml_file\n";
my $results = Load($yaml_file);


print "# \$Id\$\n";
print "# Upstream: " . $module->author->author . " <" . $module->author->email .">\n";
print "\n";
print '%define perl_vendorlib %(eval "`%{__perl} -V:installvendorlib`"; echo $installvendorlib)'."\n";
print '%define perl_vendorarch %(eval "`%{__perl} -V:installvendorarch`"; echo $installvendorarch)'."\n";
print "%define real_name $name\n";
print "\n";
print "Summary: " . $results->{'abstract'} . "\n";
print "Name: perl-$name\n";
print "Version: " . $module->package_version ."\n";
print "Release: 1%{?dist}\n";
print "License: ". $results->{'license'} ."\n";
print "Group: Applications/CPAN\n";
print "URL: http://search.cpan.org/dist/$name\n";
print "\n";
print "Source: http://search.cpan.org/CPAN/" . $module->path . "/" . $name . "-%{version}.tar.gz\n";
print "BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root\n";
print "BuildArch: noarch\n";
print "\n";


# Merge build_requires and requires in one hash
my %merged = ();
while ( my ($k,$v) = each(%{$results->{'build_requires'}}) ) {
    $merged{$k} = $v;
}
while ( my ($k,$v) = each(%{$results->{'requires'}}) ) {
    $merged{$k} = $v;
}


# Print BuildRequires
foreach my $key (sort keys %merged )  {
		if ( $key eq "perl" ) {
			print "BuildRequires: $key >= " . $merged{$key} . "\n";
		} else {
			print "BuildRequires: perl($key)";
			if ( $merged{$key} != 0 ) {
					print  " >= " . $merged{$key};
			}  
			print "\n";
		}
}

# Print Requires
foreach my $key (sort keys %{$results->{'requires'}} )  {
		if ( $key eq "perl" ) {
			print "Requires: $key >= " .$results->{'requires'}{$key} . "\n";
		} else {
			print "Requires: perl($key)";
			if ( $results->{'requires'}{$key} != 0 ) {
					print  " >= " . $results->{'requires'}{$key};
			}  
			print "\n";
		}
}


print "\n%filter_from_requires /^perl*/d\n";
print "%filter_setup\n";


#foreach my $key (sort keys %{$results->{'recommends'}} )  {
#                if ( $key eq "perl" ) {
#                        print "BuildRequires: $key >= " .$results->{'recommends'}{$key} . "\n";
#                } else {
#                        print "BuildRequires: perl($key)";
#                        if ( $results->{'requires'}{$key} != 0 ) {
#                                        print  " >= " . $results->{'recomemnds'}{$key};
#                        }
#                        print "\n";
#                }
#}

my $class = $ARGV[0];
$class =~ s/::/\//g;

$class = $class . ".pm";

print "\n";
print "\n";
print "%description\n";
print "\n";
print "%prep\n";
print "%setup -n %{real_name}-%{version}\n";
print "\n";
print "%build\n";
print "%{__perl} Makefile.PL INSTALLDIRS=\"vendor\" PREFIX=\"%{buildroot}%{_prefix}\"\n";
print "%{__make} %{?_smp_mflags}\n";
print "%{__make} %{?_smp_mflags} man\n";
print "\n";
print "%install\n";
print "%{__rm} -rf %{buildroot}\n";
print "%{__make} pure_install\n";
print "\n";
print "### Clean up buildroot\n";
print "find %{buildroot} -name .packlist -exec %{__rm} {} \\;\n";
print "\n";
print "%clean\n";
print "%{__rm} -rf %{buildroot}\n";
print "\n";
print "%files\n";
print "%defattr(-, root, root, 0755)\n";
print "%doc Changes MANIFEST META.yml README\n";
print "%doc %{_mandir}/man3/$ARGV[0].3pm*\n";
print "%dir %{perl_vendorlib}/\n";
print "%{perl_vendorlib}/$class\n";
print "\n";
print "%changelog\n";

setlocale(LC_ALL, "en_US");
my $dayname=strftime ("%A", gmtime);
$dayname=substr($dayname,0,3);
my $day=strftime ("%d", gmtime);
my $mon=strftime ("%b", gmtime);
my $year=strftime ("%Y", gmtime);

print "* $dayname $mon $day $year Christoph Maser <cmr.financial.com> - " . $module->package_version . "-1\n";
print "- initial package\n";
