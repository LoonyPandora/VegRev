package VegRev;
use Dancer ':syntax';

our $VERSION = '0.1';

# Perl stuff
use common::sense;

# Dancer Plugins
use Dancer::Plugin::Database;
use Dancer::Plugin::Params::Normalization;


get '/' => sub {
    template 'index';
};

true;
