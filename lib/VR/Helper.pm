###############################################################################
# VR::Helper.pm
# =============================================================================
# Version:      Vegetable Revolution 4.0
# Released:     1st January 2010
# Author:       James Aitken <http://www.loonypandora.com/>
###############################################################################

package VR::Helper;

use strict;
no warnings;

use base 'Exporter';
use vars '@EXPORT_OK';

@EXPORT_OK = qw();

# Parse::BBCode has a HORRIBLE Memory leak. DO NOT USE EVER!!!!

sub do_yabbc {
	${$_[0]} =~ s~\[code\](.+?)\[/code\]~&_add_code_tag($1)~eisg;

  # Don't want lots of newlines at the beginning or end of posts
  ${$_[0]} =~ s~^(\[br\])+~~ig;
  ${$_[0]} =~ s~(\[br\])+$~~ig;
  
  ${$_[0]} =~ s~\[br\]~<br />~ig;
  ${$_[0]} =~ s~\[code\]~ \[code\]~ig;
	${$_[0]} =~ s~\[/code\]~ \[/code\]~ig;
	${$_[0]} =~ s~\[quote\]~ \[quote\]~ig;
	${$_[0]} =~ s~\[/quote\]~ \[/quote\]~ig;
	${$_[0]} =~ s~\[img\]~ \[img\]~ig;

	${$_[0]} =~ s~\[img](.*?)\.(jpeg|jpg|png|gif|bmp)\[/img\]~<img src="$1.$2" />~isg;

	${$_[0]} =~ s~\[([^\]]{0,30})\n([^\]]{0,30})\]~\[$1$2\]~g;
	${$_[0]} =~ s~\[/([^\]]{0,30})\n([^\]]{0,30})\]~\[/$1$2\]~g;
	${$_[0]} =~ s~(\w+://[^<>\s\n\"\]\[]+)\n([^<>\s\n\"\]\[]+)~$1\n$2~g;
	
	${$_[0]} =~ s~\[b\](.*?)\[/b\]~<b>$1</b>~isg;
	${$_[0]} =~ s~\[i\](.*?)\[/i\]~<i>$1</i>~isg;
	${$_[0]} =~ s~\[u\](.*?)\[/u\]~<u>$1</u>~isg;
	${$_[0]} =~ s~\[s\](.*?)\[/s\]~<s>$1</s>~isg;
	${$_[0]} =~ s~\[glb\](.*?)\[/glb\]~<b>$1</b>~isg;
	${$_[0]} =~ s~\[move\](.*?)\[/move\]~<marquee>$1</marquee>~isg;

	${$_[0]} =~ s~\[color=([A-Za-z0-9# ]+)\](.+?)\[/color\]~<span style="color:$1;">$2</span>~isg;
	${$_[0]} =~ s~\[font=([A-Za-z0-9'" ]+)\](.+?)\[/font\]~<span style="font-family:$1;">$2</span>~isg;

	${$_[0]} =~ s~\[tt\](.*?)\[/tt\]~<tt>$1</tt>~isg;
	${$_[0]} =~ s~\[left\](.*?)\[/left\]~<div style="text-align: left;">$1</div>~isg;
	${$_[0]} =~ s~\[center\](.*?)\[/center\]~<div style="text-align: center;">$1</div>~isg;
	${$_[0]} =~ s~\[right\](.*?)\[/right\]~<div style="text-align: right;">$1</div>~isg;
	${$_[0]} =~ s~\[sub\](.*?)\[/sub\]~<sub>$1</sub>~isg;
	${$_[0]} =~ s~\[sup\](.*?)\[/sup\]~<sup>$1</sup>~isg;

	${$_[0]} =~ s~\[spoiler\](.*?)\[/spoiler\]~<span class="spoiler">$1</span>~isg;
	${$_[0]} =~ s~\[edit\](.*?)\[/edit\]~<span class="edit">$1</span>~isg;
  ${$_[0]} =~ s~\[size=([6-9]|[1-7][0-9])?\](.*?)\[/size\]~<span style="font-size: $1px">$2</span>~isg;
  ${$_[0]} =~ s~\[font="(.*?)"\](.*?)\[/font\]~<span style="font-family: $1">$2</span>~isg;

	${$_[0]} =~ s~\[url=(http[s]?://)?(.+?)\](.+?)\[/url\]~<a href="http://$2" />$3</a>~isg;
	${$_[0]} =~ s~\[url\](http[s]?://)?(.+?)\[/url\]~<a href="http://$2" />$2</a>~isg;

#  while (${$_[0]} =~ s~\[quote\](.+?)\[/quote\]~<blockquote>$1</blockquote>~isg) { }
#  while (${$_[0]} =~ s~\[quote="?(.+)\|(.+)\|(\d+)\|(\d+)\|(\d+)"?\](.+?)\[/quote\]~&VR::Helper::do_quotations($1, $2, $3, $4, $5, $6)~eisg) { }


  while (${$_[0]} =~ s~\[quote\]\[quotemeta\]\[name\]([^\[]+)\[/name\]\[thread\]([^\[]+)\[/thread\]\[post\]([^\[]+)\[/post\]\[timestamp\]([^\[]+)\[/timestamp\]\[/quotemeta\](.+?)\[/quote\]~&VR::Helper::do_quotations($1, $2, $3, $4, $5, $6)~eisg) { }

  return &VR::Helper::do_emoticons(\${$_[0]});
}


sub do_quotations {
  my ($display_name, $thread_id, $message_id, $message_time, $message_body) = @_;
  
  # TODO: Make this nicer, a unique number for a quote
  my $rnd = int(rand(1000)) . $message_id;

  my $string = qq~<blockquote id="$rnd"><p class="quotemeta xsmall" title="$display_name|$thread_id|$message_id|$message_time"><a href="javascript:toggle_quotes('$rnd');">+</a> Quote: <a href='/forum/board/$thread_id/post/$message_id'>$display_name, ~;
  $string .= &VR::Helper::format_time($message_time, 'semi');
  $string .= '</a></p>';
  $string .= "$message_body";
  $string .= '</blockquote>';
  
  return $string;

}

sub do_emoticons {
  # Change links, so it isn't turned into a smiley
	${$_[0]} =~ s~http://~http\|//~isg;

  # Evil first, as it contains other smileys
	${$_[0]} =~ s~>:\)~<img src="/img/emoticons/evil.gif" alt="wink" />~isg;

	${$_[0]} =~ s~:\)~<img src="/img/emoticons/smiley.gif" alt="smiley" />~isg;
	${$_[0]} =~ s~;\)~<img src="/img/emoticons/wink.gif" alt="wink" />~isg;
	${$_[0]} =~ s~:D~<img src="/img/emoticons/cheesy.gif" alt="wink" />~isg;
	${$_[0]} =~ s~;D~<img src="/img/emoticons/grin.gif" alt="wink" />~isg;
	${$_[0]} =~ s~;/~<img src="/img/emoticons/smug.gif" alt="wink" />~isg;
	${$_[0]} =~ s~>:\(~<img src="/img/emoticons/angry.gif" alt="wink" />~isg;
	${$_[0]} =~ s~:\(~<img src="/img/emoticons/sad.gif" alt="wink" />~isg;
	${$_[0]} =~ s~:O~<img src="/img/emoticons/shocked.gif" alt="wink" />~isg;
	${$_[0]} =~ s~8\)~<img src="/img/emoticons/cool.gif" alt="wink" />~isg;
	${$_[0]} =~ s~:\?~<img src="/img/emoticons/huh.gif" alt="wink" />~isg;
	${$_[0]} =~ s~::\)~<img src="/img/emoticons/rolleyes.gif" alt="wink" />~isg;
	${$_[0]} =~ s~:P~<img src="/img/emoticons/tongue.gif" alt="wink" />~isg;
	${$_[0]} =~ s~:x~<img src="/img/emoticons/embarassed.gif" alt="wink" />~isg;
	${$_[0]} =~ s~:\|~<img src="/img/emoticons/lipsrsealed.gif" alt="wink" />~isg;
	${$_[0]} =~ s~:/~<img src="/img/emoticons/undecided.gif" alt="wink" />~isg;
	${$_[0]} =~ s~:\*~<img src="/img/emoticons/kiss.gif" alt="wink" />~isg;
	${$_[0]} =~ s~:'\(~<img src="/img/emoticons/cry.gif" alt="wink" />~isg;
	${$_[0]} =~ s~\^\^d~<img src="/img/emoticons/thumbsup.gif" alt="wink" />~isg;

  # Change links back.
	${$_[0]} =~ s~http\|//~http://~isg;

  return ${$_[0]};
}


sub do_censor {
  return $_[0];
}






sub calc_prev_next {
  my ($current_page, $total_pages) = @_;

}



# Adds thousand seperators to number
sub format_numbers {
  my $number = $_[0] || 0;
	$number =~ s/\d{1,3}(?=(\d{3})+(?!\d))/$&,/g;
	return $number;
}


# user_link('user_name', 'display_name', 'color');
sub user_link {
  if ($_[2]) {
  	return qq~<a href="/user/$_[0]" class="usernamelink" style="color: $_[2];">$_[1]</a>~;
	} else {
  	return qq~<a href="/user/$_[0]" class="usernamelink">$_[1]</a>~;
	}
}


# format_time('timestamp', 'semi|full|current_date|[]');
sub format_time {
  my ($timestamp, $format) = @_;
  if (!$format) { $format = ''; }
  if (!$timestamp) { $timestamp = 1; }
	my $adjusted_time = $VR::TIMESTAMP;

	# We work in GMT throughout the site, only adjusting for BST on display.
	# Do it manually for the next 10 years. There is no better way... :(
	if 		(time > 1238292000 && time < 1256432400) 	{ $timestamp += 3600; $adjusted_time += 3600; } # March 29 - Oct 25 - 2009
	elsif (time > 1269741600 && time < 1288490400)  {	$timestamp += 3600; $adjusted_time += 3600; } # March 28 - Oct 31 - 2010
	elsif (time > 1301191200 && time < 1319940000)  {	$timestamp += 3600; $adjusted_time += 3600; } # March 27 - Oct 30 - 2011
	elsif (time > 1332640800 && time < 1351389600)  {	$timestamp += 3600; $adjusted_time += 3600; } # March 25 - Oct 28 - 2012
	elsif (time > 1364695200 && time < 1382839200)  {	$timestamp += 3600; $adjusted_time += 3600; } # March 31 - Oct 27 - 2013
	elsif (time > 1396144800 && time < 1414288800)  {	$timestamp += 3600; $adjusted_time += 3600; } # March 30 - Oct 26 - 2014
	elsif (time > 1427594400 && time < 1445738400)  {	$timestamp += 3600; $adjusted_time += 3600; } # March 29 - Oct 25 - 2015
	elsif (time > 1459044000 && time < 1477792800)  {	$timestamp += 3600; $adjusted_time += 3600; } # March 27 - Oct 30 - 2016
	elsif (time > 1490493600 && time < 1509242400)  {	$timestamp += 3600; $adjusted_time += 3600; } # March 26 - Oct 29 - 2017
	elsif (time > 1521943200 && time < 1540692000)  {	$timestamp += 3600; $adjusted_time += 3600; } # March 25 - Oct 28 - 2018
	elsif (time > 1553997600 && time < 1572141600)  {	$timestamp += 3600; $adjusted_time += 3600; } # March 31 - Oct 27 - 2019
	
	my (undef,$min,$hour,$mday,$mon,$year,undef) = gmtime($timestamp);
	my $ampm = undef;
	
	if ($hour > 11) { $hour = $hour-12; $ampm = "pm"; } 
	else { $ampm = "am"; }
	if ($hour == 0) { $hour = 12; }
	$min 	= sprintf("%.2d", $min);
	$year	+= 1900;

	my $ordinal = &_get_ordinal($mday);

	my $days_ago 		= (int((($adjusted_time/60)/60)/24)-int((($timestamp/60)/60)/24));
	my $hours_ago   = (int(($adjusted_time/60)/60)-int(($timestamp/60)/60));
	my $minutes_ago = (int($adjusted_time/60)-int($timestamp/60));
	my $weeks_ago 	= (int($days_ago/7));
	my $months_ago 	= (int($days_ago/30));

	if ($format eq 'current_date')						 { return qq~$mday<sup>$ordinal</sup> $VR::long_month_names[$mon] $year, $hour:$min $ampm~; }
   elsif ($minutes_ago <= 1)                 { return qq~Just now~; }
   elsif ($minutes_ago < 60)                 { return qq~$minutes_ago minutes ago~; }
   elsif ($hours_ago == 1)                   { return qq~$hours_ago hour ago~; }
   elsif ($hours_ago < 13)                   { return qq~$hours_ago hours ago~; }
   elsif ($days_ago == 0)                    { return qq~Today at $hour:$min $ampm~; }
   elsif ($days_ago == 1)                    { return qq~Yesterday at $hour:$min $ampm~;  }
   elsif ($format eq 'full')                 { return qq~$mday<sup>$ordinal</sup> $VR::month_names[$mon] $year at $hour:$min $ampm~; }
   elsif ($format eq 'semi')                 { return qq~$mday<sup>$ordinal</sup> $VR::month_names[$mon] $year~; }
   elsif ($days_ago > 1 && $days_ago <= 13)  { return qq~$days_ago days ago~;  }
   elsif ($days_ago > 13 && $days_ago <= 69) { return qq~$weeks_ago weeks ago~;  }
   elsif ($days_ago > 69)                    { return qq~$VR::month_names[$mon] $year~;  }
	
	else { return qq~$mday<sup>$ordinal</sup> $VR::month_names[$mon] $year at $hour:$min $ampm~; }
}


# truncate('string', 'truncate_to');
sub truncate {  
  if (!$_[0]) { $_[0] = ''; }
  if (!$_[1]) { $_[1] = 5; }
  if (length($_[0]) > $_[1]) { return sprintf("%.$_[1]s", "$_[0]")."..."; }
  else { return $_[0]; }
}


# link_to_thread('thread_id', 'subject');
sub link_to_thread {
  my ($board, $thread_id, $subject, $truncate) = @_;
  
  my $thread_link = lc($subject);
  if ($truncate && $truncate > 10) {
    $subject = &VR::Helper::truncate($subject, $truncate);
  }
  
  $thread_link =~ s/ /-/g;
  $thread_link =~ s/-+/-/g;
  $thread_link =~ s/&amp;/and/g;
  $thread_link =~ s/[^0-9a-zA-Z-]+//ig;
  $thread_link .= "-$thread_id";
  
	return qq~<a href="/forum/$board/$thread_link">$subject</a>~;
}

# Returns the thread link, with cleaned subject
sub clean_thread_id {
  my ($thread_id, $subject) = @_;
  
  my $thread_link = lc($subject);

  $thread_link =~ s/ /-/g;
  $thread_link =~ s/-+/-/g;
  $thread_link =~ s/&amp;/and/g;
  $thread_link =~ s/[^0-9a-zA-Z-]+//ig;
  $thread_link .= "-$thread_id";
  
  return $thread_link;
}

# Deprecated
sub link_photo_to_thread {
  my ($board, $thread_id, $subject, $picture_id, $truncate) = @_;

  my $thread_link = lc($subject);
  if ($truncate && $truncate > 10) {
    $subject = &VR::Helper::truncate($subject, $truncate);
  }
  
  $thread_link =~ s/ /-/g;
  $thread_link =~ s/-+/-/g;
  $thread_link =~ s/&amp;/and/g;
  $thread_link =~ s/[^0-9a-zA-Z-]+//ig;
  $thread_link .= "-$thread_id";
  
	return qq~<a href="/gallery/$board/$thread_link"><img src="/img/placeholder.png" /></a>~;
}



# --- Private --------------------------

sub _add_code_tag {
  my ($code) = @_;
  $code =~ s/\[/&#91;/g;
  $code =~ s/\]/&#93;/g;
  return qq{<span class="code">$code</span>};
}
sub _encode_tags {
  my $string = $_[0];
  $string =~ s/</&lt;/g;
  $string =~ s/>/&gt;/g;
  return $string;
}
sub _preserve_case {
  my ($from, $to) = @_;
  my ($lf, $lt) = map length, @_;

  if ($lt < $lf) { $from = substr $from, 0, $lt }
  else { $from .= substr $to, $lf }

  return uc $to | ($from ^ uc $from);
}
sub _get_ordinal {
	$_[0] =~ /^(?:\d+|\d[,\d]+\d+)$/ or return $_[0];
	return "nd" if $_[0] =~ /(?<!1)2$/;
	return "rd" if $_[0] =~ /(?<!1)3$/;
	return "st" if $_[0] =~ /(?<!1)1$/;
	return "th";
}
sub _clean_username {
	my ($name) = @_;
	$name =~ s/\s+/_/isg;
	$name =~ s/\W+//isg;
	
	return "[quote=$name link=";
}



1;