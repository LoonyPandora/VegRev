###############################################################################
# forum_model.pl
# =============================================================================
# Version:    Vegetable Revolution 3.0
# Released:   1st June 2009
# Revision:   $Rev$
# Copyright:  James Aitken <http://loonypandora.co.uk>
###############################################################################

use strict;

sub _board_list {
    my ($category, $guest_view, $vip_view, $mods_view) = @_;

    my $query = qq{
SELECT boards.board_id, boards.board_title, boards.board_description, boards.board_message_total, boards.board_thread_total, boards.board_last_post_time, boards.board_last_post_id, boards.board_icon, threads.thread_subject
FROM boards
LEFT JOIN threads as threads ON threads.thread_id = boards.board_last_post_id
WHERE boards.category_id = ?
AND boards.mods_only = ?
ORDER BY boards.board_position ASC
};

    $vr::loop = $vr::dbh->prepare($query);
    $vr::loop->execute($category, $mods_view);
    $vr::loop->bind_columns(\(@vr::loop{ @{ $vr::loop->{NAME_lc} } }));
}

sub _thread_list {
    my ($board_id, $offset, $limit, $order_by) = @_;

    my $query = qq{
SELECT threads.thread_first_message_id, threads.thread_id, threads.thread_subject, threads.thread_last_message_time, threads.thread_views, threads.thread_messages, threads.thread_icon, start.user_name AS start_user_name, last.user_name AS last_user_name, start.display_name AS start_display_name, last.display_name AS last_display_name, start.avatar, threads.thread_star, threads.thread_locked, poll.thread_id AS poll_id,
start_spec_group.spec_group_color AS start_spec_group_color, last_spec_group.spec_group_color AS last_spec_group_color
FROM threads
INNER JOIN users as start ON start.user_id = threads.thread_starter_id
INNER JOIN users as last ON last.user_id = threads.thread_last_user_id
LEFT JOIN special_groups AS start_spec_group ON start.user_id = start_spec_group.spec_group_id
LEFT JOIN special_groups AS last_spec_group ON last.user_id = last_spec_group.spec_group_id
LEFT JOIN polls as poll ON poll.thread_id = threads.thread_id
WHERE threads.board_id = ?
AND threads.thread_deleted != '1'
AND threads.thread_subject != ''
$order_by
LIMIT ?, ?
};

    $vr::loop = $vr::dbh->prepare($query);
    $vr::loop->execute($board_id, $offset, $limit);
    $vr::loop->bind_columns(\(@vr::loop{ @{ $vr::loop->{NAME_lc} } }));
}

sub _message_list {
    my ($thread_id, $offset, $limit) = @_;

    my $query = qq{
SELECT messages.message_id, messages.thread_id, messages.message_ip, messages.message_time, messages.edited_time, messages.editor_id, messages.message_body, messages.attachment, users.user_name, users.user_id, users.display_name, users.avatar, users.signature, users.user_private, users.user_post_num, users.usertext, (SELECT post_group_id FROM post_groups WHERE post_groups.posts_required <= users.user_post_num ORDER BY post_groups.posts_required DESC LIMIT 1) AS user_post_group_id, special_groups.spec_group_image, special_groups.spec_group_color, post_groups.post_group_image, editor.user_name AS editor_user_name, editor.display_name AS editor_display_name
FROM messages
INNER JOIN users AS users ON users.user_id = messages.user_id
LEFT JOIN users AS editor ON editor.user_id = messages.editor_id
LEFT JOIN special_groups AS special_groups ON users.spec_group_id = special_groups.spec_group_id
LEFT JOIN post_groups AS post_groups ON post_groups.post_group_id = (SELECT post_group_id FROM post_groups WHERE post_groups.posts_required <= users.user_post_num ORDER BY post_groups.posts_required DESC LIMIT 1)
WHERE messages.thread_id = ?
AND messages.message_deleted != '1'
LIMIT ?, ?
};

    $vr::loop = $vr::dbh->prepare($query);
    $vr::loop->execute($thread_id, $offset, $limit);
    $vr::loop->bind_columns(\(@vr::loop{ @{ $vr::loop->{NAME_lc} } }));
}

sub _category_info {
    my ($category, undef) = @_;

    my $query = qq{
SELECT categories.category_id, categories.category_title, categories.category_description
FROM categories
WHERE categories.category_id = ?
LIMIT 1
    };

    my $static = $vr::dbh->prepare($query);
    $static->execute($category);
    $static->bind_columns(\(@vr::db{ @{ $static->{NAME_lc} } }));
    $static->fetch;
}

