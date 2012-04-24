package VegRev::Chat;

use v5.14;
use feature 'unicode_strings';
use utf8;
use common::sense;

use Moo;
use Data::Dumper;
use Dancer qw(:moose);
use Dancer::Plugin::Database;

use Carp;


has messages => ( is => 'rw' );


sub new_from_id {
    my $args = shift;

    my $thread_sth = database->prepare(q{
        SELECT mail.id, ip_address, UNIX_TIMESTAMP(timestamp) AS timestamp, body, sender.display_name, sender.user_name, sender.avatar
        FROM mail
        LEFT JOIN USER AS sender ON sent_from = sender.id
        WHERE sent_from IN (?, ?)
        AND sent_to IN (?, ?)
        ORDER BY timestamp desc
        LIMIT ? ,?
    });
    $thread_sth->execute(
        $args->{user_id}, $args->{chat_id}, 
        $args->{user_id}, $args->{chat_id},
        $args->{offset},  $args->{limit}
    );

    # As an arrayref to keep the ordering
    my $messages = $thread_sth->fetchall_arrayref({});

    # No threads
    if (scalar @$messages < 1) {
        redirect '/';
        return;
    }

    return VegRev::Chat->new({
        messages => $messages,
    });
}

1;
