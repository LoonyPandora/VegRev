###############################################################################
# models/admin.pl
# =============================================================================
# Version:    Vegetable Revolution 3.0
# Released:   1st June 2009
# Revision:   $Rev$
# Copyright:  James Aitken <http://www.loonypandora.com>
###############################################################################

use strict;

sub _do_add_poll {
    my ($poll_id, $question) = @_;

    my $query = qq{
INSERT INTO polls (thread_id, question, user_id, poll_start_time)
VALUES (?, ?, ?, ?)
    };

    $vr::dbh->prepare($query)
        ->execute($poll_id, $question, $vr::viewer{'user_id'}, $vr::config{'gmtime'});
}

sub _do_add_poll_options {
    my ($poll_id, $poll_option) = @_;

    my $query = qq{
INSERT INTO poll_options (thread_id, poll_option)
VALUES (?, ?)
    };

    $vr::dbh->prepare($query)->execute($poll_id, $poll_option);
}

sub _show_poll {
    my ($poll_id) = @_;

    my $query = qq{
SELECT polls.thread_id, polls.question, poll_options.poll_option, COUNT(poll_votes.poll_option_id) AS num_votes, poll_options.poll_option_id AS option_id
FROM polls
LEFT JOIN poll_options as poll_options ON poll_options.thread_id = polls.thread_id
LEFT JOIN poll_votes as poll_votes ON poll_votes.poll_option_id = poll_options.poll_option_id
WHERE polls.thread_id = ?
GROUP BY poll_options.poll_option_id, polls.thread_id, polls.question, poll_options.poll_option
    };

    $vr::poll_loop = $vr::dbh->prepare($query);
    $vr::poll_loop->execute($poll_id);
    $vr::poll_loop->bind_columns(\(@vr::poll_loop{ @{ $vr::poll_loop->{NAME_lc} } }));
}

sub _do_delete_vote {
    my ($poll_id, $user_id) = @_;

    my $query = qq{
DELETE FROM poll_votes
WHERE thread_id = ?
AND user_id  = ?
    };

    $vr::dbh->prepare($query)->execute($poll_id, $user_id);
}

sub _do_delete_poll_votes {
    my ($poll_id) = @_;

    my $query = qq{
DELETE FROM poll_votes
WHERE thread_id = ?
    };

    $vr::dbh->prepare($query)->execute($poll_id);
}

sub _do_delete_poll_options {
    my ($poll_id) = @_;

    my $query = qq{
DELETE FROM poll_options
WHERE thread_id = ?
    };

    $vr::dbh->prepare($query)->execute($poll_id);
}

sub _do_delete_poll {
    my ($poll_id) = @_;

    my $query = qq{
DELETE FROM polls
WHERE thread_id = ?
    };

    $vr::dbh->prepare($query)->execute($poll_id);
}

sub _do_vote_poll {
    my ($poll_id, $poll_option) = @_;

    my $query = qq{
INSERT INTO poll_votes (thread_id, user_id, poll_option_id, poll_ip_address)
VALUES (?, ?, ?, ?)
    };

    $vr::dbh->prepare($query)
        ->execute($poll_id, $vr::viewer{'user_id'}, $poll_option, $vr::viewer{'ip_address'});
}

sub _poll_info {
    my ($thread) = @_;

    my $query = qq{
SELECT COUNT(1) AS max_votes, polls.question, polls.private, (SELECT user_id FROM poll_votes WHERE poll_votes.user_id = ? AND poll_votes.thread_id = ?) AS has_voted, polls.user_id AS poll_starter_id
FROM polls
LEFT JOIN poll_options as poll_options ON poll_options.thread_id = polls.thread_id
LEFT JOIN poll_votes as poll_votes ON poll_votes.poll_option_id = poll_options.poll_option_id
WHERE polls.thread_id = ?
GROUP BY poll_options.poll_option_id, polls.question, polls.private, polls.user_id
ORDER BY max_votes DESC
LIMIT 1
    };

    my $static = $vr::dbh->prepare($query);
    $static->execute($vr::viewer{'user_id'}, $thread, $thread);
    $static->bind_columns(\(@vr::db{ @{ $static->{NAME_lc} } }));
    $static->fetch;
}

1;