sub _board_info {
    my ($board, undef) = @_;

    my $query = qq{
SELECT boards.board_id, boards.board_title, boards.board_description, boards.category_id, boards.vip_only, boards.mods_only, boards.board_guest_hidden, boards.no_new_user_threads, boards.board_thread_total
FROM boards
WHERE boards.board_id = ?
LIMIT 1
    };

    my $static = $vr::dbh->prepare($query);
    $static->execute($board);
    $static->bind_columns(\(@vr::db{ @{ $static->{NAME_lc} } }));
    $static->fetch;
}

sub _thread_info {
    my ($thread, undef) = @_;

    my $query = qq{
SELECT threads.thread_id, threads.board_id, threads.thread_subject, threads.thread_messages, threads.thread_icon, threads.thread_locked, threads.thread_star, threads.thread_deleted, threads.thread_last_message_time, threads.thread_first_message_id, boards.board_title, poll.thread_id AS poll_id
FROM threads
LEFT JOIN boards AS boards ON boards.board_id = threads.board_id
LEFT JOIN polls as poll ON poll.thread_id = threads.thread_id
WHERE threads.thread_id = ?
LIMIT 1
    };

    my $static = $vr::dbh->prepare($query);
    $static->execute($thread);
    $static->bind_columns(\(@vr::db{ @{ $static->{NAME_lc} } }));
    $static->fetch;
}

sub _show_photo {
    my ($thread_id, $offset, $limit) = @_;

    my $query = qq{
SELECT messages.message_id, messages.thread_id, messages.message_ip, messages.message_time, messages.edited_time, messages.editor_id, messages.message_body, messages.attachment, users.user_name, users.user_id, users.display_name, users.avatar, users.signature, users.user_post_num, users.usertext, (SELECT post_group_id FROM post_groups WHERE post_groups.posts_required <= users.user_post_num ORDER BY post_groups.posts_required DESC LIMIT 1) AS user_post_group_id, special_groups.spec_group_image, special_groups.spec_group_color, post_groups.post_group_image
FROM messages
INNER JOIN users AS users ON users.user_id = messages.user_id
LEFT JOIN special_groups AS special_groups ON users.spec_group_id = special_groups.spec_group_id
LEFT JOIN post_groups AS post_groups ON post_groups.post_group_id = (SELECT post_group_id FROM post_groups WHERE post_groups.posts_required <= users.user_post_num ORDER BY post_groups.posts_required DESC LIMIT 1)
WHERE messages.thread_id = ?
AND messages.message_deleted != '1'
LIMIT ?, ?
};

    $vr::loop = $vr::dbh->prepare($query);
    $vr::loop->execute($thread_id, $offset, $limit);
    $vr::loop->bind_columns(\(@vr::loop{ @{ $vr::loop->{NAME_lc} } }));

}

sub _recent_posts {
    my ($category, $amount, $inc_vip, $inc_mod, $inc_members, $order_by) = @_;
    if (!$amount || $amount > 20) { $amount = 20; }

    &_simple_board_list;

    my @quoted_boards = ();
    while ($vr::board_loop->fetchrow_arrayref) {
        if (!$inc_vip     && $vr::board_loop{'vip_only'})           { next; }
        if (!$inc_mod     && $vr::board_loop{'mods_only'})          { next; }
        if (!$inc_members && $vr::board_loop{'board_guest_hidden'}) { next; }
        if ($category ne $vr::board_loop{'category_id'}) { next; }
        my $tmp = $vr::dbh->quote($vr::board_loop{'board_id'});
        push(@quoted_boards, $tmp);
    }

    my $quoted_board_string = join(',', @quoted_boards);

    my $query = qq{
SELECT thread_last_message_time, threads.thread_first_message_id, threads.thread_id, threads.thread_subject, boards.category_id, boards.board_id
FROM threads
LEFT JOIN boards AS boards ON threads.board_id = boards.board_id
WHERE boards.board_id IN ($quoted_board_string)
AND threads.thread_subject != ''
AND threads.thread_deleted != '1'
$order_by
LIMIT ?
};

    $vr::loop = $vr::dbh->prepare($query);
    $vr::loop->execute($amount);
    $vr::loop->bind_columns(\(@vr::loop{ @{ $vr::loop->{NAME_lc} } }));
}

