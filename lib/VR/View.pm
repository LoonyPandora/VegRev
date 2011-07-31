package VR::View;

use common::sense;
use Dancer ':syntax';

use Digest::SHA;
use HTML::Entities;
use Time::Duration;
use Time::Local;
use Time::HiRes qw/time/;

use JavaScript::Minifier::XS;
use CSS::Minifier::XS;


# This provides view helpers. Named like this so it's the right namespace

sub run_time {    
    return sprintf("%.3f", time() - $VR::global->{'start_time'});
}

sub current_date {
    my $offset = session('gmt_offset') * 3600;

    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = gmtime(time() + $offset);

    my @months = qw(January February March April May June July August September October November December);

    my $ampm;
    if ($hour > 11) { $hour = $hour-12; $ampm = "pm"; } 
    else { $ampm = "am"; }
    if ($hour == 0) { $hour = 12; }

    $year += 1900;
    $min  = sprintf("%.2d", $min);
    my $ordinal = &_get_ordinal($mday);

    return qq{$mday$ordinal $months[$mon] $year, $hour:$min$ampm};
}

sub _get_ordinal {
    $_[0] =~ /^(?:\d+|\d[,\d]+\d+)$/ or return $_[0];
    return "nd" if $_[0] =~ /(?<!1)2$/;
    return "rd" if $_[0] =~ /(?<!1)3$/;
    return "st" if $_[0] =~ /(?<!1)1$/;
    return "th";
}


# Access app config in templates
sub config {
    my $setting = shift;    
    my $settings = Dancer::Config->settings;

    return $settings->{config}{$setting};
}


# Generates an img tag when passed an avatar, will pass default avatar if there is none.
sub avatar_img {
    my ($avatar, $usertext, $class) = @_;

    $class //= 'avatar';
    my $base_url = 'http://www.vegetablerevolution.co.uk/uploads';
    
    # We need to encode the individual items, as this function returns HTML
    # And so isn't encoded automagically in the template
    $avatar     = encode_entities($avatar) if $avatar;
    $usertext   = encode_entities($usertext) if $usertext;

    if ($avatar && $avatar =~ /^\d+\.\w{3,4}/) {
        return qq{<img src="$base_url/$avatar" alt="$usertext" class="$class" />};
    } else {
        return qq{<img src="http://vegrev.local/img/icons/user_female_128.png" alt="No Avatar" class="$class" />};
    }

}

sub avatar_link {
    my ($user_name, $display_name, $avatar, $usertext) = @_;
    
    my $base_url = 'http://www.vegetablerevolution.co.uk/uploads';

    $avatar        = encode_entities($avatar)       if $avatar;
    $usertext      = encode_entities($usertext)     if $usertext;
    $user_name     = encode_entities($user_name)    if $user_name;
    $display_name  = encode_entities($display_name) if $display_name;

    if ($avatar && $avatar =~ /^\d+\.\w{3,4}/) {
       return qq{<a href="http://vegrev.local/profile/$user_name"><img src="$base_url/$avatar" alt="$display_name - $usertext" /></a>};
    } else {
        return qq{<a href="http://vegrev.local/profile/$user_name"><img src="http://vegrev.local/img/icons/user_female_128.png" alt="No Avatar" /></a>};
    }

}


sub username_link {
    my ($user_name, $display_name) = @_;

    $user_name     = encode_entities($user_name)    if $user_name;
    $display_name  = encode_entities($display_name) if $display_name;

    return qq{<a href="http://vegrev.local:5000/profile/$user_name">$display_name</a>};
}


sub time_ago {
    my ($timestamp, $precision) = @_;

    my $seconds = (time - $timestamp);

    if ($seconds < 60) {
        return 'just now';
    } else {
        return ago($seconds, $precision);
    }
}




# TODO: Remove this junk - just a temp fix to preview design before I write a proper parser.


