###############################################################################
# controllers/profile.pl
# =============================================================================
# Version:    Vegetable Revolution 3.0
# Released:   1st June 2009
# Revision:   $Rev$
# Copyright:  James Aitken <http://loonypandora.co.uk>
###############################################################################

use strict;

sub show_userprofile {
    $vr::dbh->begin_work;
    eval { &_load_profile($vr::GET{'user'}); };
    if ($@) { die "Died because: $@"; }

    if (!$vr::db{'user_name'}) { &_redirect('members/') }

    if ($vr::db{'spec_group_id'}) {
        $vr::db{'senior_group_title'} = $vr::db{'spec_group_title'};
        $vr::db{'senior_group_image'} = $vr::db{'spec_group_image'};
        $vr::db{'senior_group_color'} = $vr::db{'spec_group_color'};
    } else {
        $vr::db{'senior_group_title'} = $vr::db{'post_group_title'};
        $vr::db{'senior_group_image'} = $vr::db{'post_group_image'};
        $vr::db{'senior_group_color'} = $vr::db{'post_group_color'};
    }

    if ($vr::db{'last_online'} < $vr::db{'reg_time'}) {
        $vr::db{'last_online'} = $vr::db{'reg_time'}
    }

    our $action_buttons = '<ul class="action_buttons column_right alpha omega eleven">';

    if (!$vr::viewer{'is_guest'}) {
        $action_buttons
            .= &_show_footer_item("prepare_new_pm_thread", "user=$vr::db{'user_id'}", "big_add",
            "Send a Message",
            "last", "");

        if ($vr::viewer{'can_admin'}) {
            $action_buttons
                .= qq{<li class="column_right"><a href="$vr::config{'base_url'}/settings/$vr::GET{'user'}" class="top_right_round"><img src="$vr::config{'base_url'}/template/vr_green/img/icons_silk/pencil.png" />Edit Profile</a></li>};
        } elsif ($vr::viewer{'user_name'} eq $vr::GET{'user'}) {
            $action_buttons
                .= qq{<li class="column_right"><a href="$vr::config{'base_url'}/settings/" class="top_right_round"><img src="$vr::config{'base_url'}/template/vr_green/img/icons_silk/pencil.png" />Edit Profile</a></li>};
        }
    }

    $action_buttons .= '</ul>';

    $vr::tmpl{'page_title'} = "$vr::db{'display_name'} - Profile";
    &_format_template('show_userprofile');

}

sub edit_profile {
    my $user = undef;
    if    (!$vr::GET{'user_name'})   { $user = $vr::viewer{'user_name'}; }
    elsif ($vr::viewer{'can_admin'}) { $user = $vr::GET{'user_name'} }
    else                             { &_redirect(''); }

    $vr::dbh->begin_work;
    eval { &_load_profile($user); };
    if ($@) { die "Died because: $@"; }

    $tmpl::form_action = 'save_profile';

    &_format_template;
}

sub save_profile {
    my $message_id = undef;

    if ($vr::POST{'birthday_day'} && $vr::POST{'birthday_month'} && $vr::POST{'birthday_year'}) {
        $vr::POST{'birthday'}
            = qq~$vr::POST{'birthday_year'}-$vr::POST{'birthday_month'}-$vr::POST{'birthday_day'}~;
    } elsif ($vr::POST{'birthday_day'} && $vr::POST{'birthday_month'}) {
        $vr::POST{'birthday'} = qq~1900-$vr::POST{'birthday_month'}-$vr::POST{'birthday_day'}~;
    }

    $vr::dbh->begin_work;
    eval {
        if ($vr::POST{'attach_file'}) {
            &_write_message(
                $vr::POST{'user_id'}, $vr::config{'gmtime'},
                $vr::viewer{'ip_address'},
                $vr::POST{'attach_file'},
                "My Avatar $vr::POST{'usertext'}"
            );
            $message_id = $vr::dbh->{'mysql_insertid'};

            my $fake_usertext = '';
            if ($vr::POST{'usertext'} eq '') {
                $fake_usertext = "Avatar: $vr::POST{'display_name'}";
            } else {
                $fake_usertext = $vr::POST{'usertext'};
            }

            &_write_threads($fake_usertext, $message_id, 'avatars', 'xx', $vr::POST{'user_id'});
            &_update_board_total_messages('avatars', $vr::config{'gmtime'});
        }
        &_write_profile($message_id);
        $vr::dbh->commit;
    };
    if ($@) { die "Died in show_messages: $@"; }

    &_finish_attachments($vr::POST{'attach_file'}, $vr::POST{'attach_ext'}, $message_id);

    &_redirect("user/$vr::POST{'user_name'}");
}

sub users_recent_posts {
    my $page_offset
        = ($vr::GET{'page'} * $vr::config{'posts_per_page'} - $vr::config{'posts_per_page'});

    $vr::dbh->begin_work;
    eval {
        &_load_profile($vr::GET{'user'});
        &_get_recent_posts($vr::db{'user_id'}, $page_offset, $vr::config{'posts_per_page'});
        &_get_recent_post_count($vr::db{'user_id'});
    };
    if ($@) { die "Died because: $@"; }

    our $total_pages = int(($vr::db{'total_results'} / $vr::config{'posts_per_page'}) + 0.9999)
        ;    # Emulate ceil...

    $vr::tmpl{'page_title'} = "$vr::db{'display_name'} - Profile";
    &_format_template('users_recent_posts');
}

sub show_memberlist {
    my $page_offset
        = ($vr::GET{'page'} * $vr::config{'members_per_page'} - $vr::config{'members_per_page'});

    $vr::dbh->begin_work;
    eval {
        &_load_memberlist($page_offset, $vr::config{'members_per_page'}, $vr::GET{'type'});
        &_total_member_count();
    };
    if ($@) { die "Died because: $@"; }

    our $total_pages = int(($vr::db{'total_members'} / $vr::config{'members_per_page'}) + 0.9999)
        ;    # Emulate ceil...

    $vr::tmpl{'page_title'} = "View Members";
    &_format_template('show_memberlist');
}

1;

