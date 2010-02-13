###############################################################################
# VR::Model::Forum.pm
# =============================================================================
# Version:      Vegetable Revolution 4.0
# Released:     1st January 2010
# Author:       James Aitken <http://www.loonypandora.com/>
###############################################################################

package VR::Model::Forum;

use strict;
use warnings;
use base 'Exporter';
use vars '@EXPORT_OK';

@EXPORT_OK = qw();


sub load_boards {
  my ($section, $category) = @_;

	my $sql = q|
SELECT boards.board_id, boards.board_title, boards.board_description, boards.board_message_total, boards.board_thread_total, boards.board_last_post_time, boards.board_last_post_id, boards.board_icon, threads.thread_subject
FROM boards
LEFT JOIN threads as threads ON threads.thread_id = boards.board_last_post_id
WHERE boards.section_id = ?
AND boards.category_id = ?
ORDER BY boards.board_position ASC
|;

  my @bind = (
    $section,
    $category,
  );

	my $static_sql = q|
SELECT categories.category_id, categories.category_title
FROM categories
WHERE categories.category_id = ?
LIMIT 1
|;

  my @static_bind = (
    $category,
  );

  &VR::Util::fetch_db(\$static_sql, \@static_bind, \$VR::db->{$category});
  &VR::Util::read_db(\$sql, \@bind, \$VR::sth{$category}, \$VR::db->{$category});
}

sub load_threads {
  my ($board_id, $offset, $limit) = @_;

	my $sql = q|
SELECT threads.thread_first_message_id, threads.thread_id, threads.thread_subject, threads.thread_last_message_time, threads.thread_views, threads.thread_messages, threads.thread_icon, start.user_name AS start_user_name, last.user_name AS last_user_name, start.display_name AS start_display_name, last.display_name AS last_display_name, start.avatar, threads.thread_star, threads.thread_locked, poll.thread_id AS poll_id, start_spec_group.group_color AS start_group_color, last_spec_group.group_color AS last_group_color
FROM threads
INNER JOIN users as start ON start.user_id = threads.thread_starter_id
INNER JOIN users as last ON last.user_id = threads.thread_last_user_id
LEFT JOIN user_groups AS start_spec_group ON (CASE WHEN start.group_id = 0 OR start.group_id IS NULL THEN (SELECT group_id FROM user_groups WHERE user_groups.posts_required <= start.user_post_num ORDER BY user_groups.posts_required DESC LIMIT 1) ELSE start.group_id END) = start_spec_group.group_id
LEFT JOIN user_groups AS last_spec_group ON (CASE WHEN last.group_id = 0 OR last.group_id IS NULL THEN (SELECT group_id FROM user_groups WHERE user_groups.posts_required <= last.user_post_num ORDER BY user_groups.posts_required DESC LIMIT 1) ELSE last.group_id END) = last_spec_group.group_id
LEFT JOIN polls as poll ON poll.thread_id = threads.thread_id
WHERE threads.board_id = ?
AND (threads.thread_deleted IS NULL OR threads.thread_deleted != '1')
AND (threads.thread_subject IS NOT NULL OR threads.thread_deleted != '')
|;

  my $sticky_sql = $sql;
  
  if (!$offset || $offset == 0) {
    $sticky_sql .= q|AND threads.thread_star > '1' ORDER BY threads.thread_star DESC LIMIT ?, ?|;
    $sql .= q|AND (threads.thread_star IS NULL OR threads.thread_star = '0') ORDER BY threads.thread_last_message_time DESC LIMIT ?, ?|;
  } else {
    $sql .= q|AND (threads.thread_star IS NULL OR threads.thread_star = '0') ORDER BY threads.thread_last_message_time DESC LIMIT ?, ?|;
  }

  my @bind = (
    $board_id,
    $offset,
    $limit,
  );

	my $static_sql = q|
SELECT boards.board_id, boards.board_title, boards.board_description, boards.board_thread_total
FROM boards
WHERE boards.board_id = ?
LIMIT 1
|;

  my @static_bind = (
    $board_id,
  );

  &VR::Util::fetch_db(\$static_sql, \@static_bind, \$VR::db->{'board'});
  
  if (!$offset || $offset == 0) {
    &VR::Util::read_db(\$sticky_sql, \@bind, \$VR::sth{'sticky_threads'}, \$VR::db->{'sticky_threads'});  
  }

  &VR::Util::read_db(\$sql, \@bind, \$VR::sth{'threads'}, \$VR::db->{'threads'});  
}

