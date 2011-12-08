package VegRev::Thread;

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


# Creates a new VegRev::Thread object from a thread ID
sub new_from_id {
    my $args = shift;

    my $msg_sth = database->prepare(q{
        SELECT message.id, message.body, user.user_name, user.display_name, user.usertext, user.signature, user.avatar, INET_NTOA(message.ip_address) AS ip_address
        FROM message
        LEFT JOIN user ON user.id = user_id
        WHERE message.thread_id = ?
        AND message.deleted != 1
        LIMIT ?, ?
    });
    $msg_sth->execute($args->{id}, $args->{offset}, $args->{limit});

    my $meta_sth = database->prepare(q{
        SELECT id, subject, url_slug, icon, UNIX_TIMESTAMP(start_date) AS start_date, UNIX_TIMESTAMP(last_updated) AS last_updated, (
            SELECT count(id)
            FROM message
            WHERE message.thread_id = thread.id
            AND message.deleted != 1
        ) AS replies
        FROM thread
        WHERE thread.id = ?
        LIMIT 1
    });
    $meta_sth->execute($args->{id});

    my $tag_sth = database->prepare(q{
        SELECT id, tag.title, url_slug
        FROM tagged_thread
        LEFT JOIN tag ON tagged_thread.tag_id = tag.id
        WHERE tagged_thread.thread_id = ?
    });
    $tag_sth->execute($args->{id});

    my $meta     = $meta_sth->fetchall_arrayref({})->[0];
    my $tags     = $tag_sth->fetchall_arrayref({});
    my $messages = $msg_sth->fetchall_hashref('id');

    my $quote_sth = database->prepare(q{
        SELECT quote.id, message_id, message_id_quoted, quote.body, UNIX_TIMESTAMP(message.timestamp) AS message_timestamp, user.user_name, user.display_name, user.avatar, user.usertext
        FROM quote
        LEFT JOIN message ON message_id_quoted = message.id
        LEFT JOIN user ON message.user_id = user.id
        WHERE message_id IN (} . join(',', map('?', keys %$messages)) . q{)
    });
    $quote_sth->execute(keys %$messages);

    my $quote_array = $quote_sth->fetchall_arrayref({});

    # Add the quotes to the message pseudo object by matching message_id's
    for my $quote (@$quote_array) {
        push(@{ $messages->{ $quote->{message_id} }->{quotes} }, $quote);
    }

    # We don't sort in SQL because we return a hashref to add the quotes
    # Hashes aren't sorted... So sort here in perl
    my @messages;
    for my $key (sort keys $messages) {
        push @messages, $messages->{$key};
    }

    return VegRev::Thread->new({
        %$meta,
        messages => \@messages,
        tags     => $tags,
    });
}




1;
