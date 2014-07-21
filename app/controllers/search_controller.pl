###############################################################################
# search_controller.pl
# =============================================================================
# Version:    Vegetable Revolution 3.0
# Released:   1st June 2009
# Revision:   $Rev$
# Copyright:  James Aitken <http://loonypandora.co.uk>
###############################################################################

use strict;
use HTML::Entities;

sub redirect_to_search {
    if (!$vr::POST{'search_boards'}) { @{ $vr::POST{'search_boards'} } = 'main'; }
    my $board_string = join('+', @{ $vr::POST{'search_boards'} });

    &HTML::Entities::encode($vr::tmpl{'search_query'});
    &HTML::Entities::encode($board_string);
    &HTML::Entities::encode($vr::POST{'time_period'});

    &_redirect("search/$vr::POST{'time_period'}/$board_string/$vr::POST{'search_query'}");
}

sub show_search_results {
    if ($vr::viewer{'is_guest'}) { &_redirect(''); }

    my @boards_array = split("\\+", $vr::GET{'search_boards'});

    my @quoted_boards = ();
    foreach my $board (@boards_array) {
        my $tmp = $vr::dbh->quote($board);
        push(@quoted_boards, "$tmp");
    }

    my $quoted_board_string = join(',', @quoted_boards);

    my $page_offset
        = ($vr::GET{'page'} * $vr::config{'posts_per_page'} - $vr::config{'posts_per_page'});

    my ($begin_time, $end_time) = '';
    if ($vr::GET{'time_period'} eq 'last_week') {
        $begin_time = $vr::config{'gmtime'};
        $end_time   = $vr::config{'gmtime'} - 604800;
    } elsif ($vr::GET{'time_period'} eq 'last_quarter') {
        $begin_time = $vr::config{'gmtime'};
        $end_time   = $vr::config{'gmtime'} - 7948800;
    } elsif ($vr::GET{'time_period'} eq 'last_year') {
        $begin_time = $vr::config{'gmtime'} - 7948800;
        $end_time   = $vr::config{'gmtime'} - 31622400;
    } elsif ($vr::GET{'time_period'} eq 'one_two_years') {
        $begin_time = $vr::config{'gmtime'} - 31622400;
        $end_time   = $vr::config{'gmtime'} - 63244800;
    } elsif ($vr::GET{'time_period'} eq 'older') {
        $begin_time = $vr::config{'gmtime'} - 63244800;
        $end_time   = $vr::config{'gmtime'} - 126489600;
    }

    $vr::dbh->begin_work;
    eval {
        &_show_search_results(
            $vr::GET{'search_query'},
            $vr::config{'posts_per_page'},
            $begin_time, $end_time, $quoted_board_string, $page_offset
        );
        &_show_search_info($vr::GET{'search_query'}, $begin_time, $end_time, $quoted_board_string)
    };
    if ($@) { die "Died because: $@"; }

    our $total_pages = int(($vr::db{'total_results'} / $vr::config{'posts_per_page'}) + 0.9999)
        ;    # Emulate ceil...

    $vr::tmpl{'search_query'} = $vr::GET{'search_query'};
    $vr::tmpl{'page_title'}   = "Search: $vr::tmpl{'search_query'}";

    &_format_template;
}

sub show_search_form {
    if ($vr::viewer{'is_guest'}) { &_redirect(''); }

    $vr::dbh->begin_work;
    eval { &_board_list('forum', '0', '0', '0'); };
    if ($@) { die "Died because: $@"; }

    $vr::tmpl{'page_title'} = "New Search";
    $tmpl::form_action = "redirect_to_search";

    &_format_template;
}

1;
