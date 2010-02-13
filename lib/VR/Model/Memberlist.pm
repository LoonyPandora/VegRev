###############################################################################
# VR::Model::Memberlist.pm
# =============================================================================
# Version:      Vegetable Revolution 4.0
# Released:     1st January 2010
# Author:       James Aitken <http://www.loonypandora.com/>
###############################################################################

package VR::Model::Memberlist;

use strict;
use warnings;
use base 'Exporter';
use vars '@EXPORT_OK';

@EXPORT_OK = qw();


sub load_memberlist_by_postcount {
  my ($offset) = @_;

	my $sql = q|
SELECT users.user_name, users.display_name, users.avatar, users.user_post_num, users.reg_time, users.last_online, users.user_post_num,  user_groups.group_color, user_groups.group_title
FROM users
LEFT JOIN user_groups AS user_groups ON user_groups.group_id = (CASE WHEN users.group_id = 0 OR users.group_id IS NULL THEN (SELECT group_id FROM user_groups WHERE user_groups.posts_required <= users.user_post_num ORDER BY user_groups.posts_required DESC LIMIT 1) ELSE users.group_id
END)
WHERE users.user_deleted != '1'
ORDER BY users.user_post_num DESC
LIMIT ?, ?
|;

  my @bind = (
    $offset,
    20,
  );

  my $static_sql = q|
SELECT COUNT(1) as total_members
FROM users
WHERE users.user_deleted != '1'
LIMIT 1
|;

  my @static_bind = ();
  &VR::Util::fetch_db(\$static_sql, \@static_bind, \$VR::db->{'memberlist'});
  
  &VR::Util::read_db(\$sql, \@bind, \$VR::sth{'memberlist'}, \$VR::db->{'memberlist'});  
}

1;