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
has tag      => ( is => 'rw' );
has threads  => ( is => 'rw' );
has tag_meta => ( is => 'rw' );


sub new_from_tag {
    my $args = shift;

    my $thread_sth = database->prepare(q{
        SELECT thread.id, subject, url_slug, UNIX_TIMESTAMP(last_updated) AS last_updated, user_name, display_name, avatar, usertext,
            (SELECT count(*) FROM message WHERE message.thread_id = thread.id) AS replies,
            UNIX_TIMESTAMP(thread_read_receipt.timestamp) AS last_read
        FROM thread
        LEFT JOIN user ON latest_post_user_id = user.id
        LEFT JOIN thread_read_receipt ON thread_read_receipt.user_id = '1'
            AND thread_read_receipt.thread_id = thread.id
        WHERE thread.id IN (SELECT thread_id
        FROM tagged_thread
        LEFT JOIN tag ON tagged_thread.tag_id = tag.id
        WHERE group_id IN (1, 2, 4)
        AND tag_id != 2)
        ORDER BY last_updated DESC
        LIMIT ?, ?
    });

    $thread_sth->execute($args->{offset}, $args->{limit});

    # As an arrayref to keep the ordering
    my $threads = $thread_sth->fetchall_arrayref({});

    # No threads
    if (scalar @$threads < 1) {
        redirect '/';
        return;
    }

    # Gets the thread id's from the returned array
    my @thread_ids = map { $_->{id} } @$threads;

    my $tag_sth = database->prepare(q{
        SELECT thread_id, tag.title
        FROM tagged_thread
        LEFT JOIN tag ON tagged_thread.tag_id = tag.id
        WHERE thread_id IN (} . join(',', map('?', @thread_ids)) . q{)
    });
    $tag_sth->execute(@thread_ids);

    my $taglist = $tag_sth->fetchall_hashref(['thread_id', 'title']);

    for my $thread (@$threads) {
        push @{$thread->{tags}}, keys $taglist->{ $thread->{id} };
    }

    # Required for pagination
    my $meta_sth = database->prepare(q{
        SELECT COUNT(DISTINCT thread_id) AS total_threads
        FROM tagged_thread
        LEFT JOIN tag ON tagged_thread.tag_id = tag.id
        WHERE group_id IN (1, 2, 4)
        AND tag_id != 2
    });
    $meta_sth->execute();

    my $meta = $meta_sth->fetchall_arrayref({})->[0];

    return VegRev::Forum->new({
        tag_meta => $meta,
        threads  => $threads,
    });
}


1;
