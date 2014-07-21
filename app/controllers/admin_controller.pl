###############################################################################
# controllers/admin.pl
# =============================================================================
# Version:    Vegetable Revolution 3.0
# Released:   1st June 2009
# Revision:   $Rev$
# Copyright:  James Aitken <http://loonypandora.co.uk>
###############################################################################

use strict;

unless ($vr::viewer{'can_admin'} || $vr::viewer{'can_mod'}) { &_redirect(''); }
if ($vr::viewer{'is_guest'}) { &_redirect(''); }

sub show_admin {
    $vr::dbh->begin_work;
    eval {
        &_board_list('mods', '1', '0', '1');
        &_category_info('mods');
    };

    if ($@) { die "Died because: $@"; }

    $vr::tmpl{'page_title'} = "$vr::db{'category_title'}";
    &_format_template;
}

sub edit_word_filter {
    open(CENSOR, "$vr::config{'base_path'}/config/censor.config") || die "$!";
    my @lines = <CENSOR>;
    close CENSOR;

    my $jlines = join('', @lines);

    $tmpl::form_action      = 'save_word_filter';
    $vr::tmpl{'page_title'} = "Edit Word Filter";
    $vr::tmpl{'body'}       = $jlines;
    &_format_template;
}

sub save_word_filter {
    $vr::POST{'message'} =~ s/\[br\]/\n/isg;

    open(CENSOR, ">$vr::config{'base_path'}/config/censor.config") || die "$!";
    print CENSOR $vr::POST{'message'};
    close CENSOR;

    &_redirect('admin/word_filter/');
}

sub edit_bans {
    open(IPBAN, "$vr::config{'base_path'}/config/ban_ip.config") || die "$!";
    my @ip_lines = <IPBAN>;
    close IPBAN;

    open(USERBAN, "$vr::config{'base_path'}/config/ban_user.config") || die "$!";
    my @user_lines = <USERBAN>;
    close USERBAN;

    open(EMAILBAN, "$vr::config{'base_path'}/config/ban_email.config") || die "$!";
    my @email_lines = <EMAILBAN>;
    close EMAILBAN;

    my $jip_lines    = join('', @ip_lines);
    my $juser_lines  = join('', @user_lines);
    my $jemail_lines = join('', @email_lines);

    $tmpl::form_action        = 'save_bans';
    $vr::tmpl{'page_title'}   = "Edit Banned Users";
    $vr::tmpl{'jip_lines'}    = $jip_lines;
    $vr::tmpl{'juser_lines'}  = $juser_lines;
    $vr::tmpl{'jemail_lines'} = $jemail_lines;
    &_format_template('');
}

sub save_bans {
    $vr::POST{'message_one'} =~ s/\[br\]/\n/isg;
    $vr::POST{'message_two'} =~ s/\[br\]/\n/isg;
    $vr::POST{'message_three'} =~ s/\[br\]/\n/isg;

    open(IPBAN, ">$vr::config{'base_path'}/config/ban_ip.config") || die "$!";
    print IPBAN $vr::POST{'message_one'};
    close IPBAN;

    open(USERBAN, ">$vr::config{'base_path'}/config/ban_user.config") || die "$!";
    print USERBAN $vr::POST{'message_two'};
    close USERBAN;

    open(EMAILBAN, ">$vr::config{'base_path'}/config/ban_email.config") || die "$!";
    print EMAILBAN $vr::POST{'message_three'};
    close EMAILBAN;

    &_redirect('admin/edit_bans/');
}

sub edit_groups {
    $vr::dbh->begin_work;
    eval {
        &_load_spec_groups;
        our $spec_groups = $vr::loop->fetchall_hashref('spec_group_id');
        &_load_post_groups;
        our $post_groups = $vr::loop->fetchall_hashref('post_group_id');
    };

    if ($@) { die "Died because: $@"; }

    $vr::tmpl{'page_title'} = "Admin Centre";
    $tmpl::form_action = 'save_groups';
    &_format_template;

}

sub save_groups {

    $vr::dbh->begin_work;
    eval {
        for (my $i = 1; $i < 8; $i++) {
            &_write_post_group($i, $vr::POST{"post_title_$i"},
                $vr::POST{"post_$i"}, $vr::POST{"post_image_$i"});
        }

        for (my $j = 1; $j < 5; $j++) {
            &_write_spec_group(
                $j,
                $vr::POST{"spec_title_$j"},
                $vr::POST{"spec_color_$j"},
                $vr::POST{"spec_image_$j"}
            );
        }
        $vr::dbh->commit;
    };

    if ($@) { die "Died because: $@"; }

    &_redirect('admin/edit_groups/');
}

sub edit_boards {
    $vr::dbh->begin_work;
    eval { &_all_board_list; };

    if ($@) { die "Died because: $@"; }

    $vr::tmpl{'page_title'} = "Admin Centre";
    $tmpl::form_action = 'save_boards';
    &_format_template;

}

sub save_boards {

    $vr::dbh->begin_work;
    eval {
        &_get_board_array;
        my $board = $vr::loop->fetchall_arrayref;

        foreach my $id (@{$board}) {
            my $i = @{$id}->[0];

            &_write_boards($i, $vr::POST{"title_$i"}, $vr::POST{"position_$i"},
                $vr::POST{"desc_$i"}, $vr::POST{"icon_$i"});
        }
        $vr::dbh->commit;
    };

    if ($@) { die "Died because: $@"; }

    &_redirect('admin/edit_boards/');
}

sub _get_board_array {

    my $query = qq{
SELECT board_id
FROM boards
    };

    $vr::loop = $vr::dbh->prepare($query);
    $vr::loop->execute();
    $vr::loop->bind_columns(\(@vr::loop{ @{ $vr::loop->{NAME_lc} } }));
}

1;

