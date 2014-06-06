###############################################################################
# models/admin.pl
# =============================================================================
# Version:    Vegetable Revolution 3.0
# Released:   1st June 2009
# Revision:   $Rev$
# Copyright:  James Aitken <http://www.loonypandora.com>
###############################################################################

use strict;

sub _write_post_group {
    my ($id, $title, $postcount, $image) = @_;

    my $query = qq{
UPDATE post_groups
SET post_group_title = ?, posts_required = ?
WHERE post_group_id = ?
    };

    $vr::dbh->prepare($query)->execute($title, $postcount, $id);
}

sub _write_spec_group {
    my ($id, $title, $color, $image) = @_;

    my $query = qq{
UPDATE special_groups
SET spec_group_title = ?, spec_group_color = ?
WHERE spec_group_id = ?
    };

    $vr::dbh->prepare($query)->execute($title, $color, $id);
}

sub _write_boards {
    my ($id, $title, $position, $description, $icon) = @_;

    my $query = qq{
UPDATE boards
SET board_title = ?, board_position = ?, board_description = ?, board_icon = ?
WHERE board_id = ?
    };

    $vr::dbh->prepare($query)->execute($title, $position, $description, $icon, $id);
}

sub _all_board_list {
    my ($category, $guest_view, $vip_view, $mods_view) = @_;

    my $query = qq{
SELECT boards.board_id, boards.category_id, boards.board_title, boards.board_description, boards.board_position, boards.board_icon
FROM boards
};

    $vr::loop = $vr::dbh->prepare($query);
    $vr::loop->execute;
    $vr::loop->bind_columns(\(@vr::loop{ @{ $vr::loop->{NAME_lc} } }));
}

1;

