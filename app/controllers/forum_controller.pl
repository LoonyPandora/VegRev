###############################################################################
# forum_controller.pl
# =============================================================================
# Version:    Vegetable Revolution 3.0
# Released:   1st June 2009
# Revision:   $Rev$
# Copyright:  James Aitken <http://www.loonypandora.com>
###############################################################################

use strict;
use HTML::Entities qw/encode_entities_numeric/;

sub show_boards {
    $vr::dbh->begin_work;
    eval {
        &_board_list('forum', '0', '0', '0');
        &_category_info('forum');
    };

    if ($@) { die "Died because: $@"; }

    $vr::tmpl{'page_title'} = "$vr::db{'category_title'}, $vr::db{'category_description'}";
    &_format_template;
}

sub show_threads {

    # Security
    if (!$vr::GET{'id'}) { &_redirect(''); }
    if ($vr::GET{'id'} eq 'private' && $vr::viewer{'is_guest'}) { &_redirect(''); }

    my $page_offset
        = ($vr::GET{'page'} * $vr::config{'threads_per_page'} - $vr::config{'threads_per_page'});

    # DB Work
    $vr::dbh->begin_work;
    eval {
        &_thread_list(
            $vr::GET{'id'}, $page_offset,
            $vr::config{'threads_per_page'},
            'ORDER BY threads.thread_star DESC'
        );
        &_board_info($vr::GET{'id'});
    };
    if ($@) { die "Died because: $@"; }

    if (!$vr::db{'board_id'}) { &_redirect(''); }
    if (!$vr::viewer{'spec_group_id'} && $vr::db{'board_id'} eq 'private') {
        &_redirect('forum');
    }

    our $total_pages
        = int(($vr::db{'board_thread_total'} / $vr::config{'threads_per_page'}) + 0.9999)
        ;    # Emulate ceil...

    if ($vr::GET{'id'} ne 'archive' && $vr::GET{'id'} ne 'yahoo') {
        our $action_buttons = '<ul class="action_buttons column_right alpha omega eleven">';

        if (!$vr::viewer{'is_guest'}) {
            $action_buttons .= &_show_footer_item(
                "prepare_new_thread", "board_id=$vr::db{'board_id'}",
                "big_add", "Start a Thread",
                "last", ""
            );
            $action_buttons
                .= &_show_footer_item("prepare_new_poll", "board_id=$vr::db{'board_id'}",
                "add_poll", "Start a Poll", "", "");
        }

        $action_buttons .= '</ul>';

    }

    &_write_board_viewers;

    $vr::tmpl{'page_title'} = "$vr::db{'board_title'}, $vr::db{'board_description'}";
    &_format_template('show_threads');
}

