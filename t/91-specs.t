use v6;
use Test;

my $specs-dir = '../mustache-spec/specs';
my @specs = load-specs $specs-dir;
#diag sprintf("%-40s\t%s", $_<name desc>) for @specs;
plan @specs + 1;
todo "You must clone github.com/mustache/spec into '{$specs-dir.path.directory}'"
    if @specs == 0;

ok @specs > 0 && @specs[0]<template>, "Specs files located";

use Template::Mustache;
for @specs {
    is Template::Mustache.render($_<template>, $_<data>, :partials($_<partials>)),
        $_<expected>,
        "$_<name>: $_<desc>";
}

done;


# TODO Factor this out, it's used in 9*-specs*.t
sub load-specs (Str $specs-dir) {
    use JSON::Tiny;
    my ($file, $start) = '', 0;
    # Uncomment and tweak to run a specific test
    #$file = 'partials'; $start = 0;
    my @files;
    try {
        @files = dir($specs-dir).grep({/$file\.json$/}).sort;
        CATCH { return (); }
    }
    # NYI
    @files .= grep({$_ !~~ /lambda/});

    diag "Reading spec files from '$specs-dir'";
    gather for @files {
        my $json = slurp $_;
        my %data = from-json $json;
        diag "- $_: {+%data<tests>}";
        take @(%data<tests>)[$start..*];
    }
}

# vim:set ft=perl6: