###############################################################################
# controllers/shoutbox.pl
# =============================================================================
# Version:    Vegetable Revolution 3.0
# Released:   1st June 2009
# Revision:   $Rev$
# Copyright:  James Aitken <http://loonypandora.co.uk>
###############################################################################

use strict;

sub show_shoutbox {

    $vr::dbh->begin_work;
    eval {
        &_list_shoutbox_messages($vr::config{'shouts_to_show'});
        our $shouts = $vr::loop->fetchall_hashref('shout_id');
    };
    if ($@) { die "Died because: $@"; }

    $vr::tmpl{'page_title'} = "The Shoutbox";
    &_format_template;

}

sub show_archive_shouts {

    my $page_offset
        = ($vr::GET{'page'} * $vr::config{'shouts_per_page'} - $vr::config{'shouts_per_page'});

    $vr::dbh->begin_work;
    eval {
        &_list_shoutbox_archives($page_offset, $vr::config{'shouts_per_page'});
        &_shout_total;
    };
    if ($@) { die "Died because: $@"; }

    our $total_pages = int(($vr::db{'shout_count'} / $vr::config{'shouts_per_page'}) + 0.9999)
        ;    # Emulate ceil...

    $vr::tmpl{'page_title'} = "Shoutbox Archives";
    &_format_template;

}

sub do_new_shout {
    if ($vr::POST{'real_shout_message'} eq 'Enter Message...') {
        &_redirect('shoutbox/');
        return;
    }
    if ($vr::POST{'real_shout_message'} eq '') { &_redirect('shoutbox/'); return; }

    $vr::dbh->begin_work;
    eval {
        &_write_shout($vr::viewer{'user_id'}, $vr::POST{'real_shout_message'});
        &_update_site_stats('shout');
        &_update_last_online($vr::viewer{'user_id'}, $vr::viewer{'ip_address'});
        &_update_user_shout_count($vr::viewer{'user_id'}, $vr::viewer{'ip_address'});
        $vr::dbh->commit;
    };
    if ($@) { die "Died because: $@"; }

    &_redirect('shoutbox/');
}

1;
