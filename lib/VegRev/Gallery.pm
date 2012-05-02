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
has attachments => ( is => 'rw' );


sub new_from_tag {
    my $args = shift;

    my $attachment_sth = database->prepare(q{
        SELECT attachment.id, message_id, url, user.display_name, user.user_name, user.avatar, user.usertext, thread_id, timestamp, body
        FROM attachment
        LEFT JOIN message ON attachment.message_id = message.id
        LEFT JOIN user ON user_id = user.id
        ORDER BY attachment.id DESC
        LIMIT ?, ?
    });
    $attachment_sth->execute($args->{offset}, $args->{limit});

    # As an arrayref to keep the ordering
    my $attachments = $attachment_sth->fetchall_arrayref({});

    for my $attachment (@{$attachments}) {        
        if ($attachment->{url} =~ m/(:?\.jpg|\.jpeg|\.gif|\.png)$/) {
            $attachment->{type} = 'image';
        } else {
            $attachment->{type} = 'youtube';
        }
    }

    # die Data::Dump::dump $attachments;

    return VegRev::Gallery->new({
        attachments => $attachments,
    });
}


1;
