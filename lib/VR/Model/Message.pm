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



sub load_conversations {
  my ($offset, undef) = @_;

	my $query = qq{
SELECT pm_threads.pm_thread_id, pm_threads.pm_subject, pm_threads.pm_last_msg_time, pm_threads.pm_total_messages, pm_threads.pm_sender_unread, pm_threads.pm_receiver_unread, pm_threads.pm_receiver_delete, pm_threads.pm_sender_delete, pm_threads.sender.user_id AS sender_user_id, sender.display_name AS sender_display_name, sender.avatar AS sender_avatar, sender.user_name AS sender_user_name, send_spec_groups.spec_group_color AS sender_spec_group_color, receiver.user_id AS receiver_user_id, receiver.display_name AS receiver_display_name, receiver.avatar AS receiver_avatar, receiver.user_name AS receiver_user_name, rec_spec_groups.spec_group_color AS receiver_spec_group_color, last.user_id AS last_user_id, last.user_name AS last_user_name, last.display_name AS last_display_name, last_spec_groups.spec_group_color AS last_spec_group_color,
CASE
WHEN pm_sender_id = ? AND pm_sender_delete != '1' THEN '1'
END AS sender_visible,
CASE
WHEN pm_receiver_id = ? AND pm_receiver_delete != '1' THEN '1'
END AS receiver_visible,
CASE
WHEN pm_receiver_id = pm_sender_id THEN '1'
END AS self_message
FROM pm_threads
INNER JOIN users as sender ON sender.user_id = pm_threads.pm_sender_id
INNER JOIN users as receiver ON receiver.user_id = pm_threads.pm_receiver_id
INNER JOIN users as last ON last.user_id = pm_threads.pm_last_poster_id
LEFT JOIN special_groups AS send_spec_groups ON sender.spec_group_id = send_spec_groups.spec_group_id
LEFT JOIN special_groups AS rec_spec_groups ON receiver.spec_group_id = rec_spec_groups.spec_group_id
LEFT JOIN special_groups AS last_spec_groups ON last.spec_group_id = last_spec_groups.spec_group_id
WHERE (pm_threads.pm_receiver_id = ? AND receiver_visible = '1')
OR (pm_threads.pm_sender_id = ? AND sender_visible = '1')
ORDER BY pm_threads.pm_last_msg_time DESC
LIMIT ?, ?
};

	# Execute all queries, and bind to template variables.
	$vr::loop = $vr::dbh->prepare($query);
	$vr::loop->execute($vr::viewer{'user_id'}, $vr::viewer{'user_id'}, $vr::viewer{'user_id'}, $vr::viewer{'user_id'}, $offset, $vr::config{'pms_per_page'});
	$vr::loop->bind_columns(\(@vr::loop{@{$vr::loop->{NAME_lc}}}));  

}


1;