sub load_messages {
  my ($thread_id, $offset, $limit) = @_;

	my $sql = q|
SELECT messages.message_id, messages.thread_id, messages.message_ip, messages.message_time, messages.edited_time, messages.editor_id, messages.message_body, messages.attachment, users.user_name, users.user_id, users.display_name, users.avatar, users.signature, users.user_post_num, users.usertext, user_groups.group_color, user_groups.group_image
FROM messages
LEFT JOIN users AS users ON users.user_id = messages.user_id
LEFT JOIN user_groups AS user_groups ON user_groups.group_id = (CASE WHEN users.group_id = 0 OR users.group_id IS NULL THEN (SELECT group_id FROM user_groups WHERE user_groups.posts_required <= users.user_post_num ORDER BY user_groups.posts_required DESC LIMIT 1) ELSE users.group_id
END)
WHERE messages.thread_id = ?
AND messages.message_deleted != '1'
LIMIT ?, ?
|;

  my @bind = (
    $thread_id,
    $offset,
    $limit,
  );

	my $static_sql = q|
SELECT threads.thread_id, threads.thread_subject, threads.thread_locked, threads.board_id, threads.thread_messages, boards.board_title
FROM threads
LEFT JOIN boards AS boards ON boards.board_id = threads.board_id
WHERE threads.thread_id = ?
LIMIT 1
|;

  my @static_bind = (
    $thread_id,
  );


  &VR::Util::fetch_db(\$static_sql, \@static_bind, \$VR::db->{'thread'});
  &VR::Util::read_db(\$sql, \@bind, \$VR::sth{'messages'}, \$VR::db->{'messages'}); 
}

sub load_thread_viewers {
  my ($thread_id) = @_;
 
	my $sql = q|
SELECT users.user_name, users.display_name, users.user_id, user_groups.group_color
FROM thread_readers
LEFT JOIN users AS users ON users.user_id = thread_readers.read_user_id
LEFT JOIN user_groups AS user_groups ON (CASE WHEN users.group_id = 0 OR users.group_id IS NULL THEN (SELECT group_id FROM user_groups WHERE user_groups.posts_required <= users.user_post_num ORDER BY user_groups.posts_required DESC LIMIT 1) ELSE users.group_id END) = user_groups.group_id
WHERE thread_readers.read_thread_id = ?
AND thread_readers.read_timestamp > ?
|;

  my @bind = (
    $thread_id,
    ($VR::TIMESTAMP - 300),
  );

  &VR::Util::read_db(\$sql, \@bind, \$VR::sth{'thread_info'}, \$VR::db->{'thread_info'}); 
}

sub write_thread_viewer {
  my ($thread_id, $user_id, $timestamp) = @_;

  if (!$thread_id) { $thread_id = $timestamp; }

  my $sql = q|
INSERT INTO thread_readers
VALUES(?, ?, ?, ?)
ON DUPLICATE KEY UPDATE read_timestamp = ?
|;

  my @bind = (
    "$thread_id-$user_id",
    $thread_id,
    $user_id,
    $timestamp,
    $timestamp
  );

  &VR::Util::write_db(\$sql, \@bind);

}

sub write_board_viewer {
  my ($board_id, $user_id, $timestamp) = @_;

  my $sql = q|
INSERT INTO board_readers
VALUES(?, ?, ?, ?)
ON DUPLICATE KEY UPDATE read_timestamp = ?
|;

  my @bind = (
    "$board_id-$user_id",
    $board_id,
    $user_id,
    $timestamp,
    $timestamp
  );

  &VR::Util::write_db(\$sql, \@bind);
}





