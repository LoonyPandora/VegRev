###############################################################################
# helpers/application.pl
# =============================================================================
# Version:    Vegetable Revolution 3.0
# Released:   1st June 2009
# Revision:   $Rev$
# Copyright:  James Aitken <http://www.loonypandora.com>
###############################################################################

use strict;
use Parse::BBCode;
use HTML::Truncate;
use File::Copy;
use HTML::Entities;
use File::Temp qw(tempfile);
 

sub _format_template {
    our $tmpl = Text::ScriptTemplate->new();

    my $subroutine = '';

    # Get the calling subroutine so we know the right template. 0 is the current, 1 will be AUTOLOAD, 2 is the one we want
    # Use 3 if we are calling template from within an eval. (which we should be doing...)
    # Unless of course, we've been passed a template to use!

    if (!$_[0]) {
        my $caller = undef;
        my (undef, undef, undef, $call_two, undef) = caller(2);
        my (undef, undef, undef, $call_one, undef) = caller(1);

        if   ($call_two =~ /AUTOLOAD/) { $caller = $call_one; }
        else                           { $caller = $call_two; }

        (undef, $subroutine) = split(/::/, $caller);
    } else {
        $subroutine = $_[0];
    }

    my ($tmpl_end, $tmpl_path);
    if   ($subroutine =~ /^prepare/) { $tmpl_end = "/facebox"; }
    else                             { $tmpl_end = ""; }

    if ($vr::db{'avatar'} =~ /^\d{1,8}\.\w{1,4}$/) {
        my ($digits, $ext) = split(/\./, $vr::db{'avatar'});
        $ext = lc($ext);
        if ($ext eq 'jpeg') { $ext = 'jpg'; }
        if (-f "$vr::config{'base_path'}/uploads/$digits.thumb.$ext") {
            $vr::db{'avatar'} = "$vr::config{'base_url'}/uploads/$digits.thumb.$ext";
        } else {
            $vr::db{'avatar'} = "$vr::config{'base_url'}/uploads/$vr::db{'avatar'}";
        }
    }

    $tmpl_path = "$vr::config{'templatedir'}$tmpl_end";

    my $out = $tmpl->new->load("$tmpl_path/$subroutine.tmpl")->fill();

    print "Content-Type: text/html; charset=utf-8\n\n";
    print $out;
}

sub _redirect {
    print "Status: 302 Found\n";

    print "Location: $vr::config{'base_url'}/$_[0]\n\n";
}

