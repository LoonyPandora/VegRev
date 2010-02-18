###############################################################################
# VR::Model::User.pm
# =============================================================================
# Version:      Vegetable Revolution 4.0
# Released:     1st January 2010
# Author:       James Aitken <http://www.loonypandora.com/>
###############################################################################

package VR::Model::User;

use strict;
use warnings;
use base 'Exporter';
use vars '@EXPORT_OK';

@EXPORT_OK = qw();


sub load_profile {
  my ($user_name) = @_;

	my $sql = q|
SELECT users.user_id, users.user_name, users.display_name, users.avatar, users.usertext, users.email, users.user_post_num, users.real_name, users.gender, users.birthday, users.signature, users.last_online, users.reg_time, users.biography, users.homepage, users.icq, users.msn, users.yim, users.aim, users.gtalk, users.skype, users.twitter, users.flickr, users.deviantart, users.vimeo, users.youtube, users.facebook, users.myspace, users.bebo, users.last_fm, users.tumblr, users.user_post_num, users.user_shout_num, user_groups.group_title
FROM users
LEFT JOIN user_groups AS user_groups ON (CASE WHEN users.group_id = 0 OR users.group_id IS NULL THEN (SELECT group_id FROM user_groups WHERE user_groups.posts_required <= users.user_post_num ORDER BY user_groups.posts_required DESC LIMIT 1) ELSE users.group_id END) = user_groups.group_id
WHERE users.user_name = ?
LIMIT 1
|;

  my @bind = (
    $user_name
  );

  &VR::Util::fetch_db(\$sql, \@bind, \$VR::db->{'user'});
}

1;