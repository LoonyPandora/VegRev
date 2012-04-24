package VegRev::ViewHelpers;

use v5.14;
use feature 'unicode_strings';
use utf8;
use common::sense;

use Dancer qw(:moose);

use HTML::Entities;
use Carp;
use Data::Dumper;

# Because you cannot set engine configs individually, view helpers go in here
# and the settings for template engine are in here.

set 'engines' => {
    xslate => {
        cache    => 0,
        syntax   => 'Kolon',
        function => {
            uppercase  => \&uppercase,
            lowercase  => \&lowercase,
            bbcode     => \&bbcode,
            avatar_img => \&avatar_img,
        },
    }
};

set 'template' => 'xslate';


sub uppercase {
    return uc $_[0]
}

sub lowercase {
    return lc $_[0]
}


sub avatar_img {
    my ($avatar, $usertext, $class) = @_;

    $class  //= 'avatar';
    $avatar   = encode_entities($avatar)   if $avatar;
    $usertext = encode_entities($usertext) if $usertext;

    my $base_url = 'http://www.vegetablerevolution.co.uk/uploads';

    if ($avatar && $avatar =~ /^\d+\.\w{3,4}/) {
        return qq{<img src="$base_url/$avatar" alt="$usertext" class="$class" />};
    } else {
        return qq{<img src="http://vegrev.local/img/icons/user_female_128.png" alt="No Avatar" class="$class" />};
    }

}


# Junk, just parses the basics. Will have to write proper BBCode parser
sub bbcode {
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


1;