sub _format_yabbc {
    my $p = Parse::BBCode->new({
        tags => {
            ''   => '',
            'br' => {
                output => '<br />',
                single => 1,
            },
            'b' => '<b>%s</b>',
            'i' => '<i>%s</i>',
            'u' => '<u>%s</u>',
            's' => '<span style="text-decoration: line-through;">%s</span>',

            'spoiler' => '<span style="background-color: #ffff00; color: #ffff00;">%s</span>',
            'font'    => '<span style="font-family: %{html}A;">%s</span>',
            'img'     => '<img src="%{html}A" alt="[%{html}s]" title="%{html}s" />',

            'smiley' =>
                qq~<img src="$vr::viewer{'template_url'}/img/emoticons_extra/%{html}A" alt="[%{html}s]" title="%{html}s" />~,

            'url'  => 'url:<a href="%{link}A" rel="nofollow" target="_blank">%s</a>',
            'size' => '<span style="font-size: %{num}apx; line-height: 1.25em;">%s</span>',

            'color'  => '<span style="color: %{htmlcolor}a">%s</span>',
            'colour' => '<span style="color: %{htmlcolor}a">%s</span>',

            'left'   => '<span style="text-align: left; display: block;">%s</span>',
            'center' => '<span style="text-align: center; display: block;">%s</span>',
            'centre' => '<span style="text-align: center; display: block;">%s</span>',
            'right'  => '<span style="text-align: right; display: block;">%s</span>',

            'sup'  => '<sup>%s</sup>',
            'sub'  => '<sub>%s</sub>',
            'move' => '<marquee>%s</marquee>',

            'edit' => 'block:<div class="edited_message">%s</div>',

            quote => {
                code => sub {
                    my ($parser, $attr, $content, $attribute_fallback) = @_;

                    my ($user_name, $display_name, $thread_id, $message_id, $time) = split(/\|/, $attr);

                    if ($user_name && $display_name && $thread_id && $message_id && $time) {
                        $time = &vr::_format_time($time);
                        qq{<cite>Quote: <a href="$vr::config{'base_url'}/forum/board/$thread_id/post/$message_id">$display_name, $time</a></cite><blockquote>$$content</blockquote>};
                    } elsif ($user_name && $display_name && $thread_id && $message_id && !$time) {
                        $time = &vr::_format_time($message_id)
                            ;    # Older style quotes, the message_id is the same as the time
                        qq{<cite>Quote: <a href="$vr::config{'base_url'}/forum/board/$thread_id">$display_name, $time</a></cite><blockquote>$$content</blockquote>};
                    } elsif ($user_name) {
                        qq{<cite>Quote: $user_name</cite><blockquote>$$content</blockquote>};
                    } else {
                        qq{<cite>Quote:</cite><blockquote>$$content</blockquote>};
                    }
                },
                parse => 1,
                class => 'block',
            },

            flash => {
                code => sub {
                    my ($parser, $attr, $content, $attribute_fallback) = @_;
                    if ($attribute_fallback =~ m/youtube\.com/i) {
                        $attribute_fallback =~ s~watch\?v\=~v\/~g;
                        qq{<object width="100%" height="350">
                    <param name="movie" value="$attribute_fallback&hl=en&fs=1&rel=0"></param>
                    <param name="allowFullScreen" value="true"></param>
                    <param name="allowscriptaccess" value="always"></param>
                    <embed src="$attribute_fallback&hl=en&fs=1&rel=0" type="application/x-shockwave-flash" wmode="transparent" allowscriptaccess="always" allowfullscreen="true" width="100%" height="350"></embed></object>
                    }
                    } elsif ($attribute_fallback =~ m/\.mp3$/) {
                        qq{<embed src="$vr::viewer{'template_url'}/swf/mp3player.swf" width="320" height="20" flashvars="file=$attribute_fallback&amp;height=20&amp;width=320&amp;autostart=false"></embed>};
                    } elsif ($attribute_fallback =~ m/vimeo\.com/i) {
                        $attribute_fallback =~ s/\D+//ig;
                        qq{<object width="100%" height="330">
                    <param name="allowfullscreen" value="true" />
                    <param name="allowscriptaccess" value="always" />
                    <param name="movie" value="http://vimeo.com/moogaloop.swf?clip_id=$attribute_fallback&amp;server=vimeo.com&amp;show_title=1&amp;show_byline=1&amp;show_portrait=0&amp;color=&amp;fullscreen=1" />
                    <embed src="http://vimeo.com/moogaloop.swf?clip_id=$attribute_fallback&amp;server=vimeo.com&amp;show_title=1&amp;show_byline=1&amp;show_portrait=0&amp;color=&amp;fullscreen=1" type="application/x-shockwave-flash" allowfullscreen="true" allowscriptaccess="always" width="100%" height="330"></embed></object>};
                    } elsif ($attribute_fallback =~ m/collegehumor\.com/i) {
                        $attribute_fallback =~ s/\D+//ig;
                        qq|<object width="100%" height="330">
                    <param name="allowfullscreen" value="true" />
                    <param name="allowscriptaccess" value="always" />
                    <param name="movie" value="http://www.collegehumor.com/moogaloop/moogaloop.swf?clip_id=$attribute_fallback&amp;fullscreen=1" />
                    <embed src="http://www.collegehumor.com/moogaloop/moogaloop.swf?clip_id=$attribute_fallback&amp;fullscreen=1" type="application/x-shockwave-flash" allowfullscreen="true" allowscriptaccess="always" width="100%" height="330"></embed></object>|;
                    } elsif ($attribute_fallback =~ m/\.swf$/i
                        && $attribute_fallback =~ m/^http:\/\/www.vegetablerevolution/i)
                    {
                        qq|<object type="application/x-shockwave-flash" style="width:554px; height:572px;" data="$attribute_fallback">
                   <param name="movie" value="$attribute_fallback">
                 </object>|;
                    }
                },
                parse => 0,
                class => 'block',
            },

            code => {
                code => sub {
                    my ($parser, $attr, $content, $attribute_fallback) = @_;
                    $content = Parse::BBCode::escape_html($$content);
                    "<tt>$content</tt>"
                },
                parse => 0,
                class => 'block',
            },
        }
    });

    # TODO: This fixes old posts being stored HTML encoded, sortof - emoticons don't work properly
    # Need to do a search and replace on all HTML encoded entities in the database.
    &HTML::Entities::decode($_[0]);

    # Normal encoding - needed as we store raw HTML
    &HTML::Entities::encode($_[0], '<>"');

    # This is so the parser picks up quoted attributes
    $_[0] =~ s/&quot;/"/g;

    # Convert old style quotes
    $_[0] =~ s/\[quote=(.{1,32}) link=/&_clean_username($1)/eisg;

    # Convert old style flash embeds
    $_[0] =~ s/\[flash=\d{1,4},\d{1,4}\]/\[flash\]/isg;

    # Autolink twitter names
    $_[0] =~ s{(\W)?@(\w+)}{$1<a href="http://twitter.com/$2">\@$2</a>}isg;

    # Only censor for guests
    if ($vr::viewer{'is_guest'}) {
        $_[0] = &_do_censor($_[0]);
    }

    $_[0]
        =~ s~([^\w\"\=\[\]]|[\n\b]|\[br\]|\[/[b|i|u|s]\]|\[/spoiler\]|\[/img\]|\[/flash\]|\[/url\]|\[/color\]|\[/size\]|\[/font\]|\[/?quote\]|\[/code\]|\[/left\]|\[/right\]|\[/center\]|\[/sup\]|\[/sub\]|\[/move\]|\[/edit\]|\&quot\;|\[quote=".*?"\]|\A)\\*(\w+?\:\/\/(?:[\w\~\;\:\,\$\-\+\!\*\?/\=\&\@\#\%\(\)(?:\<\S+?\>\S+?\<\/\S+?\>)]+?)\.(?:[\w\~\.\;\:\,\$\-\+\!\*\?/\=\&\@\#\%\(\)\x80-\xFF]{1,})+?)~&_autolink_url($1,$2)~eisg;
    $_[0]
        =~ s~([^\"\=\[\]/\:\.(\://\w+)]|[\n\b]|\[br\]|\[/[b|i|u|s]\]|\[/spoiler\]|\[/img\]|\[/flash\]|\[/url\]|\[/color\]|\[/size\]|\[/font\]|\[/?quote\]|\[/code\]|\[/left\]|\[/right\]|\[/center\]|\[/sup\]|\[/sub\]|\[/move\]|\[/edit\]|\&quot\;|\[quote=".*?"\]|\[edit\]|\A|\()\\*(www\.[^\.](?:[\w\~\;\:\,\$\-\+\!\*\?/\=\&\@\#\%\(\)(?:\<\S+?\>\S+?\<\/\S+?\>)]+?)\.(?:[\w\~\.\;\:\,\$\-\+\!\*\?/\=\&\@\#\%\(\)\x80-\xFF]{1,})+?)~&_autolink_url($1,$2)~eisg;

    $_[0] = &_format_emoticons($p->render($_[0]));

    return $_[0];
}

sub _clean_username {
    my ($name) = @_;
    $name =~ s/\s+/_/isg;
    $name =~ s/\W+//isg;

    return "[quote=$name link=";
}

sub _do_censor {
    open(CENSOR, "$vr::config{'base_path'}/config/censor.config")
        || die "Unable to read censored words: $!";
    my @censored = <CENSOR>;
    close CENSOR;

    foreach my $line (@censored) {
        chomp $line;
        my ($t_word, $t_replace) = split(/=/, $line);
        my ($p_word, $p_replace) = split(/~/, $line);

        if ($t_word && $t_replace) {
            $_[0] =~ s/\b($t_word)\b/_preserve_case($1, $t_replace)/egi;
        } else {
            $_[0] =~ s/($p_word)/_preserve_case($1, $p_replace)/egi;
        }

    }
    return $_[0];
}

sub _preserve_case {
    my ($from, $to) = @_;
    my ($lf, $lt) = map length, @_;

    if ($lt < $lf) { $from = substr $from, 0, $lt }
    else           { $from .= substr $to, $lf }

    return uc $to | ($from ^ uc $from);
}

sub _autolink_url {
    my ($txtfirst, $txturl) = @_;

    my $lasttxt = "";
    if ($txturl
        =~ m~(.*?)(\.|\.\)|\)\.|\!|\!\)|\)\!|\,|\)\,|\)|\;|\&quot\;|\&quot\;\.|\.\&quot\;|\&quot\;\,|\,\&quot\;|\&quot\;\;|\<\/)\Z~
        )
    {
        $txturl  = $1;
        $lasttxt = $2;
    }
    my $realurl = $txturl;
    $txturl
        =~ s~(\[shighlight\]|\[\/shighlight\]|\[highlight\]|\[\/highlight\]|\[edit\]|\[\/edit\])~~ig;
    $txturl =~ s~\[~&#91;~g;
    $txturl =~ s~\]~&#93;~g;
    $txturl =~ s~\<.+?\>~~ig;

    if ($txturl !~ /^http:\/\//) { $txturl = "http://$txturl"; }

    my $formaturl = qq~$txtfirst\[url\=$txturl\]$realurl\[\/url\]$lasttxt~;
    return $formaturl;
}