sub show_messages {

    # Security
    if (!$vr::GET{'id'} || !$vr::GET{'board_id'}) { &_redirect(''); }
    if ($vr::GET{'board_id'} eq 'private' && $vr::viewer{'is_guest'}) { &_redirect(''); }

    if ($vr::GET{'page'} eq 'new') {
        my $read_messages = &_redirect_to_new($vr::GET{'id'});
        my $read_pages = int(($read_messages / $vr::config{'posts_per_page'}) + 0.9999);    # Emulate ceil...
        if ($read_pages < 1) { $read_pages = 1; }

        &_redirect("forum/$vr::GET{'board_id'}/$vr::GET{'id'}/$read_pages");
    }

    if ($vr::GET{'page'} eq 'all') {
        if (!$vr::GET{'allpage'}) { $vr::GET{'allpage'} = 1; }
        $vr::GET{'page'}                 = $vr::GET{'allpage'};
        $vr::config{'posts_per_page'}    = 150;
        $vr::config{'messages_per_page'} = 150;
    }

    my $page_offset = ($vr::GET{'page'} * $vr::config{'posts_per_page'} - $vr::config{'posts_per_page'});
    $page_offset = 0 if $page_offset < 0;

    &_write_thread_viewers;

    # DB Work
    $vr::dbh->begin_work;
    eval {
        &_read_thread_viewers;
        our $now_viewing = $vr::loop->fetchall_hashref('user_id');
        &_message_list($vr::GET{'id'}, $page_offset, $vr::config{'posts_per_page'});
        &_thread_info($vr::GET{'id'});
        if ($vr::db{'poll_id'}) {
            &_show_poll($vr::GET{'id'});
            &_poll_info($vr::GET{'id'});
        }
    };
    if ($@) { die "Died in show_messages: $@"; }

    # If it's not a valid thread (i.e. it has no messages) - redirect to the board
    if (!$vr::db{'thread_messages'}) { &_redirect("forum/$vr::GET{'board_id'}/"); }
    if ($vr::db{'thread_deleted'})   { &_redirect("forum/$vr::GET{'board_id'}/") }

    # If this is a private board, you can't see it!
    if ($vr::db{'board_id'} eq 'private' && !$vr::viewer{'spec_group_id'}) {
        &_redirect("forum/$vr::db{'board_id'}");
    }

    # Start of the footer buttons
    our $total_pages
        = int(($vr::db{'thread_messages'} / $vr::config{'messages_per_page'}) + 0.9999)
        ;    # Emulate ceil...

    our $action_buttons = '<ul class="action_buttons column_right alpha omega eleven">';

    if (!$vr::viewer{'is_guest'} && !$vr::db{'thread_locked'}) {
        $action_buttons
            .= &_show_footer_item("prepare_new_message",
            "thread_id=$vr::db{'thread_id'};board_id=$vr::GET{'board_id'}",
            "big_add", "Reply", "last", "");
        if (!$vr::db{'poll_id'}) {
            $action_buttons
                .= &_show_footer_item("prepare_add_poll",
                "thread_id=$vr::db{'thread_id'};board_id=$vr::GET{'board_id'}",
                "add_poll", "Add Poll", "", "");
        } elsif ($vr::viewer{'can_mod'} || $vr::viewer{'can_admin'}) {
            $action_buttons
                .= &_show_footer_item("prepare_delete_poll",
                "thread_id=$vr::db{'thread_id'};board_id=$vr::GET{'board_id'}",
                "cross", "Delete Poll", "", "");
        }
    }

    if ($vr::viewer{'can_mod'} || $vr::viewer{'can_admin'}) {
        $action_buttons .= qq~
      <li class="column_right"><a href="javascript:toggle_admin_nav();"><img src="$vr::viewer{'template_url'}/img/icons_silk/gear.png" /> Admin</a><ul id="admin_nav">~;
        my $lock_text = undef;
        my $star_text = undef;
        if   ($vr::db{'thread_locked'}) { $lock_text = 'Unlock'; }
        else                            { $lock_text = 'Lock'; }
        if   ($vr::db{'thread_star'} == 2147483647) { $star_text = 'Unsticky'; }
        else                                        { $star_text = 'Sticky'; }

        $action_buttons .= qq~
          <li><a href="$vr::config{'base_url'}/postform/prepare_delete_thread/?thread_id=$vr::db{'thread_id'};board_id=$vr::db{'board_id'}" rel="facebox">Delete Thread</a></li>
          <li><a href="$vr::config{'base_url'}/postform/prepare_edit_thread/?thread_id=$vr::db{'thread_id'};board_id=$vr::db{'board_id'}" rel="facebox">Edit Thread</a></li>
          <li><a href="$vr::config{'base_url'}/postform/prepare_move_thread/?thread_id=$vr::db{'thread_id'};board_id=$vr::db{'board_id'}" rel="facebox">Move Thread</a></li>
          <li><a href="$vr::config{'base_url'}/postform/prepare_lock_thread/?thread_id=$vr::db{'thread_id'};board_id=$vr::db{'board_id'}" rel="facebox">$lock_text Thread</a></li>
          <li><a href="$vr::config{'base_url'}/postform/prepare_star_thread/?thread_id=$vr::db{'thread_id'};board_id=$vr::db{'board_id'}" rel="facebox">$star_text Thread</a></li>
      ~;

        $action_buttons .= qq~</ul></li>~;
    }

    $action_buttons .= '</ul>';

    # Buttons over, lets set titles, and do the template!
    $vr::tmpl{'page_title'} = "$vr::db{'thread_subject'}";

    &_format_template('show_messages');
}

