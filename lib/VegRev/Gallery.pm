package VegRev::Gallery;

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
has pictures => ( is => 'rw' );


sub new_from_tag {
    my $args = shift;

    my $picture_sth = database->prepare(q{
        SELECT attachment.id, original_name, message_id, user.display_name, user.user_name, user.avatar, user.usertext, thread_id, timestamp, body
        FROM attachment
        LEFT JOIN message ON attachment.message_id = message.id
        LEFT JOIN user ON user_id = user.id
        ORDER BY attachment.id DESC
        LIMIT ?, ?
    });
    $picture_sth->execute($args->{offset}, $args->{limit});

    # As an arrayref to keep the ordering
    my $pictures = $picture_sth->fetchall_arrayref({});

    return VegRev::Gallery->new({
        pictures => $pictures,
    });
}


1;