sub _format_emoticons {
    my $incoming = $_[0];

    # Complex is for smileys that have parts that are contained within other smileys.
    my %complex = (
        "/:)"    => 'smug.gif',
        "&gt;:(" => 'angry.gif',
        "::)"    => 'rolleyes.gif',
        "&gt;:D" => 'evil.gif',
    );

    my %simple = (
        ":)"  => 'smiley.gif',
        ";)"  => 'wink.gif',
        ":D"  => 'cheesy.gif',
        ";D"  => 'grin.gif',
        ":("  => 'sad.gif',
        ":o"  => 'shocked.gif',
        "8-)" => 'cool.gif',          # Nose is here to prevent numbered lists being munged
        ":?"  => 'huh.gif',
        ":P"  => 'tongue.gif',
        ":["  => 'embarassed.gif',
        ":X"  => 'lipsrsealed.gif',
        ":-/" =>
            'undecided.gif',    # if this has no nose, it messes with links - it's in http:// ...
        ":*"      => 'kiss.gif',
        ":&#39;(" => 'cry.gif',
        ":'("     => 'cry.gif',
        "^^d"     => 'thumbsup.gif',
    );

    foreach my $c_key (keys %complex) {
        $incoming
            =~ s~\Q$c_key\E~ <img src="$vr::viewer{'template_url'}/img/emoticons/$complex{$c_key}" style="vertical-align: bottom;" />~g;
    }

    foreach my $s_key (keys %simple) {
        $incoming
            =~ s~\Q$s_key\E~ <img src="$vr::viewer{'template_url'}/img/emoticons/$simple{$s_key}" style="vertical-align: bottom;" />~g;
    }

    return $incoming;
}

