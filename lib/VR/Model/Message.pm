###############################################################################
# VR::Model::Message.pm
# =============================================================================
# Version:      Vegetable Revolution 4.0
# Released:     1st January 2010
# Author:       James Aitken <http://www.loonypandora.com/>
###############################################################################

package VR::Model::Message;

use strict;
use warnings;
use base 'Exporter';
use vars '@EXPORT_OK';

@EXPORT_OK = qw();


sub load_inbox {
  my ($user_id, $offset, $limit) = @_;

	my $sql = q|
SELECT priv_conversations.thread_id, pm_subject, pm_last_msg_time, pm_last_poster_id,
sender.user_name AS sender_user_name, sender.display_name AS sender_display_name, sender_user_groups.group_color AS sender_group_color,
last.user_name AS last_user_name, last.display_name AS last_display_name, last_user_groups.group_color AS last_group_color
FROM priv_conversations
LEFT JOIN priv_threads AS priv_threads ON priv_threads.pm_thread_id = priv_conversations.thread_id
LEFT JOIN priv_conversations AS sender_thread ON priv_conversations.thread_id = sender_thread.thread_id AND sender_thread.user_id != ?
LEFT JOIN users AS sender ON sender_thread.user_id = sender.user_id
LEFT JOIN user_groups AS sender_user_groups ON (CASE WHEN sender.group_id = 0 OR sender.group_id IS NULL THEN (SELECT group_id FROM user_groups WHERE sender_user_groups.posts_required <= sender.user_post_num ORDER BY sender_user_groups.posts_required DESC LIMIT 1) ELSE sender.group_id END) = sender_user_groups.group_id
LEFT JOIN users AS last ON priv_threads.pm_last_poster_id = last.user_id
LEFT JOIN user_groups AS last_user_groups ON (CASE WHEN last.group_id = 0 OR last.group_id IS NULL THEN (SELECT group_id FROM user_groups WHERE last_user_groups.posts_required <= last.user_post_num ORDER BY last_user_groups.posts_required DESC LIMIT 1) ELSE last.group_id END) = last_user_groups.group_id
WHERE priv_conversations.user_id = ?
AND priv_conversations.deleted != '1'
ORDER BY priv_threads.pm_last_msg_time DESC
LIMIT ?, ?
|;
 
  my @bind = (
    $user_id,
    $user_id,
    $offset,
    $limit,
  );


	my $static_sql = q|
SELECT COUNT(*) AS total_messages
FROM priv_conversations
WHERE priv_conversations.user_id = ?
AND priv_conversations.deleted != '1'
LIMIT 1
|;

  my @static_bind = (
    $user_id,
  );

  &VR::Util::read_db(\$sql, \@bind, \$VR::sth{'priv_messages'}, \$VR::db->{'priv_messages'}); 
  &VR::Util::fetch_db(\$static_sql, \@static_bind, \$VR::db->{'private_total'});
}

sub write_new_message {
  
}

sub reply_to_thread {
  
}


1;