sub _upcoming_birthdays {
    my ($day, $month) = @_;

    my $query = qq{
SELECT users.user_id, users.user_name, users.user_id, users.display_name, users.birthday, special_groups.spec_group_color
FROM users
LEFT JOIN special_groups AS special_groups ON users.spec_group_id = special_groups.spec_group_id
WHERE birthday LIKE ?
LIMIT 100
};

    $vr::loop = $vr::dbh->prepare($query);
    $vr::loop->execute("%$month-$day");
    $vr::loop->bind_columns(\(@vr::loop{ @{ $vr::loop->{NAME_lc} } }));
}

sub _get_news {

    my $query = qq{
SELECT threads.thread_id, threads.thread_subject, threads.thread_starter_id, threads.thread_messages, threads.thread_icon, users.user_name, users.display_name, users.avatar, messages.message_body
FROM threads
INNER JOIN users AS users ON users.user_id = threads.thread_starter_id
INNER JOIN messages AS messages ON messages.message_id = threads.thread_first_message_id
WHERE threads.board_id = 'news'
AND threads.thread_deleted != '1'
ORDER BY threads.thread_id DESC
LIMIT 2
};

    $vr::loop = $vr::dbh->prepare($query);
    $vr::loop->execute();
    $vr::loop->bind_columns(\(@vr::loop{ @{ $vr::loop->{NAME_lc} } }));
}

sub _write_threads {
    my ($subject, $message_id, $board_id, $icon, $user_id) = @_;

    my $query = qq{
INSERT INTO threads (thread_id, thread_subject, board_id, thread_starter_id, thread_locked, thread_star, thread_deleted, thread_views, thread_messages, thread_icon, thread_last_message_time, thread_last_user_id, thread_first_message_id)
VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    };

    my $query_two = qq{
UPDATE boards
SET board_message_total = board_message_total + 1, board_thread_total = board_thread_total + 1
WHERE boards.board_id = ?
    };

    $vr::dbh->prepare($query)
        ->execute($vr::config{'gmtime'}, $subject, $board_id, $user_id, '0',
        $vr::config{'gmtime'}, '0', '0', '1', $icon, $vr::config{'gmtime'}, $user_id,
        $message_id);
    $vr::dbh->prepare($query_two)->execute($board_id);
}

sub _write_message {
    my ($user_id, $thread_id, $message_ip, $attachment, $message_body) = @_;

    my $query = qq{
INSERT INTO messages (user_id, thread_id, message_ip, message_time, attachment, message_body)
VALUES (?, ?, ?, ?, ?, ?)
    };

    my $query_two = qq{
UPDATE users SET user_post_num = user_post_num + 1 WHERE users.user_id = ?
};

    my $query_three = qq{
UPDATE threads SET thread_messages = thread_messages + 1 WHERE threads.thread_id = ?
};

    $vr::dbh->prepare($query_two)->execute($vr::viewer{'user_id'});
    $vr::dbh->prepare($query_three)->execute($thread_id);
    $vr::dbh->prepare($query)->execute($user_id, $thread_id, $message_ip, $vr::config{'gmtime'}, $attachment, $message_body);
}

sub _update_board_total_messages {
    my ($board_id, $thread_id) = @_;

    my $query = qq{
UPDATE boards
SET board_message_total = board_message_total + 1, board_last_post_time = ?, board_last_post_id = ?
WHERE board_id = ?
    };

    $vr::dbh->prepare($query)->execute($vr::config{'gmtime'}, $thread_id, $board_id);
}

sub _update_threads {
    my ($thread_id, $user_id, $starred) = @_;

    if   ($starred == 2147483647) { $starred = 2147483647; }
    else                          { $starred = $vr::config{'gmtime'}; }

    my $query = qq{
    UPDATE threads
    SET thread_last_message_time = ?, thread_last_user_id = ?, thread_star = ?
    WHERE thread_id = ?
    };

    $vr::dbh->prepare($query)->execute($vr::config{'gmtime'}, $user_id, $starred, $thread_id);
}

sub _write_thread_viewers {
    if ($vr::viewer{'is_guest'})    { return; }

    eval {
        my $query = qq{
            INSERT INTO thread_read_receipts (thread_id, user_id, read_time)
            VALUES (?, ?, NOW())
            ON DUPLICATE KEY UPDATE read_time = NOW()
        };

        $vr::dbh->prepare($query)->execute(
            $vr::GET{'id'}, $vr::viewer{'user_id'}
        );

        $vr::dbh->commit;
    };
    if ($@) {
        die "Transaction aborted because $@";
        eval { $vr::dbh->rollback };
    }

}

