package VegRev::Inbox;

use v5.14;
use feature 'unicode_strings';
use utf8;
use common::sense;

use Moo;
use Data::Dumper;
use Dancer qw(:moose);
use Dancer::Plugin::Database;

use Carp;



# From the DB
has threads => ( is => 'rw' );
has offset  => ( is => 'rw' );
has limit   => ( is => 'rw' );
has user_id => ( is => 'rw' );


sub BUILD {
    my $args = shift;

    my $thread_sth = database->prepare(q{
        SELECT DISTINCT(user_id), display_name, usertext, avatar, timestamp AS last_updated
        FROM
            (SELECT sent_from AS user_id, TIMESTAMP
            FROM mail
            WHERE sent_to = ?

            UNION ALL

            SELECT sent_to AS user_id, TIMESTAMP
            FROM mail
            WHERE sent_from = ?

            ORDER BY TIMESTAMP DESC) AS inbox_view
        LEFT JOIN USER ON user_id = user.id
        GROUP BY user_id
        ORDER BY timestamp DESC
        LIMIT ?, ?
    });
    $thread_sth->execute($args->user_id, $args->user_id, $args->offset, $args->limit);

    # As an arrayref to keep the ordering
    my $threads = $thread_sth->fetchall_arrayref({});

    # No threads
    if (scalar @$threads < 1) {
        redirect '/';
        return;
    }

    $args->threads($threads);
}


1;