sub show_photo {

    # Security
    if (!$vr::GET{'id'} || !$vr::GET{'board_id'}) { &_redirect(''); }

    my $page_offset = ($vr::GET{'page'} * $vr::config{'posts_per_page'} - $vr::config{'posts_per_page'});
    $page_offset = 0 if $page_offset < 0;

    &_write_thread_viewers;

    # DB Work
    $vr::dbh->begin_work;
    eval {
        &_read_thread_viewers;
        our $now_viewing = $vr::loop->fetchall_hashref('user_id');
        &_message_list($vr::GET{'id'}, $page_offset, $vr::config{'posts_per_page'});
        &_thread_info($vr::GET{'id'});
        if ($vr::db{'poll_id'}) {
            &_show_poll($vr::GET{'id'});
            &_poll_info($vr::GET{'id'});
        }
    };
    if ($@) { die "Died in show_messages: $@"; }

    # If it's not a valid thread (i.e. it has no messages) - redirect to the board
    if (!$vr::db{'thread_messages'}) { &_redirect("gallery/$vr::GET{'board_id'}/"); }
    if ($vr::db{'thread_deleted'})   { &_redirect("gallery/$vr::GET{'board_id'}/") }

    # Start of the footer buttons
    our $total_pages
        = int(($vr::db{'thread_messages'} / $vr::config{'messages_per_page'}) + 0.9999)
        ;    # Emulate ceil...

    our $action_buttons = '<ul class="action_buttons column_right alpha omega eleven">';

    if (!$vr::viewer{'is_guest'} && !$vr::db{'thread_locked'}) {
        $action_buttons
            .= &_show_footer_item("prepare_new_comment",
            "thread_id=$vr::db{'thread_id'};board_id=$vr::GET{'board_id'}",
            "big_add", "Reply", "last", "");
        if (!$vr::db{'poll_id'}) {
            $action_buttons
                .= &_show_footer_item("prepare_add_poll",
                "thread_id=$vr::db{'thread_id'};board_id=$vr::GET{'board_id'}",
                "add_poll", "Add Poll", "", "");
        } elsif ($vr::viewer{'can_mod'} || $vr::viewer{'can_admin'}) {
            $action_buttons
                .= &_show_footer_item("prepare_delete_poll",
                "thread_id=$vr::db{'thread_id'};board_id=$vr::GET{'board_id'}",
                "cross", "Delete Poll", "", "");
        }
    }

    if ($vr::viewer{'can_mod'} || $vr::viewer{'can_admin'}) {
        $action_buttons .= qq~
      <li class="column_right"><a href="javascript:toggle_admin_nav();"><img src="$vr::viewer{'template_url'}/img/icons_silk/gear.png" /> Admin</a><ul id="admin_nav">~;

        $action_buttons .= qq~
          <li><a href="$vr::config{'base_url'}/postform/prepare_delete_thread/?thread_id=$vr::db{'thread_id'};board_id=$vr::db{'board_id'}" rel="facebox">Delete Photo</a></li>
          <li><a href="$vr::config{'base_url'}/postform/prepare_edit_thread/?thread_id=$vr::db{'thread_id'};board_id=$vr::db{'board_id'}" rel="facebox">Edit Photo</a></li>
          <li><a href="$vr::config{'base_url'}/postform/prepare_move_thread/?thread_id=$vr::db{'thread_id'};board_id=$vr::db{'board_id'}" rel="facebox">Move Photo</a></li>
      ~;

        $action_buttons .= qq~</ul></li>~;
    }

    $action_buttons .= '</ul>';

    $vr::tmpl{'page_title'} = "$vr::db{'thread_subject'}";
    &_format_template('show_photo');
}

sub prepare_new_message {
    $tmpl::category = 'forum';
    &_format_template;
}

sub prepare_new_comment {
    $tmpl::category = 'gallery';
    &_format_template;
}

sub prepare_new_thread {
    $tmpl::category = 'forum';
    &_format_template;
}

sub prepare_new_photo {
    $tmpl::category = 'gallery';
    &_format_template;
}