sub _write_board_viewers {
    if ($vr::viewer{'is_guest'})    { return; }

    eval {
        my $query = qq{
            INSERT INTO board_read_receipts (board_id, user_id, read_time)
            VALUES (?, ?, NOW())
            ON DUPLICATE KEY UPDATE read_time = NOW()
        };

        $vr::dbh->prepare($query)->execute(
            $vr::GET{'id'}, $vr::viewer{'user_id'}
        );

        $vr::dbh->commit;
    };
    if ($@) {
        die "Transaction aborted because $@";
        eval { $vr::dbh->rollback };
    }

}

sub _read_thread_viewers {
    my $query = qq{
        SELECT users.user_id, users.user_name, users.display_name, special_groups.spec_group_color, thread_read_receipts.read_time
        FROM users
        LEFT JOIN special_groups AS special_groups ON users.spec_group_id = special_groups.spec_group_id
        LEFT JOIN thread_read_receipts ON users.user_id = thread_read_receipts.user_id 
        WHERE thread_read_receipts.thread_id = ?
        AND thread_read_receipts.read_time >= NOW() - INTERVAL 15 MINUTE
    };

    $vr::loop = $vr::dbh->prepare($query);
    $vr::loop->execute($vr::GET{'id'});
    $vr::loop->bind_columns(\(@vr::loop{ @{ $vr::loop->{NAME_lc} } }));
}


sub _single_message {
    my ($message_id) = @_;

    my $query = qq{
SELECT messages.message_id, messages.message_body, messages.user_id, messages.thread_id, messages.message_time, users.user_name, users.display_name
FROM messages
INNER JOIN users as users ON messages.user_id = users.user_id
WHERE messages.message_id = ?
};

    my $static = $vr::dbh->prepare($query);
    $static->execute($message_id);
    $static->bind_columns(\(@vr::db{ @{ $static->{NAME_lc} } }));
    $static->fetch;
    $vr::db{'message_body'} =~ s/\[br\]/\n/g;
}

sub _do_save_message {
    my ($message_id) = @_;

    my $query_one = qq{
UPDATE messages
SET message_body = ?, edited_time = ?, editor_id = ?
WHERE message_id = ?
};

    $vr::dbh->prepare($query_one)
        ->execute($vr::POST{'message'}, $vr::config{'gmtime'}, $vr::viewer{'user_id'},
        $message_id);
}

sub _do_delete_message {
    my ($message_id, $thread_id, $board_id) = @_;

    my $query_one = qq{
UPDATE messages
SET message_deleted = 1
WHERE message_id = ?
};

    my $query_two = qq{
UPDATE threads
SET thread_messages = thread_messages - 1, thread_last_message_time = (SELECT message_time FROM messages WHERE thread_id = ? AND message_deleted !=1 ORDER BY message_id DESC LIMIT 1), thread_last_user_id = (SELECT user_id FROM messages WHERE thread_id = ? AND message_deleted !=1 ORDER BY message_id DESC LIMIT 1)
WHERE thread_id = ?
};

    my $query_three = qq{
UPDATE boards
SET board_message_total = board_message_total - 1, board_last_post_time = (SELECT thread_last_message_time FROM threads WHERE board_id = ? AND thread_deleted !=1 ORDER BY thread_last_message_time DESC LIMIT 1), board_last_post_id = (SELECT thread_id FROM threads WHERE board_id = ? AND thread_deleted !=1 ORDER BY thread_last_message_time DESC LIMIT 1)
WHERE board_id = ?
};

    $vr::dbh->prepare($query_one)->execute($message_id);
    $vr::dbh->prepare($query_two)->execute($thread_id, $thread_id, $thread_id);
    $vr::dbh->prepare($query_three)->execute($board_id, $board_id, $board_id);
}

sub _do_delete_thread {
    my ($thread_id, $board_id) = @_;

    my $query_one = qq{
UPDATE threads
SET thread_deleted = 1
WHERE thread_id = ?
};

    my $query_two = qq{
UPDATE boards
SET board_thread_total = board_thread_total - 1, board_message_total = board_message_total - (SELECT thread_messages FROM threads WHERE thread_id = ? LIMIT 1), board_last_post_time = (SELECT thread_last_message_time FROM threads WHERE board_id = ? AND thread_deleted !=1 ORDER BY thread_last_message_time DESC LIMIT 1), board_last_post_id = (SELECT thread_id FROM threads WHERE board_id = ? AND thread_deleted !=1 ORDER BY thread_last_message_time DESC LIMIT 1)
WHERE board_id = ?
};

    $vr::dbh->prepare($query_one)->execute($thread_id);
    $vr::dbh->prepare($query_two)->execute($thread_id, $board_id, $board_id, $board_id);
}