sub post_thread {
  my ($user_id, $board_id, $thread_id, $message_ip, $timestamp, $attachment, $message_body, $subject) = @_;

  $VR::dbh->begin_work;
  eval {
    &VR::Model::Forum::write_message($user_id, $thread_id, $message_ip, $timestamp, $attachment, $message_body);
    my $message_id = $VR::dbh->{mysql_insertid};

    &VR::Model::Forum::write_thread($thread_id, $subject, $message_id, $board_id, $user_id);
    &VR::Model::Forum::update_totals($timestamp, $board_id, $thread_id, $user_id);
    &VR::Model::Session::update_session($user_id, $timestamp, $message_ip);

    $VR::dbh->commit;
  };
	if ($@) {
		die "Failed: ".(caller(0))[3]."\nLine: ".(caller(0))[2]."\nReason: $@";
		eval { $VR::dbh->rollback while $VR::dbh->transaction_level; };
	}
  
}

sub post_reply {
  my ($user_id, $board_id, $thread_id, $message_ip, $timestamp, $attachment, $message_body, $thread) = @_;

  $VR::dbh->begin_work;
  eval {
    &VR::Model::Forum::write_message($user_id, $thread_id, $message_ip, $timestamp, $attachment, $message_body);
    &VR::Model::Forum::update_totals($timestamp, $board_id, $thread_id, $user_id);
    &VR::Model::Session::update_session($user_id, $timestamp, $message_ip);

    $VR::dbh->commit;
  };
	if ($@) {
		die "Failed: ".(caller(0))[3]."\nLine: ".(caller(0))[2]."\nReason: $@";
		eval { $VR::dbh->rollback while $VR::dbh->transaction_level; };
	}
}



sub update_totals {
  my ($timestamp, $board_id, $thread_id, $user_id) = @_;

	my $sql = qq|UPDATE boards
SET board_message_total = board_message_total + 1, board_last_post_time = ?, board_last_post_id = ?
WHERE board_id = ?;
	|;
	
	my $sql2 = qq|UPDATE threads
SET thread_last_message_time = ?, thread_last_user_id = ?, thread_messages = thread_messages + 1
WHERE thread_id = ?;
	|;
	
	my $sql3 = qq|UPDATE users
SET user_post_num = user_post_num + 1
WHERE users.user_id = ?;
	|;
	
	my $sql4 = qq|UPDATE forum_stats
SET forum_total_posts = forum_total_posts + 1;
	|;
	
	my @bind  = ($timestamp, $thread_id, $board_id);
	my @bind2 = ($timestamp, $user_id, $thread_id);
	my @bind3 = ($user_id);
	my @bind4 = ();
	
	&VR::Util::write_db(\$sql, \@bind);
	&VR::Util::write_db(\$sql2, \@bind2);
	&VR::Util::write_db(\$sql3, \@bind3);
	&VR::Util::write_db(\$sql4, \@bind4);
}

sub write_message {
  my ($user_id, $thread_id, $message_ip, $timestamp, $attachment, $message_body) = @_;

	my $sql = qq|
INSERT INTO messages (user_id, thread_id, message_ip, message_time, attachment, message_body)
VALUES (?, ?, ?, ?, ?, ?);
|;

	my @bind = ($user_id, $thread_id, $message_ip, $timestamp, $attachment, $message_body);

  &VR::Util::write_db(\$sql, \@bind);
}

sub write_thread {
  my ($thread_id, $subject, $message_id, $board_id, $user_id) = @_;

	my $sql = qq|
INSERT INTO threads (thread_id, thread_subject, board_id, thread_starter_id, thread_first_message_id)
VALUES (?, ?, ?, ?, ?)
	|;

	my $sql2 = qq|
UPDATE boards
SET board_thread_total = board_thread_total + 1
WHERE boards.board_id = ?
	|;

	my @bind  = ($thread_id, $subject, $board_id, $user_id, $message_id);
	my @bind2 = ($board_id);

	&VR::Util::write_db(\$sql, \@bind);
	&VR::Util::write_db(\$sql2, \@bind2);
}


1;


