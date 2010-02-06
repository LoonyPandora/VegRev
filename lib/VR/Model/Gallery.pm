###############################################################################
# VR::Model::Gallery.pm
# =============================================================================
# Version:      Vegetable Revolution 4.0
# Released:     1st January 2010
# Author:       James Aitken <http://www.loonypandora.com/>
###############################################################################

package VR::Model::Gallery;

use strict;
use warnings;
use base 'Exporter';
use vars '@EXPORT_OK';

@EXPORT_OK = qw();


sub load_photo_list {
  my ($album, $offset, $limit) = @_;

	my $sql = q|
SELECT threads.thread_first_message_id, threads.thread_id, threads.board_id, threads.thread_subject, threads.thread_last_message_time, threads.thread_views, threads.thread_messages, start.user_name AS start_user_name, last.user_name AS last_user_name, start.display_name AS start_display_name, last.display_name AS last_display_name, start.avatar, threads.thread_star, threads.thread_locked, start_spec_group.group_color AS start_group_color, last_spec_group.group_color AS last_group_color
FROM threads
INNER JOIN users as start ON start.user_id = threads.thread_starter_id
INNER JOIN users as last ON last.user_id = threads.thread_last_user_id
LEFT JOIN user_groups AS start_spec_group ON (CASE WHEN start.group_id = 0 OR start.group_id IS NULL THEN (SELECT group_id FROM user_groups WHERE user_groups.posts_required <= start.user_post_num ORDER BY user_groups.posts_required DESC LIMIT 1) ELSE start.group_id END) = start_spec_group.group_id
LEFT JOIN user_groups AS last_spec_group ON (CASE WHEN last.group_id = 0 OR last.group_id IS NULL THEN (SELECT group_id FROM user_groups WHERE user_groups.posts_required <= last.user_post_num ORDER BY user_groups.posts_required DESC LIMIT 1) ELSE last.group_id END) = last_spec_group.group_id
WHERE threads.board_id = ?
AND (threads.thread_deleted IS NULL OR threads.thread_deleted != '1')
AND (threads.thread_subject IS NOT NULL OR threads.thread_deleted != '')
ORDER BY thread_last_message_time DESC
LIMIT ?, ?
|;
  
  
  my @bind = ($album, $offset, $limit);

	my $static_sql = q|
SELECT boards.board_id, boards.board_title, boards.board_description, boards.board_thread_total
FROM boards
WHERE boards.board_id = ?
LIMIT 1
|;

  my @static_bind = (
    $album,
  );

  &VR::Util::fetch_db(\$static_sql, \@static_bind, \$VR::db->{'album'});


  &VR::Util::read_db(\$sql, \@bind, \$VR::sth{'photos'}, \$VR::db->{'photos'});
}


sub load_albums {
	my $sql = q|
SELECT boards.board_id, boards.board_title, boards.board_description, boards.board_message_total, boards.board_thread_total, boards.board_last_post_time, boards.board_last_post_id, boards.board_icon, threads.thread_subject
FROM boards
LEFT JOIN threads as threads ON threads.thread_id = boards.board_last_post_id
WHERE boards.section_id = 'gallery'
ORDER BY boards.board_position ASC
|;

  my @bind = ();

	my $static_sql = q|
SELECT categories.category_id, categories.category_title
FROM categories
WHERE categories.category_id = 'gallery'
LIMIT 1
|;

  my @static_bind = ();

  &VR::Util::fetch_db(\$static_sql, \@static_bind, \$VR::db->{'gallery'});
  &VR::Util::read_db(\$sql, \@bind, \$VR::sth{'gallery'}, \$VR::db->{'gallery'});
}




sub load_photo {
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
SELECT threads.thread_id, threads.thread_subject, threads.thread_locked, threads.board_id, threads.thread_messages, boards.board_title, users.user_id, users.user_name, users.display_name, user_groups.group_id, user_groups.group_color, user_groups.is_admin, user_groups.is_mod, user_groups.is_vip
FROM threads
LEFT JOIN boards AS boards ON boards.board_id = threads.board_id
LEFT JOIN users AS users ON users.user_id = threads.thread_starter_id
LEFT JOIN user_groups AS user_groups ON (CASE WHEN users.group_id = 0 OR users.group_id IS NULL THEN (SELECT group_id FROM user_groups WHERE user_groups.posts_required <= users.user_post_num ORDER BY user_groups.posts_required DESC LIMIT 1) ELSE users.group_id END) = user_groups.group_id
WHERE threads.thread_id = ?
LIMIT 1
|;

  my @static_bind = (
    $thread_id,
  );


  &VR::Util::fetch_db(\$static_sql, \@static_bind, \$VR::db->{'thread'});
  &VR::Util::read_db(\$sql, \@bind, \$VR::sth{'messages'}, \$VR::db->{'messages'}); 
}




sub load_complete_photo_list {
  my ($offset, $limit) = @_;

	my $sql = q|
SELECT threads.thread_first_message_id, threads.thread_id, threads.thread_subject, threads.thread_last_message_time, threads.thread_views, threads.thread_messages, start.user_name AS start_user_name, last.user_name AS last_user_name, start.display_name AS start_display_name, last.display_name AS last_display_name, start.avatar, threads.thread_star, threads.thread_locked, start_spec_group.group_color AS start_group_color, last_spec_group.group_color AS last_group_color
FROM threads
INNER JOIN users as start ON start.user_id = threads.thread_starter_id
INNER JOIN users as last ON last.user_id = threads.thread_last_user_id
LEFT JOIN user_groups AS start_spec_group ON (CASE WHEN start.group_id = 0 OR start.group_id IS NULL THEN (SELECT group_id FROM user_groups WHERE user_groups.posts_required <= start.user_post_num ORDER BY user_groups.posts_required DESC LIMIT 1) ELSE start.group_id END) = start_spec_group.group_id
LEFT JOIN user_groups AS last_spec_group ON (CASE WHEN last.group_id = 0 OR last.group_id IS NULL THEN (SELECT group_id FROM user_groups WHERE user_groups.posts_required <= last.user_post_num ORDER BY user_groups.posts_required DESC LIMIT 1) ELSE last.group_id END) = last_spec_group.group_id
WHERE threads.board_id IN (SELECT board_id FROM boards WHERE section_id = 'gallery')
AND (threads.thread_deleted IS NULL OR threads.thread_deleted != '1')
AND (threads.thread_subject IS NOT NULL OR threads.thread_deleted != '')
ORDER BY thread_last_message_time DESC
LIMIT ?, ?
|;
  
  
  my @bind = ($offset, $limit);

  &VR::Util::read_db(\$sql, \@bind, \$VR::sth{'photos'}, \$VR::db->{'photos'});  

};

1;





