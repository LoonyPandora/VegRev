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
  my ($user_name, undef) = @_;

	my $query = qq{
SELECT users.user_id, users.user_name, users.display_name, users.avatar, users.usertext, users.email, users.user_post_num, users.real_name, users.gender, users.birthday, users.signature, users.last_online, users.reg_time, users.biography, users.homepage, users.icq, users.msn, users.yim, users.aim, users.gtalk, users.skype, users.twitter, users.flickr, users.deviantart, users.vimeo, users.youtube, users.facebook, users.myspace, users.bebo, users.last_fm, users.tumblr, users.user_post_num, users.user_shout_num
FROM users
WHERE users.user_name = ?
LIMIT 1
};

  my $static 	= $vr::dbh->prepare($query);
  $static->execute($user_name);
  $static->bind_columns(\(@vr::db{@{$static->{NAME_lc}}}));
  $static->fetch;
  
	$vr::db{'signature'} =~ s/\[br\]/\n/g;
	$vr::db{'biography'} =~ s/\[br\]/\n/g;

}

1;