sub parse_bbcode {
    my ($string) = @_;
    
    $string =~ s~\[code\](.+?)\[/code\]~&_add_code_tag($1)~eisg;

    # Don't want lots of newlines at the beginning or end of posts
    $string =~ s~^(\[br\])+~~ig;
    $string =~ s~(\[br\])+$~~ig;

    $string =~ s~\[br\]~<br />~ig;
    $string =~ s~\[code\]~ \[code\]~ig;
    $string =~ s~\[/code\]~ \[/code\]~ig;
    $string =~ s~\[quote\]~ \[quote\]~ig;
    $string =~ s~\[/quote\]~ \[/quote\]~ig;
    $string =~ s~\[img\]~ \[img\]~ig;

    $string =~ s~\[img](.*?)\.(jpeg|jpg|png|gif|bmp)\[/img\]~<img src="$1.$2" />~isg;

    $string =~ s~\[([^\]]{0,30})\n([^\]]{0,30})\]~\[$1$2\]~g;
    $string =~ s~\[/([^\]]{0,30})\n([^\]]{0,30})\]~\[/$1$2\]~g;
    $string =~ s~(\w+://[^<>\s\n\"\]\[]+)\n([^<>\s\n\"\]\[]+)~$1\n$2~g;

    $string =~ s~\[b\](.*?)\[/b\]~<b>$1</b>~isg;
    $string =~ s~\[i\](.*?)\[/i\]~<i>$1</i>~isg;
    $string =~ s~\[u\](.*?)\[/u\]~<u>$1</u>~isg;
    $string =~ s~\[s\](.*?)\[/s\]~<s>$1</s>~isg;
    $string =~ s~\[glb\](.*?)\[/glb\]~<b>$1</b>~isg;
    $string =~ s~\[move\](.*?)\[/move\]~<marquee>$1</marquee>~isg;

    $string =~ s~\[color=([A-Za-z0-9# ]+)\](.+?)\[/color\]~<span style="color:$1;">$2</span>~isg;
    $string =~ s~\[font=([A-Za-z0-9'" ]+)\](.+?)\[/font\]~<span style="font-family:$1;">$2</span>~isg;

    $string =~ s~\[tt\](.*?)\[/tt\]~<tt>$1</tt>~isg;
    $string =~ s~\[left\](.*?)\[/left\]~<div style="text-align: left;">$1</div>~isg;
    $string =~ s~\[center\](.*?)\[/center\]~<div style="text-align: center;">$1</div>~isg;
    $string =~ s~\[right\](.*?)\[/right\]~<div style="text-align: right;">$1</div>~isg;
    $string =~ s~\[sub\](.*?)\[/sub\]~<sub>$1</sub>~isg;
    $string =~ s~\[sup\](.*?)\[/sup\]~<sup>$1</sup>~isg;

    $string =~ s~\[spoiler\](.*?)\[/spoiler\]~<span class="spoiler">$1</span>~isg;
    $string =~ s~\[edit\](.*?)\[/edit\]~<span class="edit">$1</span>~isg;
    $string =~ s~\[size=([6-9]|[1-7][0-9])?\](.*?)\[/size\]~<span style="font-size: $1px">$2</span>~isg;
    $string =~ s~\[font="(.*?)"\](.*?)\[/font\]~<span style="font-family: $1">$2</span>~isg;

    $string =~ s~\[url=(http[s]?://)?(.+?)\](.+?)\[/url\]~<a href="http://$2">$3</a>~isg;
    $string =~ s~\[url\](http[s]?://)?(.+?)\[/url\]~<a href="http://$2">$2</a>~isg;

    $string =~ s{\[quote=".+"](.+?)\[\/quote\]}{<q>$1</q>}isg;
    
    return $string;
}





sub asset_pipeline {
    my ($files) = @_;

    my @js_tags = map { qq~<script src="$_"></script>~; } merge_and_concatenate({
        type  => 'js',
        files => [grep(/\.js$/, @$files)],
    });

    my @css_tags = map { qq~<link rel="stylesheet" href="$_">~; } merge_and_concatenate({
        type  => 'css',
        files => [grep(/\.css$/, @$files)],
    });

    return join("\n", @css_tags, @js_tags);
}


# Returns a list of all js / css that is used on a given page.
# Handles caching also
sub merge_and_concatenate {
    my ($args) = @_;

    my $settings  = Dancer::Config->settings();
    my $sha       = Digest::SHA->new(256);
    my $base_path = $settings->{public};
    my $base_url  = $settings->{config}->{static_url};

    # Calculating hash of all files to check for changes
    for my $file (@{ $args->{files} }) {
        my $file_path = "$base_path/$args->{type}";

        if (-f "$file_path/$file") {
            $sha->addfile("$file_path/$file");
        }
    }

    # Check if we've already cached this exact combination
    # Shorter filenames so it looks prettier. It's good enough for git
    my $new_digest = substr($sha->hexdigest, 0, 8);
    if ( -f "$base_path/cache/$new_digest.$args->{type}" && -s "$base_path/cache/$new_digest.$args->{type}") {

        # Cache file exists and has content, so lets use it!
        return ("$base_url/cache/$new_digest.$args->{type}");

    } elsif (open my $outfile, '>', "$base_path/cache/$new_digest.$args->{type}") {

        # Cache needs to be recreated, and we have write permission
        my @contents;
        for my $file (@{ $args->{files} }) {
            my $file_path = "$base_path/$args->{type}";

            if (open my $infile, '<', "$file_path/$file") {
                push @contents, do { local $/; <$infile>; };
                push @contents, "\n";
                close $infile;
            }

        }

        my $all_files;
        if ($args->{type} eq 'js') {
            $all_files = JavaScript::Minifier::XS::minify(join("\n", @contents));
        } elsif ($args->{type} eq 'css') {
            $all_files = CSS::Minifier::XS::minify(join("\n", @contents));
        }

        print $outfile $all_files;
        close $outfile;

        # Check we've really got data in there
        if (-s "$base_path/cache/$new_digest.$args->{type}") {
            return ("$base_url/cache/$new_digest.$args->{type}");
        } else {
            unlink "$base_path/cache/$new_digest.$args->{type}";
            return map { "$base_url/$args->{type}/$_" } @{ $args->{files} };
        }

    } else {

        # Cache needs to be recreated, but we can't for some reason
        # So just return original css files
        return map { "$base_url/$args->{type}/$_" } @{ $args->{files} };
    }

}




1;