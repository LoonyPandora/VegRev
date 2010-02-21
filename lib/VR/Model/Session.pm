###############################################################################
# VR::Model::Session.pm
# =============================================================================
# Version:      Vegetable Revolution 4.0
# Released:     1st January 2010
# Author:       James Aitken <http://www.loonypandora.com/>
###############################################################################

package VR::Model::Session;

use strict;
use warnings;


sub load_viewer {
  my %cookies = %{&Dancer::Cookies::cookies};

  # DEBUG: Remove for production - always sets to be admin.
  $cookies{'user_id'}     = '1';
  $cookies{'session_id'}  = '1ac1081ae4df823f2fe22c1476179a34';

  if (!$cookies{'user_id'} || !$cookies{'session_id'}) { $VR::viewer{'is_guest'} = '1'; }

  my $sql = q|
SELECT users.user_id, users.user_name, users.display_name, users.avatar, users.reg_time, sessions.last_online, users.language, users.template, user_groups.group_id, user_groups.group_color, user_groups.is_admin, user_groups.is_mod, user_groups.is_vip
FROM users
LEFT JOIN sessions AS sessions ON users.user_id = sessions.user_id
LEFT JOIN user_groups AS user_groups ON (CASE WHEN users.group_id = 0 OR users.group_id IS NULL THEN (SELECT group_id FROM user_groups WHERE user_groups.posts_required <= users.user_post_num ORDER BY user_groups.posts_required DESC LIMIT 1) ELSE users.group_id END) = user_groups.group_id
WHERE users.user_id = ? AND users.password = ? AND users.user_deleted != 1
LIMIT 1
  |;

  my @bind = (
    $cookies{'user_id'},
    $cookies{'session_id'}
  );

  unless ($VR::viewer{'is_guest'}) {
    &VR::Util::fetch_db_noref(\$sql, \@bind, \%VR::viewer);
  }
  
  if (!$VR::viewer{'user_name'}) { $VR::viewer{'is_guest'} = '1'; }

  $VR::viewer{'ip_address'} = $ENV{'REMOTE_ADDR'};

  if (!$VR::viewer{'ip_address'} || $VR::viewer{'ip_address'} eq "127.0.0.1") {
    if    ($ENV{'HTTP_CLIENT_IP'} && $ENV{'HTTP_CLIENT_IP'} ne '127.0.0.1') { $VR::viewer{'ip_address'} = $ENV{'HTTP_CLIENT_IP'}; }
    elsif ($ENV{'X_CLIENT_IP'} && $ENV{'X_CLIENT_IP'} ne '127.0.0.1')       { $VR::viewer{'ip_address'} = $ENV{'X_CLIENT_IP'}; }
    elsif ($ENV{'HTTP_X_FORWARDED_FOR'} && $ENV{'HTTP_X_FORWARDED_FOR'} ne '127.0.0.1') { $VR::viewer{'ip_address'} = $ENV{'HTTP_X_FORWARDED_FOR'}; }
  } 

  # Untaint the IP Address, remember %ENV is tainted.
  if ($VR::viewer{'ip_address'} =~ /^(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})$/) { $VR::viewer{'ip_address'} = $1; }
  else { $VR::viewer{'ip_address'} = '127.0.0.1'; }
}

sub load_board_permissions {
  my ($board_id) = @_;
  
  if ($VR::viewer{'is_guest'}) { return; }
  
  my $sql = q|
SELECT * FROM board_permissions
WHERE board_id = ?
AND group_id = ?
LIMIT 1
  |;

  my @bind = (
    $board_id,
    $VR::viewer{'group_id'}
  );

  &VR::Util::fetch_db_noref(\$sql, \@bind, \%VR::viewer);
}

sub update_session {
  my ($user_id, $last_online, $ip_address) = @_;

  if (!$user_id) { return; }
  if (!$last_online) { $last_online = 0; }
  if ($last_online > $VR::TIMESTAMP - 900) { return; }

  my $sql = q|
INSERT INTO sessions
VALUES(?, ?, ?)
ON DUPLICATE KEY UPDATE last_online = ?, session_ip = ?
	|;
  
  my @bind = (
    $user_id,
    $VR::TIMESTAMP,
    $ip_address,
    $VR::TIMESTAMP,
    $ip_address,
  );

  &VR::Util::write_db(\$sql, \@bind);
}

sub do_login {
  &Dancer::Helpers::set_cookie(
    user_id => '1',
    expires => int(time()) + 3600,
    domain => VR::config('domain'),
    path => '/'
  );

  &Dancer::Helpers::set_cookie(
    session_id => '1ac1081ae4df823f2fe22c1476179a34',
    expires => int(time()) + 3600,
    domain => VR::config('domain'),
    path => '/'
  );
  
  &update_session('1', '0', '127.0.0.1');
}



1;