###############################################################################
# models/profile.pl
# =============================================================================
# Version:    Vegetable Revolution 3.0
# Released:   1st June 2009
# Revision:   $Rev$
# Copyright:  James Aitken <http://www.loonypandora.com>
###############################################################################

use strict;

sub _load_profile {
    my ($user_name, undef) = @_;

    my $query = qq{
SELECT users.user_id, users.user_name, users.display_name, users.avatar, users.usertext, users.email, users.user_post_num, users.real_name, users.gender, users.birthday, users.signature, users.last_online, users.reg_time, users.biography, users.spec_group_id, users.homepage, users.icq, users.msn, users.yim, users.aim, users.gtalk, users.skype, users.twitter, users.flickr, users.deviantart, users.vimeo, users.youtube, users.facebook, users.myspace, users.bebo, users.last_fm, users.tumblr, users.user_post_num, users.user_shout_num, users.user_private, 
(SELECT post_group_id FROM post_groups WHERE post_groups.posts_required <= users.user_post_num ORDER BY post_groups.posts_required DESC LIMIT 1) AS user_post_group_id, special_groups.spec_group_image, special_groups.spec_group_color, special_groups.spec_group_title, post_groups.post_group_image, post_groups.post_group_title
FROM users
LEFT JOIN special_groups AS special_groups ON users.spec_group_id = special_groups.spec_group_id
LEFT JOIN post_groups AS post_groups ON post_groups.post_group_id = (SELECT post_group_id FROM post_groups WHERE post_groups.posts_required <= users.user_post_num ORDER BY post_groups.posts_required DESC LIMIT 1)
WHERE users.user_name = ?
LIMIT 1
};

    my $static = $vr::dbh->prepare($query);
    $static->execute($user_name);
    $static->bind_columns(\(@vr::db{ @{ $static->{NAME_lc} } }));
    $static->fetch;
    $vr::db{'signature'} =~ s/\[br\]/\n/g;
    $vr::db{'biography'} =~ s/\[br\]/\n/g;
}

sub _write_profile {
    my ($attachment) = @_;

    my $optional = undef;
    my $avatar   = undef;

    my $admin = undef;

    if ( ($vr::POST{'pass_confirm'} && $vr::POST{'new_pass'}) && ($vr::POST{'pass_confirm'} eq $vr::POST{'new_pass'}) ) {
        $optional = qq{
UPDATE users
SET bcrypt_password = ?
WHERE users.user_id = ?
};
    }

    if ($vr::POST{'uploadify'}) {
        $avatar = qq{
UPDATE users
SET avatar = ?
WHERE users.user_id = ?
};
    }

    if ($vr::viewer{'can_admin'}) {
        $admin = qq{
UPDATE users
SET user_post_num = ?, user_shout_num = ?, reg_time = ?, spec_group_id = ?
WHERE users.user_id = ?
};
    }

    my $query = qq{
UPDATE users
SET homepage = ?, gtalk = ?, real_name = ?, facebook = ?, biography = ?, signature = ?, usertext = ?, skype = ?, myspace = ?, deviantart = ?, flickr = ?, twitter = ?, yim = ?, icq = ?, gender = ?, display_name = ?, aim = ?, bebo = ?, youtube = ?, birthday = ?, msn = ?,
user_private = ?
WHERE users.user_id = ?
    };

    if ($vr::POST{'private'} eq 'on') {
        $vr::POST{'private'} = 1;
    } else {
        $vr::POST{'private'} = 0;
    }

    $vr::dbh->prepare($query)->execute(
        $vr::POST{'website'},      $vr::POST{'gtalk'},    $vr::POST{'realname'},
        $vr::POST{'facebook'},     $vr::POST{'about'},    $vr::POST{'signature'},
        $vr::POST{'usertext'},     $vr::POST{'skype'},    $vr::POST{'myspace'},
        $vr::POST{'deviantart'},   $vr::POST{'flickr'},   $vr::POST{'twitter'},
        $vr::POST{'yim'},          $vr::POST{'icq'},      $vr::POST{'gender'},
        $vr::POST{'display_name'}, $vr::POST{'aim'},      $vr::POST{'bebo'},
        $vr::POST{'youtube'},      $vr::POST{'birthday'}, $vr::POST{'msn'},
        $vr::POST{'private'},      $vr::POST{'user_id'},
    );

    if ($optional) {
        my $encoded_pass = _encode_password($vr::POST{'new_pass'});

        $vr::dbh->prepare($optional)->execute($encoded_pass, $vr::POST{'user_id'});
    }
    if ($avatar) {
        $vr::dbh->prepare($avatar)->execute("$attachment.$vr::POST{'attach_ext'}", $vr::POST{'user_id'});
    }
    if ($admin) {
        $vr::dbh->prepare($admin)->execute(
            $vr::POST{'postcount'},  $vr::POST{'shoutcount'}, $vr::POST{'regtime'},
            $vr::POST{'spec_group'}, $vr::POST{'user_id'}
        );
    }

}