sub _get_next_previous_links {

    if (!$vr::GET{'board_id'}) { return ''; }

    eval {
        &_get_next();
        &_get_previous();
    };

    if (!$vr::db{'next_thread_id'}) {
        return
            qq~ / <a href="$vr::config{'base_url'}/$vr::db{'category_id'}/$vr::GET{'board_id'}/$vr::db{'prev_thread_id'}/new/">&laquo; $vr::db{'prev_thread_subject'}</a> / No Newer Posts &raquo;~;
    }

    if (!$vr::db{'prev_thread_id'}) {
        return
            qq~ / &laquo; No Older Posts / <a href="$vr::config{'base_url'}/$vr::db{'category_id'}/$vr::GET{'board_id'}/$vr::db{'next_thread_id'}/new/">$vr::db{'next_thread_subject'} &raquo;</a>~;
    }

    return
        qq~ / <a href="$vr::config{'base_url'}/$vr::db{'category_id'}/$vr::GET{'board_id'}/$vr::db{'prev_thread_id'}/new/">&laquo; $vr::db{'prev_thread_subject'}</a> / <a href="$vr::config{'base_url'}/$vr::db{'category_id'}/$vr::GET{'board_id'}/$vr::db{'next_thread_id'}/new/">$vr::db{'next_thread_subject'} &raquo;</a>~;

}

sub _get_next {
    my $query = qq{
SELECT threads.thread_id AS next_thread_id, threads.thread_subject AS next_thread_subject, boards.category_id
FROM threads
LEFT JOIN boards AS boards ON boards.board_id = threads.board_id
WHERE threads.thread_last_message_time > ?
AND threads.board_id = ?
AND threads.thread_deleted != '1'
ORDER BY threads.thread_last_message_time DESC
LIMIT 1
    };

    my $static = $vr::dbh->prepare($query);
    $static->execute($vr::db{'thread_last_message_time'}, $vr::GET{'board_id'});
    $static->bind_columns(\(@vr::db{ @{ $static->{NAME_lc} } }));
    $static->fetch;
}

sub _get_previous {
    my $query = qq{
SELECT threads.thread_id AS prev_thread_id, threads.thread_subject AS prev_thread_subject, boards.category_id
FROM threads
LEFT JOIN boards AS boards ON boards.board_id = threads.board_id
WHERE threads.thread_last_message_time < ?
AND threads.board_id = ?
AND threads.thread_deleted != '1'
ORDER BY threads.thread_last_message_time DESC
LIMIT 1
    };

    my $static = $vr::dbh->prepare($query);
    $static->execute($vr::db{'thread_last_message_time'}, $vr::GET{'board_id'});
    $static->bind_columns(\(@vr::db{ @{ $static->{NAME_lc} } }));
    $static->fetch;
}

sub _get_category {
    my ($board_id) = @_;

    my $query = qq{
SELECT boards.category_id AS current_category
FROM boards
WHERE boards.board_id = ?
LIMIT 1
    };

    my $static = $vr::dbh->prepare($query);
    $static->execute($board_id);
    $static->bind_columns(\(@vr::db{ @{ $static->{NAME_lc} } }));
    $static->fetch;
}

