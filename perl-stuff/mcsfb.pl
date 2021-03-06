# Meiers cpan spec file builder 


use strict;

use CPANPLUS::Backend;
use CPAN::Meta;
use Data::Dumper;
use LWP::Simple;

use POSIX;
use version;



my $name = $ARGV[0];
$name =~ s/::/-/g;

my $cb      = CPANPLUS::Backend->new or die loc("Could not create new CPANPLUS::Backend object");                
my $module = $cb->parse_module( module => $name ) or die "Cannot make a module object out of $name\n";

my $package_name = $module->package_name();
#print Dumper($package_name);

if ( lc($name) ne lc($package_name)) { die "Given Name does not match package name\nSeareched for $name but found $package_name\n"; };

my $json_url = "http://search.cpan.org/src/" . $module->author->cpanid . "/" . $package_name . "-" . $module->package_version . "/META.json";
my $yaml_url = "http://search.cpan.org/src/" . $module->author->cpanid . "/" . $package_name . "-" . $module->package_version . "/META.yml";
my $yaml_file;
my $meta;
if ( $yaml_file = get($json_url) ) {
	$meta = CPAN::Meta->load_json_string($yaml_file);
} else {
	$yaml_file = get($yaml_url);
	$meta = CPAN::Meta->load_yaml_string($yaml_file);
}

my $prereqs = $meta->effective_prereqs;

my $result = $prereqs->as_string_hash;

print "# \$Id\$\n";
print "# Upstream: " . $module->author->author . " <" . $module->author->email .">\n";
print "\n";
print '%define perl_vendorlib %(eval "`%{__perl} -V:installvendorlib`"; echo $installvendorlib)'."\n";
print '%define perl_vendorarch %(eval "`%{__perl} -V:installvendorarch`"; echo $installvendorarch)'."\n";
print "%define real_name $name\n";
print "\n";
print "Summary: " . $meta->{abstract} . "\n";
print "Name: perl-$name\n";
print "Version: " . $module->package_version ."\n";
print "Release: 1%{?dist}\n";
print "License: ".  &resolve_license($meta->{license}[0])  ."\n";
print "Group: Applications/CPAN\n";
print "URL: http://search.cpan.org/dist/$name/\n";
print "\n";
print "Source: http://search.cpan.org/CPAN/" . $module->path . "/" . $package_name . "-%{version}.tar.gz\n";
print "BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root\n";
print "BuildArch: noarch\n";
print "\n";


# Merge build_requires and requires in one hash
my %merged = ();
while ( my ($k,$v) = each(%{$result->{configure}->{requires}}) ) {
    $merged{$k} = $v;
}
while ( my ($k,$v) = each(%{$result->{build}->{requires}}) ) {
    $merged{$k} = $v;
}
while ( my ($k,$v) = each(%{$result->{runtime}->{requires}}) ) {
    $merged{$k} = $v;
}


# Print BuildRequires
foreach my $key (sort keys %{$result->{test}->{requires}} )  {
	print "BuildRequires: perl($key)";
	if ( $result->{test}->{requires}{$key} != 0 ) {
		print  " >= " . $result->{test}->{requires}{$key}
	}
	print "  # test dependency\n";
}



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
foreach my $key (sort keys %{$result->{runtime}->{requires}} )  {
		if ( $key eq "perl" ) {
			print "Requires: $key >= " .$result->{runtime}->{'requires'}{$key} . "\n";
		} else {
			print "Requires: perl($key)";
			if ( $result->{runtime}->{'requires'}{$key} != 0 ) {
					print  " >= " . $result->{runtime}->{'requires'}{$key};
			}  
			print "\n";
		}
}


print "\n";
print "### remove autoreq Perl dependencies\n";
print "%filter_from_requires /^perl.*/d\n";
print "%filter_setup\n";


my $class = $ARGV[0];
$class =~ s/::/\//g;

$class = $class . ".pm";

print "\n";
print "\n";
print "%description\n";
print $meta->{description} ."\n";
print "\n";
print "%prep\n";
print "%setup -n %{real_name}-%{version}\n";
print "\n";
print "%build\n";
print "%{__perl} Makefile.PL INSTALLDIRS=\"vendor\" PREFIX=\"%{buildroot}%{_prefix}\"\n";
print "%{__make} %{?_smp_mflags}\n";
print "%{__make} %{?_smp_mflags} test\n";
print "\n";
print "%install\n";
print "%{__rm} -rf %{buildroot}\n";
print "%{__make} pure_install\n";
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
print "%exclude %{perl_vendorarch}/auto/*/.packlist\n";
print "\n";
print "%changelog\n";

setlocale(LC_ALL, "en_US");
my $dayname=strftime ("%A", gmtime);
$dayname=substr($dayname,0,3);
my $day=strftime ("%d", gmtime);
my $mon=strftime ("%b", gmtime);
my $year=strftime ("%Y", gmtime);

print "* $dayname $mon $day $year Christoph Maser <cmaser.gmx.de> - " . $module->package_version . "-1\n";
print "- initial package\n";


sub resolve_license() {

	my $input = shift;
	my %license = (
		'perl_5' => 'Artistic/GPL' ,
	);
	
	if ( defined $license{$input} ) {
		return $license{$input};
	} else {
		return $input;
	}
}
