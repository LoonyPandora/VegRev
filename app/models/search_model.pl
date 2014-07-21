###############################################################################
# search_controller.pl
# =============================================================================
# Version:    Vegetable Revolution 3.0
# Released:   1st June 2009
# Revision:   $Rev$
# Copyright:  James Aitken <http://loonypandora.co.uk>
###############################################################################

use strict;

sub _show_search_results {
    my ($search, $limit, $begin_time, $end_time, $board_string, $offset) = @_;

    $search = $vr::dbh->quote("%" . $search . "%");

    my $query = qq{
SELECT DISTINCT messages.message_id, messages.thread_id, messages.message_body, messages.message_time, threads.thread_subject, threads.board_id, boards.category_id, users.user_id, users.user_name, users.display_name, users.avatar, special_groups.spec_group_color
FROM messages
INNER JOIN threads AS threads ON threads.thread_id = messages.thread_id
INNER JOIN boards AS boards ON threads.board_id = boards.board_id
INNER JOIN users AS users ON users.user_id = messages.user_id
LEFT JOIN special_groups AS special_groups ON users.spec_group_id = special_groups.spec_group_id
WHERE messages.message_body LIKE $search
AND boards.category_id = 'forum'
AND boards.vip_only != '1'
AND boards.mods_only != '1'
AND messages.message_deleted != '1'
AND messages.message_time <= ? AND messages.message_time  >= ?
AND threads.board_id IN ($board_string)
ORDER BY messages.message_time DESC
LIMIT ?, ?
};

    $vr::loop = $vr::dbh->prepare($query);
    $vr::loop->execute($begin_time, $end_time, $offset, $limit);
    $vr::loop->bind_columns(\(@vr::loop{ @{ $vr::loop->{NAME_lc} } }));
}

sub _show_search_info {
    my ($search, $begin_time, $end_time, $board_string) = @_;

    $search = $vr::dbh->quote("%" . $search . "%");

    my $query = qq{
SELECT COUNT(DISTINCT messages.thread_id) as total_results
FROM messages
INNER JOIN threads AS threads ON threads.thread_id = messages.thread_id
INNER JOIN boards AS boards ON threads.board_id = boards.board_id
WHERE messages.message_body LIKE $search
AND boards.category_id = 'forum'
AND boards.vip_only != '1'
AND boards.mods_only != '1'
AND messages.message_deleted != '1'
AND messages.message_time <= ? AND messages.message_time  >= ?
AND threads.board_id IN ($board_string)
LIMIT 1
};

    my $static = $vr::dbh->prepare($query);
    $static->execute($begin_time, $end_time);
    $static->bind_columns(\(@vr::db{ @{ $static->{NAME_lc} } }));
    $static->fetch;

}

1;
