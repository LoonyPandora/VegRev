#!/usr/bin/env perl

# Use vendor libs in preference to system defaults
use lib 'vendor/Dancer/lib';
use lib 'vendor/Dancer-Template-MojoTemplate/lib';

use Dancer;
use VR;

use Plack::Builder;
use Plack::Middleware::Session;
use Plack::Session::Store::DBI;


my $app = sub {
  my $env     = shift;
  my $request = Dancer::Request->new($env);
  Dancer->dance($request);
};

builder {

  enable 'Debug', 
    panels => [
#      qw(Environment Response Timer Memory Parameters Dancer::Version Dancer::Settings Profiler::NYTProf)
      qw(Timer Memory Dancer::Version Response Parameters)
    ];
  
#  enable 'Debug::DBIProfile', profile => 2;
#  enable 'Debug::DBITrace', level => 2;

  enable 'Session',
    store => Plack::Session::Store::DBI->new(
      dbh           => DBI->connect( 'DBI:mysql:database=development;host=127.0.0.1;port=3306', 'vegrev', 'password' ),
      serializer    => sub { Dancer::Serializer::JSON::to_json(@_); },
      deserializer  => sub { Dancer::Serializer::JSON::from_json(@_); },
    );

  $app;
};
