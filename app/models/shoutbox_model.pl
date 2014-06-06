###############################################################################
# models/shoutbox.pl
# =============================================================================
# Version:    Vegetable Revolution 3.0
# Released:   1st June 2009
# Revision:   $Rev$
# Copyright:  James Aitken <http://www.loonypandora.com>
###############################################################################

use strict;

sub _list_shoutbox_messages {
    my ($limit) = @_;

    my $query = qq{
SELECT shoutbox.shout_id, shoutbox.shout_time, shoutbox.shout_body, users.user_name, users.display_name, special_groups.spec_group_color
FROM shoutbox
INNER JOIN users AS users ON users.user_id = shoutbox.user_id
LEFT JOIN special_groups AS special_groups ON users.spec_group_id = special_groups.spec_group_id
AND shoutbox.shout_deleted != '1'
ORDER BY shoutbox.shout_time DESC
LIMIT ?
};

    $vr::loop = $vr::dbh->prepare($query);
    $vr::loop->execute($limit);
    $vr::loop->bind_columns(\(@vr::loop{ @{ $vr::loop->{NAME_lc} } }));
}

sub _shout_total {

    # TODO: Add a trigger to increase the count in the stats board, instead of the COUNT

    my $query = qq{
SELECT COUNT(shout_id) AS shout_count
FROM shoutbox
	};

    my $static = $vr::dbh->prepare($query);
    $static->execute();
    $static->bind_columns(\(@vr::db{ @{ $static->{NAME_lc} } }));
    $static->fetch;
}

sub _list_shoutbox_archives {
    my ($offset, $limit) = @_;

    my $query = qq{
SELECT shoutbox.shout_id, shoutbox.shout_time, shoutbox.shout_body, shoutbox.shout_ip_address, users.user_id, users.user_name, users.display_name, users.avatar, users.user_shout_num, special_groups.spec_group_color
FROM shoutbox
INNER JOIN users AS users ON users.user_id = shoutbox.user_id
LEFT JOIN special_groups AS special_groups ON users.spec_group_id = special_groups.spec_group_id
AND shoutbox.shout_deleted != '1'
ORDER BY shoutbox.shout_time DESC
LIMIT ?, ?
};

    $vr::loop = $vr::dbh->prepare($query);
    $vr::loop->execute($offset, $limit);
    $vr::loop->bind_columns(\(@vr::loop{ @{ $vr::loop->{NAME_lc} } }));
}

sub _write_shout {
    my ($user_id, $message_body) = @_;

    my $query = qq{
INSERT INTO shoutbox (user_id, shout_ip_address, shout_time, shout_deleted, shout_body)
VALUES (?, ?, ?, ?, ?)
	};

    #  die "$query - ($user_id, $vr::viewer{'ip_address'}, $vr::config{'gmtime'}, '0', $message_body)";

    $vr::dbh->prepare($query)
        ->execute($user_id, $vr::viewer{'ip_address'}, $vr::config{'gmtime'}, '0', $message_body);

}

1;