sub do_new_thread {
    my $message_id = undef;
    $vr::dbh->begin_work;
    eval {
        &_write_message(
            $vr::viewer{'user_id'},   $vr::config{'gmtime'}, $vr::viewer{'ip_address'},
            $vr::POST{'attach_file'}, $vr::POST{'message'}
        );
        $message_id = $vr::dbh->{'mysql_insertid'};
        &_write_threads(
            $vr::POST{'subject'}, $message_id, $vr::POST{'board_id'},
            'xx',                 $vr::viewer{'user_id'}
        );
        &_update_board_total_messages($vr::POST{'board_id'}, $vr::config{'gmtime'});
        &_update_site_stats('thread');
        &_update_last_online($vr::viewer{'user_id'}, $vr::viewer{'ip_address'});
        $vr::dbh->commit;
    };
    if ($@) { die "Died in show_messages: $@"; }

    &_finish_attachments($vr::POST{'attach_file'}, $vr::POST{'attach_ext'}, $message_id);

    &_redirect("$vr::POST{'category_id'}/$vr::POST{'board_id'}/$vr::config{'gmtime'}/");
}

sub do_new_message {
    my $message_id = undef;

    $vr::dbh->begin_work;
    eval {
        &_write_message(
            $vr::viewer{'user_id'},   $vr::POST{'thread_id'}, $vr::viewer{'ip_address'},
            $vr::POST{'attach_file'}, $vr::POST{'message'}
        );
        $message_id = $vr::dbh->{'mysql_insertid'};

        &_thread_info($vr::POST{'thread_id'});
        &_update_board_total_messages($vr::db{'board_id'}, $vr::POST{'thread_id'});
        &_update_threads($vr::POST{'thread_id'}, $vr::viewer{'user_id'}, $vr::db{'thread_star'});
        &_update_site_stats('post');
        &_update_last_online($vr::viewer{'user_id'}, $vr::viewer{'ip_address'});
        $vr::dbh->commit;
    };
    if ($@) { die "Died in show_messages: $@"; }

    &_finish_attachments($vr::POST{'attach_file'}, $vr::POST{'attach_ext'}, $message_id);

    my $last_page = int(($vr::db{'thread_messages'} / $vr::config{'messages_per_page'}) + 0.9999);    # Emulate ceil...

    if ($last_page == 1) {
        &_redirect("$vr::POST{'category_id'}/$vr::POST{'board_id'}/$vr::POST{'thread_id'}/");
    } else {
        &_redirect(
            "$vr::POST{'category_id'}/$vr::POST{'board_id'}/$vr::POST{'thread_id'}/$last_page");
    }
}

sub show_gallery_threads {

    # Security
    if (!$vr::GET{'id'}) { &_redirect(''); }

    my $page_offset
        = ($vr::GET{'page'} * $vr::config{'photos_per_page'} - $vr::config{'photos_per_page'});

    # DB Work
    $vr::dbh->begin_work;
    eval {
        &_thread_list(
            $vr::GET{'id'}, $page_offset,
            $vr::config{'photos_per_page'},
            'ORDER BY threads.thread_id DESC'
        );
        &_board_info($vr::GET{'id'});
    };

    if ($@) { die "Died because: $@"; }

    our $total_pages
        = int(($vr::db{'board_thread_total'} / $vr::config{'photos_per_page'}) + 0.9999)
        ;    # Emulate ceil...

    if ($vr::GET{'id'} ne 'archive' && $vr::GET{'id'} ne 'yahoo') {
        our $action_buttons = '<ul class="action_buttons column_right alpha omega eleven">';

        if (!$vr::viewer{'is_guest'}) {
            $action_buttons
                .= &_show_footer_item("prepare_new_photo", "board_id=$vr::db{'board_id'}",
                "big_add", "Add a Photo", "last", "");

            #      $action_buttons .= &_show_footer_item("prepare_new_poll", "board_id=$vr::db{'board_id'}" ,"add_poll", "Start a Poll", "", "");
        }

        $action_buttons .= '</ul>';

    }

    $vr::tmpl{'page_title'} = "$vr::db{'board_title'}, $vr::db{'board_description'}";
    &_format_template('show_gallery_threads');
}

sub show_gallery_boards {
    $vr::dbh->begin_work;
    eval {
        &_board_list('gallery', '0', '0', '0');
        &_category_info('gallery');
    };

    if ($@) { die "Died because: $@"; }

    $vr::tmpl{'page_title'} = "$vr::db{'category_title'}, $vr::db{'category_description'}";
    &_format_template;

}

sub show_archive_boards {
    $vr::dbh->begin_work;
    eval {
        &_board_list('archive', '0', '0', '0');
        &_category_info('archive');
        &_shout_total();
    };

    if ($@) { die "Died because: $@"; }

    $vr::tmpl{'page_title'} = "$vr::db{'category_title'}, $vr::db{'category_description'}";
    &_format_template('show_boards');
}

