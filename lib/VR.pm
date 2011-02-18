package VR;
use Dancer ':syntax';

our $VERSION = '0.0.1';

# Perl stuff
use common::sense;
use Time::HiRes qw/time/;

# Dancer Plugins
use Dancer::Plugin::Database;
use Dancer::Plugin::Params::Normalization;

# Extra Routes
use VR::Route;
#use VR::Route::Admin;
use VR::Route::Chat;
use VR::Route::Forum;
use VR::Route::Gallery;
use VR::Route::Inbox;
use VR::Route::Member;
use VR::Route::Photo;
use VR::Route::Poll;
use VR::Route::Profile;
use VR::Route::Search;
use VR::Route::Shoutbox;
use VR::Route::Search;
use VR::Route::Tag;
use VR::Route::Thread;

before sub {
  # We are already in transactional mode
  our $global = {};
  $global->{'start_time'} = time();

  session('user_id' => '1');
  session('start_time' => "$global->{'start_time'}");
};

after sub {
  # Make sure we commit any open transactions. The entire request depends on it.
  eval      { database->commit; };
  if ($@)   { die "Committing Transaction Failed: $@"; }
};


# Default route for 404
get qr{.*} => sub {
    status 'not_found';

    template 'index', {
        path => request->path
    };
};


true;
