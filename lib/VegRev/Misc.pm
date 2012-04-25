package VegRev::Misc;

use v5.14;
use feature 'unicode_strings';
use utf8;
use common::sense;

use Dancer qw(:moose);
use Dancer::Plugin::Database;

use Data::Dump qw/dump/;



# Misc functions that aren't appropriate in the view



# Gets a list of user id's who have an active session
# Where active is timestamp within 30 minutes
sub currently_online {
    my $sth = database->prepare(q{
        SELECT session_data
        FROM session
        WHERE timestamp BETWEEN DATE_SUB(NOW(), INTERVAL 30 MINUTE) AND NOW()
        LIMIT 999
    });
    $sth->execute();

    my $online = $sth->fetchall_arrayref({});

    # We don't return the whole session in case we reveal something sensitive
    my @online;
    for my $session_json (@$online) {
        my $session = Dancer::Serializer::JSON::from_json($session_json->{session_data});

        if ($session->{user_id}) {
            push @online, {
                user_id      => $session->{user_id},
                user_name    => $session->{user_name},
                display_name => $session->{display_name},
                avatar       => $session->{avatar},
            };
        }
    }

    return \@online
}



1;