sub _load_spec_groups {
    my $query = qq{
SELECT spec_group_id, spec_group_title, spec_group_image, group_can_mod, group_can_admin, spec_group_color
FROM special_groups
};

    $vr::loop = $vr::dbh->prepare($query);
    $vr::loop->execute();
    $vr::loop->bind_columns(\(@vr::loop{ @{ $vr::loop->{NAME_lc} } }));
}

sub _load_post_groups {
    my $query = qq{
SELECT post_group_id, posts_required, post_group_title, post_group_image, post_group_color
FROM post_groups
};

    $vr::loop = $vr::dbh->prepare($query);
    $vr::loop->execute();
    $vr::loop->bind_columns(\(@vr::loop{ @{ $vr::loop->{NAME_lc} } }));
}

sub _get_recent_posts {
    my ($user, $offset, $limit) = @_;

    my $query = qq{
SELECT messages.message_id, messages.thread_id, messages.message_body, messages.message_time, threads.thread_subject, threads.board_id, boards.category_id, users.user_id, users.user_name, users.display_name, users.avatar, special_groups.spec_group_color
FROM messages
INNER JOIN threads AS threads ON threads.thread_id = messages.thread_id
INNER JOIN boards AS boards ON threads.board_id = boards.board_id
INNER JOIN users AS users ON users.user_id = messages.user_id
LEFT JOIN special_groups AS special_groups ON users.spec_group_id = special_groups.spec_group_id
WHERE messages.user_id = ?
AND boards.category_id = 'forum'
AND boards.vip_only != '1'
AND boards.mods_only != '1'
AND messages.message_deleted != '1'
ORDER BY messages.message_time DESC
LIMIT ?, ?
    };

    $vr::loop = $vr::dbh->prepare($query);
    $vr::loop->execute($user, $offset, $limit);
    $vr::loop->bind_columns(\(@vr::loop{ @{ $vr::loop->{NAME_lc} } }));
}

sub _get_recent_post_count {
    my ($user) = @_;

    my $query = qq{
SELECT COUNT(1) as total_results
FROM messages
INNER JOIN threads AS threads ON threads.thread_id = messages.thread_id
INNER JOIN boards AS boards ON threads.board_id = boards.board_id
WHERE messages.user_id = ?
AND messages.message_deleted != '1'
AND boards.category_id = 'forum'
AND boards.vip_only != '1'
AND boards.mods_only != '1'
LIMIT 1
};

    my $static = $vr::dbh->prepare($query);
    $static->execute($user);
    $static->bind_columns(\(@vr::db{ @{ $static->{NAME_lc} } }));
    $static->fetch;
}

sub _load_memberlist {
    my ($offset, $limit, $type) = @_;

    my $order_by = '';
    if ($type eq 'date') {
        $order_by = 'ORDER BY users.reg_time ASC';
    } elsif ($type eq 'name') {
        $order_by = 'ORDER BY users.display_name ASC';
    } elsif ($type eq 'posts') {
        $order_by = 'ORDER BY users.user_post_num DESC';
    } elsif ($type eq 'online') {
        $order_by = "ORDER BY (CASE WHEN last_online = '' THEN 1 ELSE 0 END), last_online DESC";
    }

    my $query = qq{
SELECT users.user_name, users.display_name, users.avatar, users.user_post_num, users.reg_time, users.spec_group_id, users.last_online, users.user_post_num,
(SELECT post_group_id FROM post_groups WHERE post_groups.posts_required <= users.user_post_num ORDER BY post_groups.posts_required DESC LIMIT 1) AS user_post_group_id, special_groups.spec_group_image, special_groups.spec_group_color, special_groups.spec_group_title, post_groups.post_group_image, post_groups.post_group_title
FROM users
LEFT JOIN special_groups AS special_groups ON users.spec_group_id = special_groups.spec_group_id
LEFT JOIN post_groups AS post_groups ON post_groups.post_group_id = (SELECT post_group_id FROM post_groups WHERE post_groups.posts_required <= users.user_post_num ORDER BY post_groups.posts_required DESC LIMIT 1)
WHERE users.user_deleted != '1'
$order_by
LIMIT ?, ?
};

    $vr::loop = $vr::dbh->prepare($query);
    $vr::loop->execute($offset, $limit);
    $vr::loop->bind_columns(\(@vr::loop{ @{ $vr::loop->{NAME_lc} } }));

}

sub _total_member_count {
    my $query = qq{
SELECT COUNT(1) as total_members
FROM users
WHERE users.user_deleted != '1'
LIMIT 1
};

    my $static = $vr::dbh->prepare($query);
    $static->execute();
    $static->bind_columns(\(@vr::db{ @{ $static->{NAME_lc} } }));
    $static->fetch;
}

1;