sub _do_edit_thread {
    my ($thread_id, $new_subject, $number_replies) = @_;

    my $query = qq{
UPDATE threads
SET thread_subject = ?, thread_messages = ?
WHERE thread_id = ?
};

    $vr::dbh->prepare($query)->execute($new_subject, $number_replies, $thread_id);

}

sub _do_move_thread {
    my ($thread_id, $board_id) = @_;

    my $query = qq{
UPDATE threads
SET board_id = ?
WHERE thread_id = ?
};

    $vr::dbh->prepare($query)->execute($board_id, $thread_id);
}

sub _do_lock_thread {
    my ($thread_id) = @_;
    my $query = qq{
UPDATE threads
SET thread_locked = ?
WHERE thread_id = ?
};

    $vr::dbh->prepare($query)->execute($vr::config{'gmtime'}, $thread_id);
}

sub _do_unlock_thread {
    my ($thread_id) = @_;

    my $query = qq{
UPDATE threads
SET thread_locked = '0'
WHERE thread_id = ?
};

    $vr::dbh->prepare($query)->execute($thread_id);
}

sub _do_star_thread {
    my ($thread_id) = @_;
    my $query = qq{
UPDATE threads
SET thread_star = '2147483647'
WHERE thread_id = ?
};

    $vr::dbh->prepare($query)->execute($thread_id);
}

sub _do_unstar_thread {
    my ($thread_id) = @_;

    my $query = qq{
UPDATE threads
SET thread_star = thread_last_message_time
WHERE thread_id = ?
};

    $vr::dbh->prepare($query)->execute($thread_id);
}

sub _simple_board_list {
    my $query = qq{
SELECT boards.board_id, boards.board_title, boards.category_id, boards.board_position, boards.vip_only, boards.mods_only, boards.board_guest_hidden
FROM boards
ORDER BY boards.board_position
  };

    $vr::board_loop = $vr::dbh->prepare($query);
    $vr::board_loop->execute();
    $vr::board_loop->bind_columns(\(@vr::board_loop{ @{ $vr::board_loop->{NAME_lc} } }));
}

sub _redirect_to_new {
    my ($thread_id) = @_;

    my $query = qq{
        SELECT COUNT(messages.message_id) AS read_messages
        FROM messages
        LEFT JOIN thread_read_receipts ON thread_read_receipts.thread_id = messages.thread_id
        WHERE messages.thread_id = ?
        AND thread_read_receipts.user_id = ?
        AND messages.message_deleted != 1
        AND (messages.message_time < UNIX_TIMESTAMP(thread_read_receipts.read_time) OR thread_read_receipts.read_time IS NULL)
    };

    my $static = $vr::dbh->prepare($query);
    $static->execute($thread_id, $vr::viewer{'user_id'});
    $static->bind_columns(\(@vr::db{ @{ $static->{NAME_lc} } }));
    $static->fetch;

    return $vr::db{'read_messages'};
}

sub _get_site_stats {

    my $query = qq{
SELECT forum_total_posts, forum_total_threads, forum_total_photos, forum_total_shouts, forum_total_users, forum_max_online, forum_max_online_time
FROM forum_stats
ORDER BY forum_max_online_time DESC
LIMIT 1
    };

    my $static = $vr::dbh->prepare($query);
    $static->execute();
    $static->bind_columns(\(@vr::db{ @{ $static->{NAME_lc} } }));
    $static->fetch;
}

sub _update_site_stats {
    my ($type) = @_;
    my $query = undef;

    if ($type eq 'post') {
        $query = qq{
UPDATE forum_stats
SET forum_total_posts = forum_total_posts + 1
    };
    } elsif ($type eq 'thread') {
        $query = qq{
UPDATE forum_stats
SET forum_total_threads = forum_total_threads + 1
    };
    } elsif ($type eq 'photo') {
        $query = qq{
UPDATE forum_stats
SET forum_total_photos = forum_total_photos + 1, forum_total_threads = forum_total_threads + 1, forum_total_posts = forum_total_posts + 1
    };
    } elsif ($type eq 'shout') {
        $query = qq{
UPDATE forum_stats
SET forum_total_shouts = forum_total_shouts + 1
    };
    } elsif ($type eq 'user') {
        $query = qq{
UPDATE forum_stats
SET forum_total_users = forum_total_users + 1
    };
    }

    $vr::dbh->prepare($query)->execute();

}

sub _set_site_stats {
    my ($num_online) = @_;

    my $query = qq{
UPDATE forum_stats
SET forum_max_online = ?,
forum_max_online_time = ?
    };

    $vr::dbh->prepare($query)->execute($num_online, $vr::config{'gmtime'});
}

1;