sub show_portal {

    # Work out the dates for the next few days. Rails has some LOVELY features for this... *le sigh*
    my (undef, undef, undef, $day_today, $month_today, undef) = gmtime($vr::config{'gmtime'});
    my (undef, undef, undef, $day_plusone, $month_plusone, undef)
        = gmtime($vr::config{'gmtime'} + 86400);
    my (undef, undef, undef, $day_plustwo, $month_plustwo, undef)
        = gmtime($vr::config{'gmtime'} + 172800);
    my (undef, undef, undef, $day_plusthree, $month_plusthree, undef)
        = gmtime($vr::config{'gmtime'} + 259200);
    my (undef, undef, undef, $day_plusfour, $month_plusfour, undef)
        = gmtime($vr::config{'gmtime'} + 345600);
    $month_today++;
    $month_plusone++;
    $month_plustwo++;
    $month_plusthree++;
    $month_plusfour++;

    $vr::dbh->begin_work;
    eval {
        if ($vr::viewer{'spec_group_id'} == 4) {
            &_recent_posts('forum', '8', '1', '0', '1',
                'ORDER BY threads.thread_last_message_time DESC');
            our $recent_posts = $vr::loop->fetchall_hashref('thread_last_message_time');
        } elsif ($vr::viewer{'spec_group_id'}) {
            &_recent_posts('forum', '8', '1', '1', '1',
                'ORDER BY threads.thread_last_message_time DESC');
            our $recent_posts = $vr::loop->fetchall_hashref('thread_last_message_time');
        } else {
            &_recent_posts('forum', '8', '0', '0', '0',
                'ORDER BY threads.thread_last_message_time DESC');
            our $recent_posts = $vr::loop->fetchall_hashref('thread_last_message_time');
        }
        &_recent_posts('gallery', '6', '0', '0', '0', 'ORDER BY threads.thread_id DESC');
        our $recent_photos = $vr::loop->fetchall_hashref('thread_id');
        &_recent_posts('gallery', '4', '0', '0', '0',
            "AND threads.thread_messages > '1' ORDER BY threads.thread_last_message_time DESC");
        our $recent_photo_comments = $vr::loop->fetchall_hashref('thread_last_message_time');
        &_list_active_users;
        our $users_online = $vr::loop->fetchall_hashref('user_id');

        &_upcoming_birthdays($day_today, $month_today);
        our $today_birthdays = $vr::loop->fetchall_hashref('user_id');
        &_upcoming_birthdays($day_plusone, $month_plusone);
        our $tomorrow_birthdays = $vr::loop->fetchall_hashref('user_id');
        &_upcoming_birthdays($day_plustwo, $month_plustwo);
        our $two_day_birthdays = $vr::loop->fetchall_hashref('user_id');
        &_upcoming_birthdays($day_plusthree, $month_plusthree);
        our $three_day_birthdays = $vr::loop->fetchall_hashref('user_id');
        &_upcoming_birthdays($day_plusfour, $month_plusfour);
        our $four_day_birthdays = $vr::loop->fetchall_hashref('user_id');

        &_get_news;
        our $recent_news = $vr::loop->fetchall_hashref('thread_id');

        &_get_site_stats;
        if (scalar keys %{$vr::users_online} >= $vr::db{'forum_max_online'}) {
            &_set_site_stats(scalar keys %{$vr::users_online});
        }
        $vr::dbh->commit;
    };

    if ($@) { die "Died because: $@"; }

    $vr::tmpl{'page_title'} = 'Home';
    &_format_template;
}

sub prepare_edit_message {

    # DB Work
    $vr::dbh->begin_work;
    eval { &_single_message($vr::GET{'post_id'}); };
    if ($@) { die "Died in show_messages: $@"; }

    &_format_template;
}

sub do_edit_message {
    $vr::dbh->begin_work;
    eval {
        &_do_save_message($vr::POST{'post_id'});
        $vr::dbh->commit;
    };
    if ($@) {
        die "Transaction aborted because $@";
        eval { $vr::dbh->rollback };
    }

    &_redirect("forum/$vr::POST{'board_id'}/$vr::POST{'thread_id'}/$vr::POST{'page'}/");
}

