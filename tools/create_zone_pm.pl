#!/usr/bin/perl
use strict;
use warnings;
use Data::Dumper;
use FindBin;

my $zone_tab = $ARGV[0] or die "Usage: create_zone_pm.pl zone.tab\n";
my $pm_path = "$FindBin::Bin/../lib/DateTime/TimeZone/FromCountry/Zone.pm";

my $zone = read_zone_tab($zone_tab);
generate_pm($zone, $pm_path);

sub read_zone_tab {
    my $zone_tab = shift;

    my $zone;
    open my $fh, "<", $zone_tab;
    while (<$fh>) {
        next if /^\#/;
        chomp;
        my($cc, $coord, $tz, $comment) = split /\t/, $_;
        push @{$zone->{$cc}}, $tz;
    }

    return $zone;
}

sub generate_pm {
    my($zone, $pm_path) = @_;

    my $perl_data = Data::Dumper::Dumper($zone);
    $perl_data =~ s/^\$VAR1 = //;

    open my $fh, ">", $pm_path or die "$pm_path: $!";
    print $fh sprintf(<<'TEMPLATE', $perl_data);
# This file is auto-generated by tools/create_zone_pm.pl
# DO NOT EDIT!
package DateTime::TimeZone::FromCountry::Zone;
use strict;
use base qw( Exporter );
our @EXPORT_OK = qw($Map);

our $Map = %s

1;
TEMPLATE
    close $fh;
}

