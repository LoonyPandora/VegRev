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
has messages      => ( is => 'rw' );
has tags          => ( is => 'rw' );

has latest_user_name     => ( is => 'rw' );
has latest_display_name  => ( is => 'rw' );
has started_user_name    => ( is => 'rw' );
has started_display_name => ( is => 'rw' );


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
        SELECT thread.id, subject, url_slug, icon, UNIX_TIMESTAMP(start_date) AS start_date, UNIX_TIMESTAMP(last_updated) AS last_updated, (
            SELECT count(id)
            FROM message
            WHERE message.thread_id = thread.id
            AND message.deleted != 1
        ) AS replies, latest_user.user_name AS latest_user_name, latest_user.display_name AS latest_display_name, started_user.user_name AS started_user_name, started_user.display_name AS started_display_name
        FROM thread
        LEFT JOIN user AS latest_user  ON latest_post_user_id = latest_user.id
        LEFT JOIN user AS started_user ON started_by_user_id = started_user.id
        WHERE thread.id = ?
        LIMIT 1
    });
    $meta_sth->execute($args->{id});

    my $tag_sth = database->prepare(q{
        SELECT id, tag.title, tag.description, url_slug
        FROM tagged_thread
        LEFT JOIN tag ON tagged_thread.tag_id = tag.id
        WHERE tagged_thread.thread_id = ?
    });
    $tag_sth->execute($args->{id});

    my $meta     = $meta_sth->fetchall_arrayref({})->[0];
    my $tags     = $tag_sth->fetchall_arrayref({});
    my $messages = $msg_sth->fetchall_hashref('id');

    # No messages
    if (scalar keys %$messages < 1) {
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

    my $attachment_sth = database->prepare(q{
        SELECT id, message_id, url
        FROM attachment
        WHERE message_id IN (} . join(',', map('?', keys %$messages)) . q{)
    });
    $attachment_sth->execute(keys %$messages);

    # Add any attachments
    for my $attachment (@{ $attachment_sth->fetchall_arrayref({}) }) {        
        if ($attachment->{url} =~ m/(:?\.jpg|\.jpeg|\.gif|\.png)$/) {
            $attachment->{type} = 'image';
        } else {
            $attachment->{type} = 'youtube';
        }

        push(@{ $messages->{ $attachment->{message_id} }->{attachments} }, $attachment);
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


sub start_thread {
    my $self = shift;
    my $args = shift;
    
    # TODO: Error handling
    return unless session('user_id');

    my $thread_sth = database->prepare(q{
        INSERT INTO thread (subject, url_slug, icon, last_updated, started_by_user_id, latest_post_user_id, first_message_id)
        VALUES (?, ?, ?, NOW(), ?, ?, ?)
    });

    my $tag_sth = database->prepare(q{
        INSERT INTO tagged_thread (tag_id, thread_id)
        VALUES (?, ?)
    });

    my $url_slug = lc $args->{subject} =~ s/[^\w+-]//gr;

    # We are always in a transaction - so this works.
    $thread_sth->execute(
        $args->{subject}, $url_slug, "xx", session('user_id'),  session('user_id'),  session('user_id')
    );

    $self->id($thread_sth->{mysql_insertid});

    if (ref $args->{tags} eq 'ARRAY') {
        for my $tag (@{$args->{tags}}) {
            $tag_sth->execute(
                $tag, $self->id
            );
        }
    } else {
        $tag_sth->execute(
            $args->{tags}, $self->id
        );

    }
    
    # Now we've made the thread, make a message
    $self->add_message({
        thread_id   => $thread_sth->{mysql_insertid},
        raw_body    => $args->{raw_body},
        body        => $args->{body},
        plaintext   => $args->{plaintext},
        attachments => $args->{attachments},
    });

    return $self;
}



sub add_message {
    my $self = shift;
    my $args = shift;
    
    # TODO: Error handling
    return unless session('user_id');

    my $msg_sth = database->prepare(q{
        INSERT INTO message (user_id, thread_id, ip_address, timestamp, body, raw_body, plaintext)
        VALUES (?, ?, INET_ATON(?), NOW(), ?, ?, ?)
    });

    my $thread_sth = database->prepare(q{
        UPDATE thread
        SET last_updated = NOW(), latest_post_user_id = ?
        WHERE id = ?
        LIMIT 1
    });

    my $attach_sth = database->prepare(q{
        INSERT INTO attachment (message_id, url)
        VALUES (?, ?)
    });

    my $quote_sth = database->prepare(q{
        INSERT INTO quote (message_id, message_id_quoted, body)
        VALUES (?, ?, (SELECT plaintext FROM message WHERE id = ?))
    });

    # We are always in a transaction - so this works.
    $msg_sth->execute(
        session('user_id'), $args->{thread_id},  session('ip_address'),
        $args->{body},      $args->{raw_body},   $args->{plaintext}
    );

    $thread_sth->execute(
        session('user_id'), session('user_id')
    );

    # Multiple attachments are an arrayref from the POST params
    if (ref $args->{attachments} eq 'ARRAY') {
        for my $attachment (@{$args->{attachments}}) {        
            $attach_sth->execute(
                $msg_sth->{mysql_insertid}, $attachment
            );
        }
    } elsif (defined $args->{attachments}) {
        $attach_sth->execute(
            $msg_sth->{mysql_insertid}, $args->{attachments}
        );    
    }
    
    # insert the quotes
    if ($args->{quote}) {
        $quote_sth->execute(
            $msg_sth->{mysql_insertid}, $args->{quote}, $args->{quote}
        );
    }

    return $self;
}


1;