sub _format_time {
    my $timestamp     = $_[0];
    my $adjusted_time = $vr::config{'gmtime'};

    # We work in GMT throughout the site, only adjusting for BST on display.
    # Do it manually for the next 10 years. There is no better way... :(
    if (time > 1238292000 && time < 1256432400) {
        $timestamp     += 3600;
        $adjusted_time += 3600;
    }    # March 29 - Oct 25 - 2009
    elsif (time > 1269741600 && time < 1288490400) {
        $timestamp     += 3600;
        $adjusted_time += 3600;
    }    # March 28 - Oct 31 - 2010
    elsif (time > 1301191200 && time < 1319940000) {
        $timestamp     += 3600;
        $adjusted_time += 3600;
    }    # March 27 - Oct 30 - 2011
    elsif (time > 1332640800 && time < 1351389600) {
        $timestamp     += 3600;
        $adjusted_time += 3600;
    }    # March 25 - Oct 28 - 2012
    elsif (time > 1364695200 && time < 1382839200) {
        $timestamp     += 3600;
        $adjusted_time += 3600;
    }    # March 31 - Oct 27 - 2013
    elsif (time > 1396144800 && time < 1414288800) {
        $timestamp     += 3600;
        $adjusted_time += 3600;
    }    # March 30 - Oct 26 - 2014
    elsif (time > 1427594400 && time < 1445738400) {
        $timestamp     += 3600;
        $adjusted_time += 3600;
    }    # March 29 - Oct 25 - 2015
    elsif (time > 1459044000 && time < 1477792800) {
        $timestamp     += 3600;
        $adjusted_time += 3600;
    }    # March 27 - Oct 30 - 2016
    elsif (time > 1490493600 && time < 1509242400) {
        $timestamp     += 3600;
        $adjusted_time += 3600;
    }    # March 26 - Oct 29 - 2017
    elsif (time > 1521943200 && time < 1540692000) {
        $timestamp     += 3600;
        $adjusted_time += 3600;
    }    # March 25 - Oct 28 - 2018
    elsif (time > 1553997600 && time < 1572141600) {
        $timestamp     += 3600;
        $adjusted_time += 3600;
    }    # March 31 - Oct 27 - 2019

    my (undef, $min, $hour, $mday, $mon, $year, undef) = gmtime($timestamp);

    my $ampm = undef;

    if ($hour > 11) { $hour = $hour - 12; $ampm = "pm"; }
    else            { $ampm = "am"; }
    if ($hour == 0) { $hour = 12; }
    $min = sprintf("%.2d", $min);
    $year += 1900;

    my $ordinal = &_format_ordinal($mday);

    my $days_ago  = (int((($adjusted_time / 60) / 60) / 24) - int((($timestamp / 60) / 60) / 24));
    my $hours_ago = (int(($adjusted_time / 60) / 60) - int(($timestamp / 60) / 60));
    my $minutes_ago = (int($adjusted_time / 60) - int($timestamp / 60));
    my $weeks_ago   = (int($days_ago / 7));
    my $months_ago  = (int($days_ago / 30));

    if ($_[1] eq 'current_date') {
        return qq~$mday<sup>$ordinal</sup> $vr::long_month_names[$mon] $year, $hour:$min $ampm~;
    } elsif ($minutes_ago <= 1) {
        return qq~Just now~;
    } elsif ($minutes_ago < 60) {
        return qq~$minutes_ago minutes ago~;
    } elsif ($hours_ago == 1) {
        return qq~$hours_ago hour ago~;
    } elsif ($hours_ago < 13) {
        return qq~$hours_ago hours ago~;
    } elsif ($days_ago == 0) {
        return qq~Today at $hour:$min $ampm~;
    } elsif ($days_ago == 1) {
        return qq~Yesterday at $hour:$min $ampm~;
    } elsif ($_[1] eq 'full') {
        return qq~$mday<sup>$ordinal</sup> $vr::month_names[$mon] $year at $hour:$min $ampm~;
    } elsif ($_[1] eq 'semi') {
        return qq~$mday<sup>$ordinal</sup> $vr::month_names[$mon] $year~;
    } elsif ($days_ago > 1 && $days_ago <= 13) {
        return qq~$days_ago days ago~;
    } elsif ($days_ago > 13 && $days_ago <= 69) {
        return qq~$weeks_ago weeks ago~;
    } elsif ($days_ago > 69) {
        return qq~$vr::month_names[$mon] $year~;
    } else {
        return qq~$mday<sup>$ordinal</sup> $vr::month_names[$mon] $year at $hour:$min $ampm~;
    }
}

sub _format_ordinal {
    $_[0] =~ /^(?:\d+|\d[,\d]+\d+)$/ or return $_[0];
    return "nd" if $_[0] =~ /(?<!1)2$/;
    return "rd" if $_[0] =~ /(?<!1)3$/;
    return "st" if $_[0] =~ /(?<!1)1$/;
    return "th";
}

sub _format_numbers {
    my $number = $_[0];
    $number =~ s/(\d{1,3}?)(?=(\d{3})+$)/$1,/g;
    return $number;
}

sub _time_ago {
    my (undef, $min, $hour, $mday, $mon, $year, undef) = gmtime($_[0]);

    my $ampm = undef;

    if ($hour > 11) { $hour = $hour - 12; $ampm = "pm"; }
    else            { $ampm = "am"; }
    if ($hour == 0) { $hour = 12; }
    $min = sprintf("%.2d", $min);
    $year += 1900;

    my $ordinal = &_format_ordinal($mday);

    my $days_ago
        = (int((($vr::config{'gmtime'} / 60) / 60) / 24) - int((($_[0] / 60) / 60) / 24));
    my $weeks_ago  = (int($days_ago / 7));
    my $months_ago = (int($days_ago / 30));
    my $years_ago  = (int($days_ago / 365));

    if    ($days_ago == 0) { return qq~<span class="faded">less than a day</span>~; }
    elsif ($days_ago == 1) { return qq~1 <span class="faded">day</span>~; }
    elsif ($days_ago > 1 && $days_ago <= 13) {
        return qq~$days_ago <span class="faded">days</span>~;
    } elsif ($days_ago > 13 && $days_ago <= 69) {
        return qq~$weeks_ago <span class="faded">weeks</span>~;
    } elsif ($days_ago > 69 && $months_ago <= 23) {
        return qq~$months_ago <span class="faded">months</span>~;
    } elsif ($months_ago > 23) {
        return qq~$years_ago <span class="faded">years</span>~;
    } else {
        return qq~$mday<sup>$ordinal</sup> $vr::month_names[$mon] $year~;
    }
}

sub _rate_per_day {
    my $days_ago = (int(((time() / 60) / 60) / 24) - int((($_[0] / 60) / 60) / 24)) || 1;

    return sprintf("%.2f", ($_[1] / $days_ago));
}

sub _get_age {
    my ($year, $month, $mday) = split(/\-/, $_[0]);
    $month -= 1;

    my (undef, undef, undef, $cur_mday, $cur_mon, $cur_year, undef)
        = gmtime($vr::config{'gmtime'});
    $cur_year += 1900;

    if ($cur_mon - $month < 0) { $cur_year -= 1 }
    elsif ($cur_mon - $month == 0 && $cur_mday - $mday < 0) { $cur_year -= 1 }

    return int($cur_year - $year);
}

