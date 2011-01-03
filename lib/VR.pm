package VR;
use Dancer ':syntax';

our $VERSION = '0.1';

# Perl stuff
use common::sense;

# Dancer Plugins
use Dancer::Plugin::Database;
use Dancer::Plugin::Params::Normalization;


load (
  'VR/Route.pm',
  'VR/Route/Forum.pm',
  'VR/Route/User.pm',
);


true;
