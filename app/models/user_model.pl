###############################################################################
# models/user.pl
# =============================================================================
# Version:    Vegetable Revolution 3.0
# Released:   1st June 2009
# Revision:   $Rev$
# Copyright:  James Aitken <http://www.loonypandora.com>
###############################################################################

use strict;

sub _load_viewer {
    if (!$vr::COOKIE{'session_id'}) { $vr::viewer{'is_guest'} = '1'; }

    my $query = qq{
SELECT users.user_id, users.user_name, users.email, users.display_name, users.avatar, users.usertext, users.user_post_num, users.reg_time, special_groups.spec_group_id, special_groups.spec_group_color, post_groups.post_group_color, users.language, users.template, special_groups.group_can_mod AS can_mod, special_groups.group_can_admin AS can_admin, (SELECT SUM(pm_receiver_unread) FROM pm_threads WHERE pm_threads.pm_receiver_id = users.user_id) AS new_receiver_pms, (SELECT SUM(pm_sender_unread) FROM pm_threads WHERE pm_threads.pm_sender_id = users.user_id) AS new_sender_pms,
(SELECT post_group_id FROM post_groups WHERE post_groups.posts_required <= users.user_post_num ORDER BY post_groups.posts_required DESC LIMIT 1) AS user_post_group_id
FROM users
LEFT JOIN special_groups AS special_groups ON users.spec_group_id = special_groups.spec_group_id
LEFT JOIN post_groups AS post_groups ON post_groups.post_group_id = (SELECT post_group_id FROM post_groups WHERE post_groups.posts_required <= users.user_post_num ORDER BY post_groups.posts_required DESC LIMIT 1)
LEFT JOIN session ON session.user_id = users.user_id
WHERE session.id = ?
LIMIT 1
    };

    unless ($vr::viewer{'is_guest'}) {
        my $static = $vr::dbh->prepare($query);
        $static->execute($vr::COOKIE{'session_id'});
        $static->bind_columns(\(@vr::viewer{ @{ $static->{NAME_lc} } }));
        $static->fetch;
    }

    if (!$vr::viewer{'user_name'}) { $vr::viewer{'is_guest'} = '1'; }

    if ($vr::viewer{'spec_group_color'}) {
        $vr::viewer{'username_color'} = $vr::viewer{'spec_group_color'};
    } else {
        $vr::viewer{'username_color'} = $vr::viewer{'post_group_color'};
    }

    $vr::viewer{'ip_address'} = $ENV{'REMOTE_ADDR'};

    if (!$vr::viewer{'ip_address'} || $vr::viewer{'ip_address'} eq "127.0.0.1") {
        if ($ENV{'HTTP_CLIENT_IP'} && $ENV{'HTTP_CLIENT_IP'} ne '127.0.0.1') {
            $vr::viewer{'ip_address'} = $ENV{'HTTP_CLIENT_IP'};
        } elsif ($ENV{'X_CLIENT_IP'} && $ENV{'X_CLIENT_IP'} ne '127.0.0.1') {
            $vr::viewer{'ip_address'} = $ENV{'X_CLIENT_IP'};
        } elsif ($ENV{'HTTP_X_FORWARDED_FOR'} && $ENV{'HTTP_X_FORWARDED_FOR'} ne '127.0.0.1') {
            $vr::viewer{'ip_address'} = $ENV{'HTTP_X_FORWARDED_FOR'};
        }
    }

    # Untaint the IP Address, remember %ENV is tainted.
    if ($vr::viewer{'ip_address'} =~ /^(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})$/) {
        $vr::viewer{'ip_address'} = $1;
    } else {
        $vr::viewer{'ip_address'} = '127.0.0.1';
    }

    # LoonyPandora Edit: Anonymise VR Hotties Account
    #  if ($vr::viewer{'user_name'} eq 'vrhotties' ) { $vr::viewer{'ip_address'} = '86.163.3.209'; }

    if ($vr::viewer{'template'} && -d "$vr::config{'assetdir'}/$vr::viewer{'template'}") {
        $vr::viewer{'template_url'}  = "$vr::config{'base_url'}/template/$vr::viewer{'template'}";
        $vr::viewer{'template_path'} = "$vr::config{'assetdir'}/$vr::viewer{'template'}";
    } else {
        $vr::viewer{'template_url'}  = "$vr::config{'base_url'}/template/$vr::config{'template'}";
        $vr::viewer{'template_path'} = "$vr::config{'assetdir'}/$vr::config{'template'}";
    }

    $vr::viewer{'new_pms'} = $vr::viewer{'new_sender_pms'} + $vr::viewer{'new_receiver_pms'};

    if (!$vr::viewer{'avatar'}) {
        $vr::viewer{'avatar'} = "$vr::viewer{'template_url'}/img/placeholder.png";
    }
    if (!$vr::viewer{'usertext'}) { $vr::viewer{'usertext'} = "Guest"; }

    if ($vr::viewer{'avatar'} =~ /^\d{1,8}\.\w{1,4}$/) {
        my ($digits, $ext) = split(/\./, $vr::viewer{'avatar'});
        $ext = lc($ext);
        if ($ext eq 'jpeg') { $ext = 'jpg'; }
        if (-f "$vr::config{'base_path'}/uploads/$digits.thumb.$ext") {
            $vr::viewer{'avatar'} = "$vr::config{'base_url'}/uploads/$digits.thumb.$ext";
        } else {
            $vr::viewer{'avatar'} = "$vr::config{'base_url'}/uploads/$vr::viewer{'avatar'}";
        }
    }

}

