#!/usr/bin/env perl

use Plack::App::WrapCGI;

return Plack::App::WrapCGI->new(
    script  => "./app/forums.pl",
    execute => 1
)->to_app;
