###############################################################################
# models/messages.pl
# =============================================================================
# Version:    Vegetable Revolution 3.0
# Released:   1st June 2009
# Revision:   $Rev$
# Copyright:  James Aitken <http://loonypandora.co.uk>
###############################################################################

use strict;

sub _list_private_conversations {
    my ($offset, undef) = @_;

    my $query = qq{
SELECT pm_threads.pm_thread_id, pm_threads.pm_subject, pm_threads.pm_last_msg_time, pm_threads.pm_total_messages, pm_threads.pm_sender_unread, pm_threads.pm_receiver_unread, pm_threads.pm_receiver_delete, pm_threads.pm_sender_delete, pm_threads.pm_sender_id AS sender_user_id, sender.display_name AS sender_display_name, sender.avatar AS sender_avatar, sender.user_name AS sender_user_name, send_spec_groups.spec_group_color AS sender_spec_group_color, receiver.user_id AS receiver_user_id, receiver.display_name AS receiver_display_name, receiver.avatar AS receiver_avatar, receiver.user_name AS receiver_user_name, rec_spec_groups.spec_group_color AS receiver_spec_group_color, last.user_id AS last_user_id, last.user_name AS last_user_name, last.display_name AS last_display_name, last_spec_groups.spec_group_color AS last_spec_group_color
FROM pm_threads
INNER JOIN users as sender ON sender.user_id = pm_threads.pm_sender_id
INNER JOIN users as receiver ON receiver.user_id = pm_threads.pm_receiver_id
INNER JOIN users as last ON last.user_id = pm_threads.pm_last_poster_id
LEFT JOIN special_groups AS send_spec_groups ON sender.spec_group_id = send_spec_groups.spec_group_id
LEFT JOIN special_groups AS rec_spec_groups ON receiver.spec_group_id = rec_spec_groups.spec_group_id
LEFT JOIN special_groups AS last_spec_groups ON last.spec_group_id = last_spec_groups.spec_group_id
WHERE (pm_threads.pm_receiver_id = ? AND pm_receiver_delete != '1')
OR (pm_threads.pm_sender_id = ? AND pm_sender_delete != '1')
ORDER BY pm_threads.pm_last_msg_time DESC
LIMIT ?, ?
};

    # Execute all queries, and bind to template variables.
    $vr::loop = $vr::dbh->prepare($query);
    $vr::loop->execute($vr::viewer{'user_id'}, $vr::viewer{'user_id'}, $offset, $vr::config{'pms_per_page'});
    $vr::loop->bind_columns(\(@vr::loop{ @{ $vr::loop->{NAME_lc} } }));
}

sub _list_sent_messages {
    my ($offset, undef) = @_;

    my $query = qq{
SELECT pm_messages.pm_message_id, pm_messages.pm_thread_id, pm_messages.pm_post_time, pm_messages.pm_body, threads.pm_subject, receiver.display_name, receiver.avatar, receiver.user_name, special_groups.spec_group_color
FROM pm_messages
INNER JOIN users as receiver ON receiver.user_id = pm_messages.pm_receiver_id
INNER JOIN pm_threads as threads ON threads.pm_thread_id = pm_messages.pm_thread_id
LEFT JOIN special_groups AS special_groups ON receiver.spec_group_id = special_groups.spec_group_id
WHERE pm_messages.pm_sender_id = ?
ORDER BY pm_messages.pm_post_time DESC
LIMIT ?, ?
};

    # Execute all queries, and bind to template variables.
    $vr::loop = $vr::dbh->prepare($query);
    $vr::loop->execute($vr::viewer{'user_id'}, $offset, $vr::config{'pms_per_page'});
    $vr::loop->bind_columns(\(@vr::loop{ @{ $vr::loop->{NAME_lc} } }));
}

sub _list_private_messages {
    my ($thread_id, $offset, $limit) = @_;

    my $query = qq{
SELECT pm_messages.pm_message_id, pm_messages.pm_thread_id, pm_messages.pm_ip, pm_messages.pm_post_time, pm_messages.pm_body, users.user_name, users.user_id, users.display_name, users.avatar, special_groups.spec_group_color
FROM pm_messages
INNER JOIN users AS users ON users.user_id = pm_messages.pm_sender_id
LEFT JOIN special_groups AS special_groups ON users.spec_group_id = special_groups.spec_group_id
WHERE pm_messages.pm_thread_id = ?
ORDER BY pm_messages.pm_post_time ASC
LIMIT ?, ?
};

    $vr::loop = $vr::dbh->prepare($query);
    $vr::loop->execute($thread_id, $offset, $limit);
    $vr::loop->bind_columns(\(@vr::loop{ @{ $vr::loop->{NAME_lc} } }));
}

sub _pm_thread_info {
    my ($thread, undef) = @_;
    my $static_query = qq{
SELECT pm_threads.pm_subject, pm_threads.pm_total_messages, send.user_id AS send_user_id, send.user_name AS send_user_name , send.user_id AS send_user_id, send.display_name AS send_display_name, send_spec_groups.spec_group_color AS send_spec_group_color, receive.user_id AS receive_user_id, receive.user_name AS receive_user_name, receive.user_id AS receive_user_id, receive.display_name AS receive_display_name, rec_spec_groups.spec_group_color AS receive_spec_group_color
FROM pm_threads
INNER JOIN users AS send ON send.user_id = pm_threads.pm_sender_id
INNER JOIN users AS receive ON receive.user_id = pm_threads.pm_receiver_id
LEFT JOIN special_groups AS send_spec_groups ON send.spec_group_id = send_spec_groups.spec_group_id
LEFT JOIN special_groups AS rec_spec_groups ON receive.spec_group_id = rec_spec_groups.spec_group_id
WHERE pm_threads.pm_thread_id = ?
LIMIT 1
    };

    my $static = $vr::dbh->prepare($static_query);
    $static->execute($thread);
    $static->bind_columns(\(@vr::db{ @{ $static->{NAME_lc} } }));
    $static->fetch;

}