sub _format_dob {
    my ($year, $month, $mday) = split(/\-/, $_[0]);
    $month -= 1;
    $mday = int($mday);

    if ($year == 1900) {
        return "$mday" . &_format_ordinal($mday) . " $vr::long_month_names[$month]";
    } else {
        return "$mday" . &_format_ordinal($mday) . " $vr::month_names[$month] $year";
    }
}

sub _format_username {
    my $lower_username = undef;

    if (lc($vr::viewer{'user_name'}) eq lc($_[0])) {
        $lower_username = lc($_[0]);
    }

    if ($_[2]) {
        return
            qq~<a href="$vr::config{'base_url'}/user/$_[0]" class="usernamelink $lower_username" style="color: $_[2];"$_[3]>$_[1]</a>~;
    } else {
        return
            qq~<a href="$vr::config{'base_url'}/user/$_[0]" class="usernamelink $lower_username"$_[3]>$_[1]</a>~;
    }
}

sub _format_threadlink {
    return qq~<a href="$vr::config{'base_url'}/forum/$_[0]/$_[1]/">$_[2]</a>~;
}

sub _generate_pagination {
    my ($total_pages, $current_page) = @_;

    if (!$total_pages) { return; }

    if ($total_pages == 1) {
        return qq{<p class="column two alpha omega">One Page</p>};
    }

    my $selected = '';
    my $return   = '';

    my $nextpage = $current_page + 1;
    my $prevpage = $current_page - 1;

    my $cur_url = $vr::GET{'request_uri'};
    $cur_url =~ s~/\d{1,8}/?$~~;
    $cur_url =~ s~/$~~;

    if ($vr::viewer{'is_guest'}) {
        $return
            .= '<p class="column less_than_one alpha omega">Page:</p><ul class="pagination column four">';
    } elsif ($vr::GET{'action'} eq 'show_messages') {
        $return
            .= qq~<ul class="pagination column five_and_half"><li class="column" id="page_select_container"><select id="page_selector">~;
        $return .= qq~<option value="" selected="selected">Page</option>~;
        for (my $i = 1; $i < $total_pages; $i++) {
            $return .= qq~<option value="$cur_url/$i">$i</option>~;
        }
        $return .= qq~</select></li>~;

        $return .= qq~<li class="column"><a href="$cur_url/all">all</a></li>~;
    } else {
        $return
            .= qq~<ul class="pagination column five_and_half"><li class="column" id="page_select_container"><select id="page_selector">~;
        $return .= qq~<option value="" selected="selected">Page</option>~;
        for (my $i = 1; $i < $total_pages; $i++) {
            $return .= qq~<option value="$cur_url/$i">$i</option>~;
        }
        $return .= qq~</select></li>~;
    }

    if ($current_page <= 1) { $return .= qq~<li class="column prev"><a>&lt;</a></li>~; }
    else { $return .= qq~<li class="column prev"><a href="$cur_url/$prevpage/">&lt;</a></li>~; }

    if ($total_pages <= 6) {
        for (my $i = 1; $i <= $total_pages; $i++) {
            if   ($current_page == $i) { $selected = ' selected'; }
            else                       { $selected = ''; }
            $return .= qq~<li class="column$selected"><a href="$cur_url/$i/">$i</a></li>~;
        }

        if ($current_page <= 6 && $current_page < $total_pages) {
            $return .= qq~<li class="column next"><a href="$cur_url/$nextpage/">&gt;</a></li>~;
        } else {
            $return .= qq~<li class="column next"><a>&gt;</a></li>~;
        }

    } else {
        for (my $i = 1; $i <= $total_pages; $i++) {
            if   ($current_page == $i) { $selected = ' selected'; }
            else                       { $selected = ''; }
            if ($i == 1 && $prevpage != 1) {
                $return .= qq~<li class="column$selected"><a href="$cur_url/1/">1</a></li>~;
            }
            if ($i == 2 && ($prevpage != 2) && $current_page > 2) {
                $return .= qq~<li class="column spacer">...</li>~;
            }

            if ($i == $prevpage && $i == $total_pages - 1) {
                my $tmp  = $prevpage - 1;
                my $tmp2 = $prevpage - 2;
                $return .= qq~
        <li class="column$selected"><a href="$cur_url/$tmp2/">$tmp2</a></li>
        <li class="column$selected"><a href="$cur_url/$tmp/">$tmp</a></li>
        <li class="column$selected"><a href="$cur_url/$prevpage/">$prevpage</a></li>~;
            } elsif ($i == $prevpage) {
                $return
                    .= qq~<li class="column$selected"><a href="$cur_url/$prevpage/">$prevpage</a></li>~;
            }

            if ($i == $current_page && $current_page < $total_pages && $current_page != 1) {
                $return
                    .= qq~<li class="column$selected"><a href="$cur_url/$current_page/">$current_page</a></li>~;
            }

            if ($i == 1 && $current_page == 1) {
                my $tmp  = $nextpage + 1;
                my $tmp2 = $nextpage + 1;
                my $tmp3 = $nextpage + 2;
                $return .= qq~
        <li class="column"><a href="$cur_url/$nextpage/">$nextpage</a></li>
        <li class="column"><a href="$cur_url/$tmp2/">$tmp2</a></li>
        <li class="column"><a href="$cur_url/$tmp3/">$tmp3</a></li>
        ~;

            } elsif ($i == $nextpage && $nextpage < $total_pages && $i != 2) {
                $return
                    .= qq~<li class="column$selected"><a href="$cur_url/$nextpage/">$nextpage</a></li>~;
            }

            if ($i == ($nextpage + 1) && $nextpage < $total_pages) {
                $return .= qq~<li class="column spacer">...</li>~;
            }

            if ($i == $total_pages) {
                $return
                    .= qq~<li class="column$selected"><a href="$cur_url/$total_pages/">$total_pages</a></li>~;
            }
        }

        if ($current_page <= $total_pages && $current_page < $total_pages) {
            $return .= qq~<li class="column next"><a href="$cur_url/$nextpage/">&gt;</a></li>~;
        } else {
            $return .= qq~<li class="column next"><a>&gt;</a></li>~;
        }
    }

    return $return . '</ul>';
}

