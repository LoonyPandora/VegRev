###############################################################################
# controllers/user.pl
# =============================================================================
# Version:    Vegetable Revolution 3.0
# Released:   1st June 2009
# Revision:   $Rev$
# Copyright:  James Aitken <http://loonypandora.co.uk>
###############################################################################

use strict;

sub prepare_add_poll {
    if ($vr::viewer{'guest'}) { die("you don't have permission to add a poll"); }

    &_get_category($vr::GET{'board_id'});
    $tmpl::category = $vr::db{'current_category'};

    &_format_template;
}

sub prepare_delete_poll {
    if ($vr::viewer{'guest'}) { die("you don't have permission to delete this poll"); }

    &_get_category($vr::GET{'board_id'});
    $tmpl::category      = $vr::db{'current_category'};
    $tmpl::form_action   = 'do_delete_poll';
    $tmpl::form_title    = 'Delete Poll';
    $tmpl::button_submit = 'Delete Poll';
    $tmpl::dialog_text   = 'Are you sure you want to delete this poll, and all the votes?';

    &_format_template('/facebox/_dialog_box');
}

sub prepare_new_poll {
    if ($vr::viewer{'guest'}) { die("you don't have permission to add a poll"); }

    &_get_category($vr::GET{'board_id'});
    $tmpl::category = $vr::db{'current_category'};

    &_format_template;
}

sub do_vote_poll {
    $vr::dbh->begin_work;
    eval {
        &_do_vote_poll($vr::POST{'thread_id'}, $vr::POST{'poll_option'});
        $vr::dbh->commit;
    };
    if ($@) { die "Died in show_messages: $@"; }

    &_get_category($vr::POST{'board_id'});
    &_redirect(
        "$vr::db{'current_category'}/$vr::POST{'board_id'}/$vr::POST{'thread_id'}/$vr::POST{'page'}"
    );
}

sub do_delete_vote {
    $vr::dbh->begin_work;
    eval {
        &_do_delete_vote($vr::POST{'thread_id'}, $vr::viewer{'user_id'});
        $vr::dbh->commit;
    };
    if ($@) { die "Died in show_messages: $@"; }

    &_get_category($vr::POST{'board_id'});
    &_redirect(
        "$vr::db{'current_category'}/$vr::POST{'board_id'}/$vr::POST{'thread_id'}/$vr::POST{'page'}"
    );
}

sub do_delete_poll {
    if ($vr::viewer{'guest'}) { die("you don't have permission to delete this poll"); }

    $vr::dbh->begin_work;
    eval {
        &_poll_info($vr::POST{'thread_id'});

        if ($vr::viewer{'user_id'} ne $vr::db{'poll_starter_id'}) {
            unless ($vr::viewer{'can_mod'} || $vr::viewer{'can_admin'}) {
                die("you don't have permission to delete this poll");
            }
        }

        &_do_delete_poll($vr::POST{'thread_id'});
        &_do_delete_poll_votes($vr::POST{'thread_id'});
        &_do_delete_poll_options($vr::POST{'thread_id'});
        $vr::dbh->commit;
    };
    if ($@) { die "Died in show_messages: $@"; }

    &_get_category($vr::POST{'board_id'});
    &_redirect(
        "$vr::db{'current_category'}/$vr::POST{'board_id'}/$vr::POST{'thread_id'}/$vr::POST{'page'}"
    );
}

sub do_new_poll {
    my @poll_options = ();
    my $message_id   = undef;

    while ((my $key, my $value) = each(%vr::POST)) {
        if ($key =~ /poll_option_(\d+)/) { push(@poll_options, "$1|$vr::POST{$key}"); }
    }

    @poll_options = sort { $a <=> $b } @poll_options;

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
        &_do_add_poll($vr::config{'gmtime'}, $vr::POST{'subject'});
        foreach my $item (@poll_options) {
            my (undef, $option_text) = split(/\|/, $item);
            &_do_add_poll_options($vr::config{'gmtime'}, $option_text);
        }
        $vr::dbh->commit;
    };
    if ($@) { die "Died: $@"; }

    &_finish_attachments($vr::POST{'attach_file'}, $vr::POST{'attach_ext'}, $message_id);

    my $last_page = int(($vr::db{'thread_messages'} / $vr::config{'messages_per_page'}) + 0.9999)
        ;    # Emulate ceil...

    &_redirect("$vr::POST{'category_id'}/$vr::POST{'board_id'}/$vr::config{'gmtime'}/");
}

sub do_add_poll {
    my @poll_options = ();
    while ((my $key, my $value) = each(%vr::POST)) {
        if ($key =~ /poll_option_(\d+)/) { push(@poll_options, "$1|$vr::POST{$key}"); }
    }

    @poll_options = sort { $a <=> $b } @poll_options;

    $vr::dbh->begin_work;
    eval {
        &_do_add_poll($vr::POST{'thread_id'}, $vr::POST{'subject'});
        foreach my $item (@poll_options) {
            my (undef, $option_text) = split(/\|/, $item);
            &_do_add_poll_options($vr::POST{'thread_id'}, $option_text);
        }
        $vr::dbh->commit;
    };
    if ($@) { die "Died in show_messages: $@"; }

    my $last_page = int(($vr::db{'thread_messages'} / $vr::config{'messages_per_page'}) + 0.9999)
        ;    # Emulate ceil...
    &_get_category($vr::POST{'board_id'});

    if ($last_page == 1) {
        &_redirect("$vr::db{'current_category'}/$vr::POST{'board_id'}/$vr::POST{'thread_id'}/");
    } else {
        &_redirect(
            "$vr::db{'current_category'}/$vr::POST{'board_id'}/$vr::POST{'thread_id'}/$last_page"
        );
    }
}

1;
