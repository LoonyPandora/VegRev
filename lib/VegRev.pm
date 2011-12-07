package VegRev;

use v5.14;
use feature 'unicode_strings';
use utf8;
use common::sense;

use Dancer ':syntax';

use Time::HiRes qw/time/;

use Dancer::Plugin::Database;
use Data::Dumper;

use Carp;
use VegRev::User;
use VegRev::Thread;


our $VERSION = '0.0.1';


# Loads the viewer, should get the user ID from the cookie
# Should also do some authentication here
hook 'before' => sub {

    my $viewer = VegRev::User->new({ id => 1 })->load_extra;

    $viewer->store_session;

};


hook 'before_template' => sub {
    my $tokens = shift;

    # Add the Plack::Middleware::Assets used in all routes
#    $tokens->{base_css} = request->env->{'psgix.assets'}->[0];
#    $tokens->{base_js}  = request->env->{'psgix.assets'}->[1];

};




# Make sure we commit any open transactions. The entire request depends on it.
hook 'after' => sub {
  eval      { database->commit; };
  if ($@)   { die "Committing Transaction Failed: $@"; }
};


get '/' => sub {
    template 'index';
};



get qr{/(\d+)} => sub {
    my ($thread_id) = splat;

    my $thread = VegRev::Thread::new_from_id({
        id     => $thread_id,
        offset => 0,
        limit  => 100,
    });

    template 'thread', {
        template => 'thread',
        thread   => $thread
    };
};



1;
