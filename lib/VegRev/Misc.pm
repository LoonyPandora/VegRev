package VegRev::Misc;

use v5.14;
use feature 'unicode_strings';
use utf8;
use common::sense;

use Dancer qw(:moose);
use Dancer::Plugin::Database;

use Data::Dump qw/dump/;

use HTML::Entities qw(encode_entities);
use HTML::FormatText;
use HTML::StripScripts::Parser;
use HTML::TreeBuilder;



# Misc functions that aren't appropriate in the view



# Gets a list of user id's who have an active session
# Where active is timestamp within 30 minutes
sub currently_online {
    my $sth = database->prepare(q{
        SELECT session_data
        FROM session
        WHERE timestamp BETWEEN DATE_SUB(NOW(), INTERVAL 30 MINUTE) AND NOW()
        LIMIT 999
    });
    $sth->execute();

    my $online = $sth->fetchall_arrayref({});

    # We don't return the whole session in case we reveal something sensitive
    my %online;
    for my $session_json (@$online) {
        my $session = Dancer::Serializer::JSON::from_json($session_json->{session_data});

        if ($session->{user_id}) {
            $online{$session->{user_id}} = {
                user_id      => $session->{user_id},
                user_name    => $session->{user_name},
                display_name => $session->{display_name},
                avatar       => $session->{avatar},
            };
        }
    }

    # If logged in from multiple devices, will have multiple sessions.
    my @unduped = values %online;

    return \@unduped;
}

sub list_tags {
    my $sth = database->prepare(q{
        SELECT id, title, url_slug, description
        FROM tag
        WHERE group_id IN (2,3)
    });
    $sth->execute();

    my $all_tags = $sth->fetchall_arrayref({});

    return $all_tags;
}


# TODO: Can this add classes instead of inline style tags?
sub cleanup_wysiwyg {
    my $unclean_html = shift;

    my $tidy = HTML::Tidy->new({
        char_encoding               => 'utf8',
        input_encoding              => 'utf8',
        output_encoding             => 'utf8',
        newline                     => 'LF',
        sort_attributes             => 'alpha',
        doctype                     => 'omit',
        tidy_mark                   => 0,
        clean                       => 0,
        output_html                 => 1,
        bare                        => 1,
        fix_backslash               => 1,
        fix_uri                     => 1,
        indent                      => 1,
        break_before_br             => 1,
        merge_divs                  => 1,
        merge_spans                 => 1,
        drop_empty_paras            => 1,
        drop_proprietary_attributes => 1,
        logical_emphasis            => 1,
        quote_ampersand             => 1,
        quote_nbsp                  => 1,
        show_body_only              => 1,
        word_2000                   => 1,
    });

    $tidy->ignore( type => 1, type => 2 );

    my $clean_html = $tidy->clean($unclean_html);

    # Until HTML::StripScripts supports classes, return the tidied stuff 
    return $clean_html;

    # Now check for XSS and dodgy tags
    my $hss = HTML::StripScripts::Parser->new({
        Context        => 'Flow',
        # BanList        => [qw( div img hr ul ol dl li dt dd )],
        BanAllBut      => [qw( a b i em strong p span blockquote )],
        AllowSrc       => 1,
        AllowHref      => 1,
        AllowRelURL    => 1,
        EscapeFiltered => 1,
    });

    return $hss->filter_html($clean_html);
}

sub make_plaintext {
    my $html = shift;

    my $tree = HTML::TreeBuilder->new_from_content($html);
    
    my $formatter = HTML::FormatText->new();
    
    my $plaintext = $formatter->format($tree);    
    $plaintext =~ s/\s+/ /g;
    $plaintext =~ s/^\s+|\s+$//g;

    return encode_entities($plaintext);
}

1;