sub _quick_load_viewer {
    $vr::viewer{'ip_address'}    = $ENV{'REMOTE_ADDR'};
    $vr::viewer{'template_url'}  = "$vr::config{'base_url'}/template/$vr::config{'template'}";
    $vr::viewer{'template_path'} = "$vr::config{'assetdir'}/$vr::config{'template'}";
    $vr::viewer{'avatar'}        = "$vr::viewer{'template_url'}/img/placeholder.png";
    $vr::viewer{'usertext'}      = "Guest";
}


sub _set_session { 
    my ($session_id, $user_id) = @_;

    my $query = qq{
        INSERT INTO session (id, user_id, date_online)
        VALUES (?, ?, NOW())
        ON DUPLICATE KEY UPDATE date_online = NOW()
    };

    $vr::dbh->prepare($query)->execute(
        $session_id, $user_id
    );

    # Manually commit as we are redirecting right after
    $vr::dbh->commit();
}


sub _list_active_users {
    our $num_guests_online = int(rand(5));

    my $query = qq{
        SELECT users.user_id, users.user_name, users.avatar, users.usertext, users.display_name, special_groups.spec_group_color
        FROM session
        LEFT JOIN users ON session.user_id = users.user_id
        LEFT JOIN special_groups AS special_groups ON users.spec_group_id = special_groups.spec_group_id
        WHERE session.user_id = ?
        AND session.date_online >= NOW() - INTERVAL 15 MINUTE
    };

    $vr::loop = $vr::dbh->prepare($query);
    $vr::loop->execute($vr::viewer{'user_id'});
    $vr::loop->bind_columns(\(@vr::loop{ @{ $vr::loop->{NAME_lc} } }));
}

sub _check_if_online {
    my $query = qq{
        SELECT session.user_id
        FROM session
        WHERE session.user_id = ?
        # AND session.date_online >= NOW() - INTERVAL 15 MINUTE
    };

    my %tmp;
    my $static = $vr::dbh->prepare($query);
    $static->execute($_[0]);
    $static->bind_columns(\(@tmp{ @{ $static->{NAME_lc} } }));
    $static->fetch;

    if ($tmp{user_id}) {
        return 1;
    }

    return undef;
}

sub _authenticate_login {
    my ($user, $pass) = @_;
    my $column = undef;

    if   ($user =~ /\@/) { $column = 'users.email'; }
    else                 { $column = 'users.user_name'; }

    my $query = qq{
SELECT users.user_id, users.password, users.bcrypt_password
FROM users
WHERE $column = ?
LIMIT 1
    };

    my $static = $vr::dbh->prepare($query);
    $static->execute($user);
    $static->bind_columns(\(@vr::db{ @{ $static->{NAME_lc} } }));
    $static->fetch;

    # Auth against old password
    if ($vr::db{'password'} eq _old_insecure_md5_password($pass)) {
        $vr::db{'bcrypt_password'} = _encode_password($pass);
 
        # Update it with a bcrypt version and delete the old one.
        my $query = qq{
            UPDATE users
            SET password = '', bcrypt_password = ?
            WHERE $column = ?
        };

        $vr::dbh->prepare($query)->execute($vr::db{'bcrypt_password'}, $user);
    }

    # Now auth against bcrypt password
    # Default to not letting them in - hence the unless
    warn qq~text => $pass, crypt => $vr::db{'bcrypt_password'}~;
    unless ( bcrypt->compare( text => $pass, crypt => $vr::db{'bcrypt_password'} ) ) {
        delete $vr::db{'user_id'};
    }

    # Always delete this from the returned data
    delete $vr::db{'bcrypt_password'};
    delete $vr::db{'password'};
}

sub _update_last_online {
    my ($user_id, $last_ip) = @_;

    my $query = qq{
UPDATE users
SET last_ip = ?, last_online = ?
WHERE user_id = ?
    };

    $vr::dbh->prepare($query)->execute($last_ip, $vr::config{'gmtime'}, $user_id);
}

sub _update_user_shout_count {
    my ($user_id) = @_;

    my $query = qq{
UPDATE users SET user_shout_num = user_shout_num + 1 WHERE users.user_id = ?
    };

    $vr::dbh->prepare($query)->execute($user_id);
}

sub _do_reset_password {
    my ($email, $plainpass) = @_;

    my $password = _encode_password($plainpass);

    my $query = qq{
UPDATE users
SET password = ?
WHERE email = ?
    };

    $vr::dbh->prepare($query)->execute($password, $email);
}

sub _get_user_id_from_name {
    my ($user_name) = @_;

    my $query = qq{
SELECT users.user_id
FROM users
WHERE users.user_name = ?
LIMIT 1
    };

    my $static = $vr::dbh->prepare($query);
    $static->execute($user_name);
    $static->bind_columns(\(@vr::db{ @{ $static->{NAME_lc} } }));
    $static->fetch;
}

1;