sub prepare_quote_message {

    # DB Work
    $vr::dbh->begin_work;
    eval { &_single_message($vr::GET{'post_id'}); };
    if ($@) { die "Died in show_messages: $@"; }

    # HTML Entities doesn't do square brackets...
    my $quoted_name = $vr::db{'display_name'};

    $quoted_name =~ s/\[/&#91;/g;
    $quoted_name =~ s/\]/&#93;/g;

    $vr::db{'message_body'}
        = qq~\[quote="$vr::db{'user_name'}|$quoted_name|$vr::db{'thread_id'}|$vr::db{'message_id'}|$vr::db{'message_time'}"\]$vr::db{'message_body'}\[\/quote\]~;

    $tmpl::category = 'forum';
    &_format_template('prepare_new_message');
}

sub prepare_delete_message {

    $tmpl::form_action   = 'do_delete_message';
    $tmpl::form_title    = 'Delete Message';
    $tmpl::button_submit = 'Delete Message';
    $tmpl::dialog_text   = 'Are you sure you want to delete this message?';

    &_format_template('facebox/_dialog_box');

}

sub do_delete_message {
    $vr::dbh->begin_work;
    eval {
        &_do_delete_message($vr::POST{'post_id'}, $vr::POST{'thread_id'}, $vr::POST{'board_id'});
        $vr::dbh->commit;
    };
    if ($@) {
        die "Transaction aborted because $@";
        eval { $vr::dbh->rollback };
    }

    &_redirect("forum/$vr::POST{'board_id'}/$vr::POST{'thread_id'}/$vr::POST{'page'}/");

}

sub prepare_delete_thread {

    $tmpl::form_action   = 'do_delete_thread';
    $tmpl::form_title    = 'Delete Thread';
    $tmpl::button_submit = 'Delete Thread';
    $tmpl::dialog_text
        = 'Are you sure you want to delete this thread, and all the messages in it?';

    &_format_template('/facebox/_dialog_box');

}

sub do_delete_thread {
    $vr::dbh->begin_work;
    eval {
        &_do_delete_thread($vr::POST{'thread_id'}, $vr::POST{'board_id'});
        $vr::dbh->commit;
    };
    if ($@) {
        die "Transaction aborted because $@";
        eval { $vr::dbh->rollback };
    }

    &_redirect("forum/$vr::POST{'board_id'}/");

}

sub prepare_lock_thread {

    $vr::dbh->begin_work;
    eval { &_thread_info($vr::GET{'thread_id'}); };
    if ($@) { die "Transaction aborted because $@"; }

    if (!$vr::db{'thread_locked'}) {
        $tmpl::form_action   = 'do_lock_thread';
        $tmpl::form_title    = 'Lock Thread';
        $tmpl::button_submit = 'Lock Thread';
        $tmpl::dialog_text   = 'Are you sure you want to lock this thread?';
        $tmpl::category      = 'forum';
    } else {
        $tmpl::form_action   = 'do_unlock_thread';
        $tmpl::form_title    = 'Unlock Thread';
        $tmpl::button_submit = 'Unlock Thread';
        $tmpl::dialog_text   = 'Are you sure you want to unlock this thread?';
        $tmpl::category      = 'forum';
    }

    &_format_template('/facebox/_dialog_box');

}

sub do_lock_thread {
    $vr::dbh->begin_work;
    eval {
        &_do_lock_thread($vr::POST{'thread_id'});
        $vr::dbh->commit;
    };
    if ($@) {
        die "Transaction aborted because $@";
        eval { $vr::dbh->rollback };
    }

    &_redirect("$vr::POST{'category_id'}/$vr::POST{'board_id'}/");
}

sub do_unlock_thread {
    $vr::dbh->begin_work;
    eval {
        &_do_unlock_thread($vr::POST{'thread_id'});
        $vr::dbh->commit;
    };
    if ($@) {
        die "Transaction aborted because $@";
        eval { $vr::dbh->rollback };
    }

    &_redirect(
        "$vr::POST{'category_id'}/$vr::POST{'board_id'}/$vr::POST{'thread_id'}/$vr::POST{'page'}"
    );
}

