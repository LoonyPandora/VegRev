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
        SELECT message.id, message.body, UNIX_TIMESTAMP(message.timestamp) AS timestamp, user.user_name, user.display_name, user.usertext, user.signature, user.avatar, INET_NTOA(message.ip_address) AS ip_address
        FROM message
        LEFT JOIN user ON user.id = user_id
        WHERE message.thread_id = ?
        AND message.deleted != 1
        ORDER BY message.id ASC
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

    # No messages
    if (keys %$messages < 1) {
        redirect '/';
        return;
    }

    my $quote_sth = database->prepare(q{
        SELECT quote.id, message_id, message_id_quoted, quote.body, UNIX_TIMESTAMP(message.timestamp) AS message_timestamp, user.user_name, user.display_name, user.avatar, user.usertext
        FROM quote
        LEFT JOIN message ON message_id_quoted = message.id
        LEFT JOIN user ON message.user_id = user.id
        WHERE message_id IN (} . join(',', map('?', keys %$messages)) . q{)
    });
    $quote_sth->execute(keys %$messages);

    # Add the quotes to the message pseudo object by matching message_id's
    for my $quote (@{ $quote_sth->fetchall_arrayref({}) }) {
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


sub mark_as_read {
    my $self = shift;

    return unless session('user_id');

    my $msg_sth = database->prepare(q{
        INSERT INTO thread_read_receipt (thread_id, user_id, timestamp)
        VALUES (?, ?, NOW())
        ON DUPLICATE KEY
        UPDATE timestamp = NOW();
    });
    $msg_sth->execute($self->id, session('user_id'));

    return $self;
}



sub add_message {
    my $self = shift;
    my $args = shift;
    
    # TODO: Error handling
    # return unless session('user_id');

    my $msg_sth = database->prepare(q{
        INSERT INTO message (user_id, thread_id, ip_address, timestamp, body, raw_body)
        VALUES (?, ?, INET_ATON(?), NOW(), ?, ?)
    });

    my $thread_sth = database->prepare(q{
        UPDATE thread
        SET last_updated = NOW(), latest_post_user_id = ?
        WHERE id = ?
        LIMIT 1
    });

    # We are always in a transaction - so this works.
    $msg_sth->execute(
        session('user_id'), $args->{thread_id},  session('ip_address'),
        $args->{body},      $args->{raw_body}
    );

    $thread_sth->execute(
        session('user_id'), session('user_id')
    );

    return $self;
}


1;