sub _show_footer_item {
    my ($type, $query, $icon, $text, $last, $top) = @_;

    my $rounded = undef;
    if    ($last) { $rounded = qq~ class="top_right_round"~; }
    elsif ($top)  { $rounded = qq~ class="top_round"~; }
    else          { $rounded = undef; }

    my $return = qq~
                <li class="column_right">
                    <a href="$vr::config{'base_url'}/postform/$type/?$query" rel="facebox"$rounded>
    ~;

    if ($icon) {
        $return .= qq~
                    <img src="$vr::viewer{'template_url'}/img/icons_silk/$icon.png" />
        ~;
    }
    $return .= qq~
                        $text
                    </a>
                </li>
    ~;

    return $return;
}

sub _check_new_thread {
    if ($vr::viewer{'is_guest'}) { return; }

    my ($category, $board, $thread_id, $thread_time) = @_;

    # Things can only be new if they have been updated in the past month
    if ($thread_time > ($vr::config{'gmtime'} - 2419200)) {
        my $query = qq{
            SELECT thread_read_receipts.read_time AS has_read
            FROM thread_read_receipts
            WHERE thread_read_receipts.thread_id = ?
            AND thread_read_receipts.user_id = ?
            AND thread_read_receipts.read_time > FROM_UNIXTIME(?)
        };

        my $static = $vr::dbh->prepare($query);
        $static->execute($thread_id, $vr::viewer{'user_id'}, $thread_time);
        $static->bind_columns(\(@vr::db{ @{ $static->{NAME_lc} } }));
        $static->fetch;

        if (!$vr::db{'has_read'}) {
            return qq~<a href="$vr::config{'base_url'}/$category/$board/$thread_id/new/" class="new_link">new</a>~;
        }

        delete $vr::db{'has_read'};
    }

    return;
}

sub _check_new_boards {
    if ($vr::viewer{'is_guest'}) { return "old"; }

    my ($board, $board_last_post) = @_;

    # Things can only be new if they have been updated in the past month
    if ($board_last_post > ($vr::config{'gmtime'} - 2419200)) {
        my $query = qq{
            SELECT board_read_receipts.read_time AS has_read
            FROM board_read_receipts
            WHERE board_read_receipts.board_id = ?
            AND board_read_receipts.user_id = ?
            AND board_read_receipts.read_time > FROM_UNIXTIME(?)
        };

        my $static = $vr::dbh->prepare($query);
        $static->execute($board, $vr::viewer{'user_id'}, $board_last_post);
        $static->bind_columns(\(@vr::db{ @{ $static->{NAME_lc} } }));
        $static->fetch;

        if (!$vr::db{'has_read'}) {
            return "new";
        }

        delete $vr::db{'has_read'};
    }

    return "old";
}


sub _start_attachments {
    my ($fh, $tmp_filename) = tempfile();

    print $fh $vr::POST{'Filedata'};
    $fh->close;

    my $new_filename = $vr::POST{'Filename'} =~ s{[^A-Za-z0-9\-\_\.]}{}r; 

    if (-f $tmp_filename) {
        move(
            $tmp_filename,
            "$vr::config{'tmp_uploaddir'}/$new_filename"
        ) or die "Upload failed: $!";
    } else {
        # Uploadify error
        print "403 Forbidden\n";
    }

    print "OK";
}



