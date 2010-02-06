###############################################################################
# VR::Model::Shoutbox.pm
# =============================================================================
# Version:      Vegetable Revolution 4.0
# Released:     1st January 2010
# Author:       James Aitken <http://www.loonypandora.com/>
###############################################################################

package VR::Model::Shoutbox;

use strict;
use warnings;
use base 'Exporter';
use vars '@EXPORT_OK';

@EXPORT_OK = qw();


sub load_shouts {
  my ($limit) = @_;

	my $sql = q|
SELECT shoutbox.shout_id, shoutbox.shout_time, shoutbox.shout_body, users.user_name, users.display_name, user_groups.group_color
FROM shoutbox
LEFT JOIN users AS users ON users.user_id = shoutbox.user_id
LEFT JOIN user_groups AS user_groups ON (CASE WHEN users.group_id = 0 OR users.group_id IS NULL THEN (SELECT group_id FROM user_groups WHERE user_groups.posts_required <= users.user_post_num ORDER BY user_groups.posts_required DESC LIMIT 1) ELSE users.group_id END) = user_groups.group_id
WHERE shoutbox.shout_deleted != '1'
ORDER BY shoutbox.shout_time DESC
LIMIT ?
|;

  my @bind = (
    $limit
  );

  &VR::Util::read_db(\$sql, \@bind, \$VR::sth{'shoutbox'}, \$VR::db->{'shoutbox'});
  $VR::db->{'shoutbox'} = $VR::sth{'shoutbox'}->fetchall_hashref('shout_id');
}


1;