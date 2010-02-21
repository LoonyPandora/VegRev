###############################################################################
# VR::Model::Portal.pm
# =============================================================================
# Version:      Vegetable Revolution 4.0
# Released:     1st January 2010
# Author:       James Aitken <http://www.loonypandora.com/>
###############################################################################

package VR::Model::Portal;

use strict;
use warnings;
use base 'Exporter';
use vars '@EXPORT_OK';

@EXPORT_OK = qw();



sub load_recent_posts {
  my ($limit) = @_;

  my $sql = q|
SELECT threads.thread_last_message_time, threads.thread_first_message_id, threads.thread_id, threads.thread_subject, threads.board_id
FROM threads
WHERE threads.thread_subject != ''
AND threads.thread_deleted != '1'
ORDER BY threads.thread_last_message_time DESC
LIMIT ?
|;

  my @bind = (
    $limit
  );

  &VR::Util::read_db(\$sql, \@bind, \$VR::sth{'recent'}, \$VR::db->{'recent'});
}

sub load_recent_photos {
  my ($section, $limit, $type, $order) = @_;

  if ($type eq 'uploads') {
    $order = q|ORDER BY threads.thread_id DESC|;
  } else {
    $order = q|ORDER BY threads.thread_last_message_time DESC|;
  }

  my $sql = qq|
SELECT threads.thread_last_message_time, threads.thread_first_message_id, threads.thread_id, threads.thread_subject, threads.board_id, threads.thread_first_message_id
FROM threads
LEFT JOIN boards as boards ON threads.board_id = boards.board_id
WHERE boards.section_id = ?
AND threads.thread_subject != ''
AND threads.thread_deleted != '1'
$order
LIMIT ?
|;

  my @bind = (
    $section,
    $limit
  );

  if ($type eq 'uploads') {
    &VR::Util::read_db(\$sql, \@bind, \$VR::sth{'recent_photo_uploads'}, \$VR::db->{'recent_photo_uploads'});  
  } else {
    &VR::Util::read_db(\$sql, \@bind, \$VR::sth{'recent_photo_comments'}, \$VR::db->{'recent_photo_comments'});  
  }
}

sub load_news {
  my ($limit) = @_;

	my $sql = q|
SELECT threads.thread_id, threads.thread_subject, threads.thread_icon, threads.board_id
FROM threads
INNER JOIN users as start ON start.user_id = threads.thread_starter_id
WHERE threads.board_id = 'news'
AND (threads.thread_deleted IS NULL OR threads.thread_deleted != '1')
AND (threads.thread_subject IS NOT NULL OR threads.thread_deleted != '')
ORDER BY threads.thread_last_message_time DESC
LIMIT ?
|;

  my @bind = (
    $limit,
  );

  &VR::Util::read_db(\$sql, \@bind, \$VR::sth{'news'}, \$VR::db->{'news'});  
}

sub load_birthdays {
  my ($day, $month, $sth) = @_;
  $sth =~ s/\W+//isg;

  my $sql = q|
SELECT users.user_id, users.user_name, users.user_id, users.display_name, user_groups.group_color
FROM users
LEFT JOIN user_groups AS user_groups ON (CASE WHEN users.group_id = 0 OR users.group_id IS NULL THEN (SELECT group_id FROM user_groups WHERE user_groups.posts_required <= users.user_post_num ORDER BY user_groups.posts_required DESC LIMIT 1) ELSE users.group_id END) = user_groups.group_id
WHERE birthday LIKE ?
LIMIT 100
|;

  my @bind = (
    "%$month-$day"
  );

  &VR::Util::read_db(\$sql, \@bind, \$VR::sth{$sth}, \$VR::db->{$sth});
}

sub get_stats {
  my $sql = q|
SELECT forum_total_posts, forum_total_threads, forum_total_photos, forum_total_shouts, forum_total_users, forum_max_online, forum_max_online_time
FROM forum_stats
ORDER BY forum_max_online_time DESC
LIMIT 1
|;

  my @bind = ();

  &VR::Util::fetch_db(\$sql, \@bind, \$VR::db->{'site_stats'});
}

sub get_online_users {
  my $sql = q|
SELECT users.user_id, users.user_name, users.user_id, users.display_name, users.avatar, user_groups.group_color
FROM sessions
LEFT JOIN users AS users ON users.user_id = sessions.user_id
LEFT JOIN user_groups AS user_groups ON (CASE WHEN users.group_id = 0 OR users.group_id IS NULL THEN (SELECT group_id FROM user_groups WHERE user_groups.posts_required <= users.user_post_num ORDER BY user_groups.posts_required DESC LIMIT 1) ELSE users.group_id END) = user_groups.group_id
ORDER BY sessions.last_online DESC
LIMIT 1
|;

  my @bind = ();

  &VR::Util::read_db(\$sql, \@bind, \$VR::sth{'online_users'}, \$VR::db->{'online_users'});
}

sub get_online_user_avatars {
  my $sql = q|
SELECT users.user_id, users.user_name, users.user_id, users.display_name, users.avatar, user_groups.group_color
FROM sessions
LEFT JOIN users AS users ON users.user_id = sessions.user_id
LEFT JOIN user_groups AS user_groups ON (CASE WHEN users.group_id = 0 OR users.group_id IS NULL THEN (SELECT group_id FROM user_groups WHERE user_groups.posts_required <= users.user_post_num ORDER BY user_groups.posts_required DESC LIMIT 1) ELSE users.group_id END) = user_groups.group_id
ORDER BY sessions.last_online DESC
LIMIT 1
|;

  my @bind = ();

  &VR::Util::read_db(\$sql, \@bind, \$VR::sth{'online_user_avatars'}, \$VR::db->{'online_user_avatars'});
}



1;




