###############################################################################
# controllers/messages.pl
# =============================================================================
# Version:    Vegetable Revolution 3.0
# Released:   1st June 2009
# Revision:   $Rev$
# Copyright:  James Aitken <http://loonypandora.co.uk>
###############################################################################

use strict;

sub show_pm_inbox {

    # Security
    if ($vr::GET{'is_guest'}) { &_redirect(''); }

    my $page_offset = (
        $vr::GET{'page'} * $vr::config{'messages_per_page'} - $vr::config{'messages_per_page'});

    # DB Work
    $vr::dbh->begin_work;
    eval {
        &_list_private_conversations($page_offset);
        &_pm_list_info();
    };

    if ($@) { die "Died because: $@"; }

    our $total_pages = int(($vr::db{'thread_num'} / $vr::config{'threads_per_page'}) + 0.9999)
        ;    # Emulate ceil...

    our $action_buttons = '<ul class="action_buttons column_right alpha omega eleven">';

    if (!$vr::viewer{'is_guest'}) {
        $action_buttons
            .= &_show_footer_item("prepare_new_pm_thread", "", "big_add", "Send a Message",
            "last", "");
    }

    $action_buttons .= '</ul>';

    $vr::tmpl{'page_title'} = "Private Messages - Inbox";
    &_format_template('show_pm_inbox');
}

sub show_pm_thread {

    # Security
    if (!$vr::GET{'id'}) { &_redirect(''); }

    my $page_offset
        = ($vr::GET{'page'} * $vr::config{'posts_per_page'} - $vr::config{'posts_per_page'});

    # DB Work
    $vr::dbh->begin_work;
    eval {
        &_list_private_messages($vr::GET{'id'}, $page_offset, $vr::config{'posts_per_page'});
        &_pm_thread_info($vr::GET{'id'});
        &_mark_pm_unread($vr::GET{'id'});
    };
    if ($@) { die "Died in show_messages: $@"; }

    if ($vr::db{'send_user_name'} eq $vr::viewer{'user_name'}) {
        $vr::db{'user_id'}          = $vr::db{'receive_user_id'};
        $vr::db{'user_name'}        = $vr::db{'receive_user_name'};
        $vr::db{'display_name'}     = $vr::db{'receive_display_name'};
        $vr::db{'spec_group_color'} = $vr::db{'receive_spec_group_color'};
    } else {
        $vr::db{'user_id'}          = $vr::db{'send_user_id'};
        $vr::db{'user_name'}        = $vr::db{'send_user_name'};
        $vr::db{'display_name'}     = $vr::db{'send_display_name'};
        $vr::db{'spec_group_color'} = $vr::db{'send_spec_group_color'};
    }

    our $total_pages
        = int(($vr::db{'pm_total_messages'} / $vr::config{'messages_per_page'}) + 0.9999)
        ;    # Emulate ceil...
    our $action_buttons = '<ul class="action_buttons column_right alpha omega eleven">';

    if (!$vr::viewer{'is_guest'}) {
        $action_buttons
            .= &_show_footer_item("prepare_new_pm_message",
            "thread_id=$vr::GET{'id'};user=$vr::db{'user_id'}",
            "big_add", "Reply", "last", "");
    }

    $action_buttons .= '</ul>';

    $vr::tmpl{'page_title'} = " - Private Message: $vr::db{'pm_subject'}";
    &_format_template('show_pm_thread');

    # Write changes to unread count after we close the db connection
    eval { $vr::dbh->commit; };
    if ($@) { die "Died in show_messages: $@"; }
}

sub show_pm_sent {

    # Security
    if ($vr::GET{'is_guest'}) { &_redirect(''); }

    my $page_offset = (
        $vr::GET{'page'} * $vr::config{'messages_per_page'} - $vr::config{'messages_per_page'});

    # DB Work
    $vr::dbh->begin_work;
    eval {
        &_list_sent_messages($page_offset);
        &_pm_list_info();
    };

    if ($@) { die "Died because: $@"; }

    our $total_pages = int(($vr::db{'thread_num'} / $vr::config{'messages_per_page'}) + 0.9999)
        ;    # Emulate ceil...

    $vr::tmpl{'page_title'} = "Private Messages - Sent Items";
    &_format_template();
}

sub prepare_new_pm_thread {

    # DB Work
    $vr::dbh->begin_work;
    eval { &_load_recipient($vr::GET{'user'}); };
    if ($@) { die "Died in show_messages: $@"; }

    $tmpl::form_action   = 'do_new_pm_thread';
    $tmpl::form_title    = 'Send Private Messsage';
    $tmpl::button_submit = 'Send a Message';

    &_format_template();
}

