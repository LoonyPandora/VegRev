package VegRev::Forum;

use v5.14;
use feature 'unicode_strings';
use utf8;
use common::sense;

use Moo;
use Data::Dumper;
use Dancer qw(:moose);
use Dancer::Plugin::Database;
use Carp;


# A thread object should conceptually be a collection of VegRev::Message objects
# But that would mean extra DB queries, and essentially I would be creating an ORM


# From the DB
has id            => ( is => 'rw' );
has subject       => ( is => 'rw' );
has url_slug      => ( is => 'rw' );
has icon          => ( is => 'rw' );
has start_date    => ( is => 'rw' );
has last_updated  => ( is => 'rw' );
has replies       => ( is => 'rw' );
has started_by    => ( is => 'rw' );
has latest_poster => ( is => 'rw' );
has messages      => ( is => 'rw' );
has tags          => ( is => 'rw' );





1;