sub prepare_edit_thread {

    $tmpl::form_action   = 'do_edit_thread';
    $tmpl::form_title    = 'Edit Thread Details';
    $tmpl::button_submit = 'Save Changes';

    # DB Work
    $vr::dbh->begin_work;
    eval { &_thread_info($vr::GET{'thread_id'}); };
    if ($@) { die "Died in show_messages: $@"; }

    &_format_template;
}

sub do_edit_thread {
    $vr::dbh->begin_work;
    eval {
        &_do_edit_thread($vr::POST{'thread_id'}, $vr::POST{'subject'},
            $vr::POST{'thread_messages'});
        $vr::dbh->commit;
    };
    if ($@) {
        die "Transaction aborted because $@";
        eval { $vr::dbh->rollback };
    }

    &_redirect("forum/$vr::POST{'board_id'}/$vr::POST{'thread_id'}/$vr::POST{'page'}/");
}

sub prepare_star_thread {

    $vr::dbh->begin_work;
    eval { &_thread_info($vr::GET{'thread_id'}); };
    if ($@) { die "Transaction aborted because $@"; }

    if ($vr::db{'thread_star'} != 2147483647) {
        $tmpl::form_action   = 'do_star_thread';
        $tmpl::form_title    = 'Sticky Thread';
        $tmpl::button_submit = 'Sticky Thread';
        $tmpl::dialog_text   = 'Are you sure you want to sticky this thread?';
        $tmpl::category      = 'forum';
    } else {
        $tmpl::form_action   = 'do_unstar_thread';
        $tmpl::form_title    = 'Unsticky Thread';
        $tmpl::button_submit = 'Unsticky Thread';
        $tmpl::dialog_text   = 'Are you sure you want to unsticky this thread?';
        $tmpl::category      = 'forum';
    }

    &_format_template('/facebox/_dialog_box');

}

sub do_star_thread {
    $vr::dbh->begin_work;
    eval {
        &_do_star_thread($vr::POST{'thread_id'});
        $vr::dbh->commit;
    };
    if ($@) {
        die "Transaction aborted because $@";
        eval { $vr::dbh->rollback };
    }

    &_redirect(
        "$vr::POST{'category_id'}/$vr::POST{'board_id'}/$vr::POST{'thread_id'}/$vr::POST{'page'}"
    );

}

sub do_unstar_thread {
    $vr::dbh->begin_work;
    eval {
        &_do_unstar_thread($vr::POST{'thread_id'});
        $vr::dbh->commit;
    };
    if ($@) {
        die "Transaction aborted because $@";
        eval { $vr::dbh->rollback };
    }

    &_redirect(
        "$vr::POST{'category_id'}/$vr::POST{'board_id'}/$vr::POST{'thread_id'}/$vr::POST{'page'}"
    );

}

sub prepare_move_thread {

    $tmpl::form_action   = 'do_move_thread';
    $tmpl::form_title    = 'Move Thread';
    $tmpl::button_submit = 'Move Thread';

    # DB Work
    $vr::dbh->begin_work;
    eval {
        &_thread_info($vr::GET{'thread_id'});
        &_simple_board_list();
    };
    if ($@) { die "Died in show_messages: $@"; }

    &_format_template();
}

sub do_move_thread {
    $vr::dbh->begin_work;
    eval {
        &_do_move_thread($vr::POST{'thread_id'}, $vr::POST{'new_board_id'});
        $vr::dbh->commit;
    };
    if ($@) {
        die "Transaction aborted because $@";
        eval { $vr::dbh->rollback };
    }

    &_redirect("forum/$vr::POST{'board_id'}/$vr::POST{'thread_id'}/$vr::POST{'page'}/");
}

sub big_boards {

    &_get_site_stats;
    my $posts = $vr::db{'forum_total_posts'} + $vr::db{'forum_total_shouts'};

    print "Content-Type: text/html; charset=utf-8\n\n";

    print qq{<info>Statistics</info>
<members>$vr::db{'forum_total_users'}</members>
<posts>$posts</posts>
<threads>$vr::db{'forum_total_threads'}</threads>
<notes>
Posts are split between following pages:
$vr::config{'base_url'}/forum/
$vr::config{'base_url'}/archive/
$vr::config{'base_url'}/gallery/

Members List:
$vr::config{'base_url'}/members/
</notes>
    };
}

1;