sub prepare_new_pm_message {

    # DB Work
    $vr::dbh->begin_work;
    eval {
        &_load_recipient($vr::GET{'user'});
        &_pm_thread_info($vr::GET{'thread_id'});
    };
    if ($@) { die "Died in show_messages: $@"; }

    $tmpl::form_action   = 'do_new_pm_message';
    $tmpl::form_title    = 'Send Private Messsage';
    $tmpl::button_submit = 'Send a Message';

    &_format_template();
}

sub do_new_pm_thread {
    my $message_id = undef;
    $vr::dbh->begin_work;
    eval {
        &_write_pm_thread($vr::POST{'recipient'});
        &_write_pm_message($vr::POST{'recipient'}, $vr::config{'gmtime'});
        $vr::dbh->commit;
    };
    if ($@) { die "Died in show_messages: $@"; }

    # &_finish_attachments($vr::POST{'attach_file'}, $vr::POST{'attach_ext'}, $message_id);

    &_redirect("messages/inbox/$vr::config{'gmtime'}/");
}

sub do_new_pm_message {

    my $message_id = undef;
    $vr::dbh->begin_work;
    eval {
        &_write_pm_message($vr::POST{'recipient'}, $vr::POST{'thread_id'});
        $vr::dbh->commit;
    };
    if ($@) { die "Died in show_messages: $@"; }

    # &_finish_attachments($vr::POST{'attach_file'}, $vr::POST{'attach_ext'}, $message_id);

    &_redirect("messages/inbox/$vr::POST{'thread_id'}/");
}

sub confirm_delete_pm_thread {
    $tmpl::form_action   = 'do_delete_pm_thread';
    $tmpl::form_title    = 'Delete Conversation';
    $tmpl::button_submit = 'Delete Conversation';
    $tmpl::dialog_text   = 'Are you sure you want to delete this conversation?';

    &_format_template('facebox/_dialog_box');
}

sub do_delete_pm_thread {
    $vr::dbh->begin_work;
    eval {
        &_do_delete_pm_thread($vr::POST{'thread_id'});
        $vr::dbh->commit;
    };
    if ($@) { die "Died: $@"; }

    &_redirect("messages/inbox/");
}

sub show_pm_saved {

    # Security
    if ($vr::GET{'is_guest'}) { &_redirect(''); }

    my $page_offset = (
        $vr::GET{'page'} * $vr::config{'messages_per_page'} - $vr::config{'messages_per_page'});

    # DB Work
    $vr::dbh->begin_work;
    eval {
        &_list_private_conversations($page_offset);
        &_pm_list_info();
    };

    if ($@) { die "Died because: $@"; }

    our $total_pages = int(($vr::db{'thread_num'} / $vr::config{'threads_per_page'}) + 0.9999)
        ;    # Emulate ceil...

    our $action_buttons = '<ul class="action_buttons column_right alpha omega eleven">';

    if (!$vr::viewer{'is_guest'}) {
        $action_buttons
            .= &_show_footer_item("prepare_new_pm_thread", "", "big_add", "Send a Message",
            "last", "");

        #  $action_buttons .= &_show_footer_item("prepare_new_poll", "board_id=$vr::db{'board_id'}" ,"add_poll", "Start a Poll", "", "");
    }

    $action_buttons .= '</ul>';

    $vr::tmpl{'page_title'} = "Private Messages - Inbox";
    &_format_template('show_pm_inbox');
}

sub show_pm_userlist {
    if ($vr::viewer{'is_guest'}) { return; }
    my $user_details = '[';

    $vr::dbh->begin_work;
    eval {
        &_get_pm_userlist;
        our $userlist = $vr::loop->fetchall_hashref('user_id');
    };

    my $i = 1;
    foreach (keys(%{$vr::userlist})) {
        $user_details .= '[';
        $user_details .= %{$vr::userlist}->{$_}{'user_id'};
        $user_details .= ',"' . %{$vr::userlist}->{$_}{'user_name'} . ' ';
        $user_details .= %{$vr::userlist}->{$_}{'display_name'} . '","';
        $user_details .= %{$vr::userlist}->{$_}{'display_name'};
        $user_details .= '","<img src=\"';
        $user_details .= %{$vr::userlist}->{$_}{'avatar'};
        $user_details .= '\" class=\"column tiny_avatar\" \/> ';
        $user_details .= %{$vr::userlist}->{$_}{'display_name'};
        $user_details .= '<br />';
        $user_details .= %{$vr::userlist}->{$_}{'user_name'};

        if   ($i == scalar keys %{$vr::userlist}) { $user_details .= '"]'; }
        else                                      { $user_details .= '"],'; }
        $i++;
    }

    $user_details .= ']';

    print "Content-Type: text/html\n\n";
    print $user_details;
}

1;

