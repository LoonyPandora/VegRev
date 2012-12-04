#!/usr/bin/env perl

use Dancer;
use VegRev;

use DBI;
use Plack::Builder;

my $app = sub {
    my $env = shift;

    my $request = Dancer::Request->new( env => $env );

    Dancer->dance($request);
};

builder {
    enable 'Debug', 
    panels => [
        qw(Timer Memory Dancer::Settings Response Parameters Environment Dancer::Version)
    ];
    
    enable 'Debug::DBIProfile', profile => 2;
    enable 'Debug::DBITrace',   level => 2;

    $app;
};