sub _load_recipient {
    my ($user_id) = @_;

    my $static_query = qq{
SELECT users.user_id, users.user_name, users.display_name, special_groups.spec_group_id
FROM users
LEFT JOIN special_groups AS special_groups ON special_groups.spec_group_id = users.spec_group_id
WHERE users.user_id = ?
LIMIT 1
    };

    my $static = $vr::dbh->prepare($static_query);
    $static->execute($user_id);
    $static->bind_columns(\(@vr::db{ @{ $static->{NAME_lc} } }));
    $static->fetch;
}

sub _pm_list_info {
    my $static_query = qq{
SELECT COUNT(pm_thread_id) AS thread_num
FROM pm_threads
WHERE pm_threads.pm_receiver_id = ?
AND pm_threads.pm_receiver_delete != '1'
LIMIT 1
    };

    my $static = $vr::dbh->prepare($static_query);
    $static->execute($vr::viewer{'user_id'});
    $static->bind_columns(\(@vr::db{ @{ $static->{NAME_lc} } }));
    $static->fetch;
}

sub _get_pm_userlist {
    my $query = qq{
SELECT users.user_id, users.user_name, users.display_name, users.avatar
FROM users
WHERE users.user_deleted != '1'
ORDER BY users.user_name
    };

    $vr::loop = $vr::dbh->prepare($query);
    $vr::loop->execute();
    $vr::loop->bind_columns(\(@vr::loop{ @{ $vr::loop->{NAME_lc} } }));

}

sub _write_pm_message {
    my ($recipient, $thread) = @_;

    my $query = qq{
UPDATE pm_threads
SET pm_receiver_unread = pm_receiver_unread + 1, pm_total_messages = pm_total_messages + 1, pm_last_msg_time = ?, pm_last_poster_id = ?
WHERE pm_threads.pm_thread_id = ?
    };

    my $query_two = qq{
INSERT INTO pm_messages (pm_sender_id, pm_receiver_id, pm_thread_id, pm_ip, pm_post_time, pm_body)
VALUES (?, ?, ?, ?, ?, ?)
    };

    my $query_three = qq{
UPDATE pm_threads
SET pm_sender_unread = '0'
WHERE pm_threads.pm_thread_id = ?
AND pm_sender_id = ?
  };

    my $query_four = qq{
UPDATE pm_threads
SET pm_receiver_unread = '0'
WHERE pm_threads.pm_thread_id = ?
AND pm_receiver_id = ?
  };

    $vr::dbh->prepare($query)->execute($vr::config{'gmtime'}, $vr::viewer{'user_id'}, $thread);
    $vr::dbh->prepare($query_two)
        ->execute($vr::viewer{'user_id'}, $recipient, $thread, $vr::viewer{'ip_address'},
        $vr::config{'gmtime'}, $vr::POST{'message'});
    $vr::dbh->prepare($query_three)->execute($thread, $vr::viewer{'user_id'});
    $vr::dbh->prepare($query_four)->execute($thread, $vr::viewer{'user_id'});
}

sub _mark_pm_unread {
    my ($thread) = @_;

    my $query = undef;
    if ($vr::db{'receive_user_id'} eq $vr::viewer{'user_id'}) {
        $query = qq{
UPDATE pm_threads
SET pm_receiver_unread = '0'
WHERE pm_threads.pm_thread_id = ?
    };
    } else {
        $query = qq{
UPDATE pm_threads
SET pm_sender_unread = '0'
WHERE pm_threads.pm_thread_id = ?
    };
    }

    $vr::dbh->prepare($query)->execute($thread);
}

sub _do_delete_pm_thread {
    my ($thread_id) = @_;

    my $query_one = qq{
UPDATE pm_threads
SET pm_receiver_unread = 0, pm_receiver_delete = 1
WHERE pm_thread_id = ?
AND pm_receiver_id = ?
};

    my $query_two = qq{
UPDATE pm_threads
SET pm_sender_unread = 0, pm_sender_delete = 1
WHERE pm_thread_id = ?
AND pm_sender_id = ?
};

    $vr::dbh->prepare($query_one)->execute($thread_id, $vr::viewer{'user_id'});
    $vr::dbh->prepare($query_two)->execute($thread_id, $vr::viewer{'user_id'});
}

sub _write_pm_thread {
    my ($recipient) = @_;

    my $query = qq{
INSERT INTO pm_threads (pm_thread_id, pm_subject, pm_sender_id, pm_receiver_id, pm_last_msg_time, pm_last_poster_id, pm_sender_delete)
VALUES (?, ?, ?, ?, ?, ?, 0)
    };

    $vr::dbh->prepare($query)->execute(
        $vr::config{'gmtime'}, $vr::POST{'subject'},  $vr::viewer{'user_id'},
        $recipient,            $vr::config{'gmtime'}, $vr::viewer{'user_id'}
    );
}

1;
