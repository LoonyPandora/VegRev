package VR;
use Dancer ':syntax';

our $VERSION = '0.1';

# Perl stuff
use common::sense;

# Dancer Plugins
use Dancer::Plugin::Database;
use Dancer::Plugin::Params::Normalization;

# Extra Routes
use VR::Route;
use VR::Route::Forum;
use VR::Route::User;


before sub {
  # We are already in transactional mode
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