sub _finish_attachments {
    my ($attach_name, $attach_ext, $message_id) = @_;

    my $new_attach_ext = undef;
    if   ($attach_ext eq 'jpeg') { $new_attach_ext = 'jpg'; }
    else                         { $new_attach_ext = lc($attach_ext); }

    # GD::Thumbnail is crap for anything but jpegs
    # but we need it to get correct image dimensions...
    # Try to get rid of it if possible...
    use GD::Thumbnail;
    use Image::Thumbnail;

    if (-f "$vr::config{'tmp_uploaddir'}/$attach_name" && $attach_ext =~ /gif|png|jpg|jpeg/i) {
        my $gd = GD::Thumbnail->new;
        my $gd_img = $gd->create("$vr::config{'tmp_uploaddir'}/$attach_name", '100%', 0)
            || die("$! - $attach_name");
        undef $gd_img;

        my ($need_thumb, $need_sized) = undef;
        if ($gd->width > 100 || $gd->height > 100) { $need_thumb = 1; }
        if ($gd->width > 580 || $gd->height > 800) { $need_sized = 1; }

        if ($need_sized) {
            my $sized = new Image::Thumbnail(
                size       => 580,
                create     => 1,
                input      => "$vr::config{'tmp_uploaddir'}/$attach_name",
                outputpath => "$vr::config{'uploaddir'}/$message_id.sized.$new_attach_ext",
            );
        }

        if ($need_thumb) {
            my $thumb = new Image::Thumbnail(
                size       => 100,
                create     => 1,
                input      => "$vr::config{'tmp_uploaddir'}/$attach_name",
                outputpath => "$vr::config{'uploaddir'}/$message_id.thumb.$new_attach_ext",
            );
        }
        move(
            "$vr::config{'tmp_uploaddir'}/$attach_name",
            "$vr::config{'uploaddir'}/$message_id.$new_attach_ext"
        ) or die "Upload failed: $!";
    } elsif (-f "$vr::config{'tmp_uploaddir'}/$attach_name") {
        move(
            "$vr::config{'tmp_uploaddir'}/$attach_name",
            "$vr::config{'uploaddir'}/$message_id.$new_attach_ext"
        ) or die "Upload failed: $!";
    }
}

sub _truncate {
    my ($length, $string, $ellipsis) = @_;

    my $ht = HTML::Truncate->new(chars => $length, ellipsis => $ellipsis);

    return $ht->truncate($string)
}

sub _old_insecure_md5_password {
    my $encpass = md5_hex("$vr::config{'salt'}|$_[0]");
    return $encpass;
}

sub _encode_password {
    my ($plaintext) = @_;

    my $encpass = bcrypt->crypt(
        text   => $plaintext,
        cost   => 8,
        strong => 0,
    );

    return $encpass;
}

sub _check_email {
    if ($_[0] =~ m/\@/) {
        return $_[0];
    } else {
        return;
    }
}

sub _sendmail {
    my ($to, $subject, $body) = @_;

    &HTML::Entities::encode($to);
    &HTML::Entities::encode($subject);
    &HTML::Entities::encode($body);

    # TODO: Make this not suck;
    if (&_check_email($to)) {
        $ENV{'PATH'} =~ /(.*)/;
        $ENV{'PATH'} = $1;
        unless (open(MAIL, "|/usr/sbin/sendmail -t")) {
            print "error.\n";
            die "Error starting sendmail: $!";
        } else {
            print MAIL "From: [VR] Notification <noreply\@vegetablerevolution.com>\n";
            print MAIL "Reply-to: $to\n";
            print MAIL "To: $to\n";
            print MAIL "Subject: $subject\n\n";
            print MAIL "$body";
            close(MAIL) || warn "Error closing mail: $!";
        }
    }
}

sub _message_of_the_day {
    my $query = qq{
SELECT message_body, message_id 
FROM messages
WHERE thread_id = '1232530250'
AND message_body LIKE '%quote%'
ORDER BY RAND()
LIMIT 1
    };

    my $motd = $vr::dbh->prepare($query);
    $motd->execute();
    $motd->bind_columns(\(my $tmp), \($vr::viewer{'motd_id'}));
    $motd->fetch;
    $motd->finish;
    undef $motd;

    $tmp =~ m/\[quote.*?\](.*?)\[\/quote\]/isg;

    $vr::viewer{'motd'} = $1;
    $vr::viewer{'motd'} =~ s/\[br\]//isg;
    $vr::viewer{'motd'} = &_format_yabbc($vr::viewer{'motd'});
    return
        qq~<a href="$vr::config{'base_url'}/forum/main/1232530250/post/$vr::viewer{'motd_id'}">$vr::viewer{'motd'}</a>~;
}

sub calculate_page {

    $vr::dbh->begin_work;
    eval { &_calculate_pages($vr::GET{'id'}, $vr::GET{'post_id'}); };
    if ($@) { die "Died because: $@"; }

    my $page = int(($vr::db{'previous_posts'} / $vr::config{'posts_per_page'}) + 0.9999);

    &_redirect(
        "$vr::GET{'base_url'}forum/$vr::GET{'board_id'}/$vr::GET{'id'}/$page#$vr::GET{'post_id'}"
    );
}

sub _calculate_pages {
    my ($thread_id, $post_id) = @_;

    my $query = qq{
SELECT COUNT(1) AS previous_posts
FROM messages
WHERE messages.thread_id = ?
AND messages.message_id < ?
AND messages.message_deleted != '1'
LIMIT 1
    };

    my $static = $vr::dbh->prepare($query);
    $static->execute($thread_id, $post_id);
    $static->bind_columns(\(@vr::db{ @{ $static->{NAME_lc} } }));
    $static->fetch;
}

sub _list_smileys {
    my @extra_smileys = ();

    opendir(DIR, "$vr::viewer{'template_path'}/img/emoticons_extra")
        || die "can't opendir: $vr::viewer{'template_path'}/img/emoticons_extra";
    while ((my $file = readdir(DIR))) {
        if ($file =~ /^\./) { next; }
        push(@extra_smileys, $file);
    }
    closedir DIR;

    return sort { lc $a cmp lc $b } @extra_smileys;
}

1;

