#!/usr/bin/env perl

###############################################################################
# forums.pl
# =============================================================================
# Version:        Vegetable Revolution 3.0
# Released:        1st June 2009
# Revision:        $Rev$
# Copyright:        James Aitken <http://www.loonypandora.com>
###############################################################################

package vr;
use strict;

use lib "../lib";
use CGI::Minimal;
use Time::Local;
use Text::ScriptTemplate;
use Digest::MD5 qw(md5_hex);
use Crypt::Bcrypt::Easy;
use JSON::XS;
use DBI;

# Global variable setup
our %GET    = ();
our %POST   = ();
our %COOKIE = ();

our %config = ();
our %tmpl   = ();
our %db     = ();
our %viewer = ();

our %loop = ();
our $loop = '';

require "../config/paths.config";
require "../config/sensitive.config";
require "../config/settings.config";
require "$config{'langdir'}/$config{'language'}.lang";

# If is in maintenance mode
if (-f "../config/maintenance.lock") {
    print "Status: 302 Found\n";
    print "Location: $vr::config{'base_url'}/errors/down.html\n\n";
}

$config{'gmtime'} = int(timegm(gmtime));    # Init this now because time will change before the end of the script run.

our $dbh = DBI->connect("DBI:mysql:database=vegrev;host=127.0.0.1;port=3306", "root", "", { RaiseError => 1 });
$dbh->do("SET NAMES 'utf8'");
$dbh->do("SET CHARACTER SET 'utf8'");

our $cgi = CGI::Minimal->new;

$SIG{__DIE__} = sub {
    # Give a nice error page if the server is busy
    # database is locked, or read-only database.
    print "Content-Type: text/html\n\n";
    print
        qq|<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
  <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
  <meta http-equiv="Content-Language" content="EN" />
  <meta http-equiv="Pragma" content="no-cache" />
  <meta http-equiv="Cache-Control" content="no-cache" />
  <meta http-equiv="Expires" content="0" />
  <meta http-equiv="imagetoolbar" content="no" />

  <title>[VR] 500 Internal Server Error</title>
  <style type="text/css">
        body{background-color:#d8d8c8;color:#333333;font-family:Verdana,Helvetica,Arial,"Sans Serif";font-size:11px;line-height:1.25em;border:0;margin:0;padding:0 0 0 0;height:100%;overflow:auto;}
        #everything{width:980px;margin-left:auto;margin-right:auto;padding:0;}
        #maincontainer_auth{display:block;margin:50px auto 0 auto;padding:0;width:730px;}
        #main_content{padding-left:15px;}
        .main_roundtop,.shout_roundtop,.main_roundbottom,.shout_roundbottom{height:10px;}
        .error,p{font-size:18px;line-height:1em;font-family:Courier;letter-spacing:-1px;line-height:1.25em;font-weight:normal;margin-bottom:0.75em;}
        p{font-weight:bold;}
        #copyright{font-size:10px;clear:both;text-align:center;padding-top:40px;padding-bottom:40px;color:#777777;line-height:8px;}
        hr{border-color:#cccccc;border-style:dashed;border-width:1px 0 0;clear:both;margin:20px 15px 20px 0;height:0;}
        h1,h2{font-family:Helvetica,Arial,"Sans Serif";margin:0;padding:0;line-height:1.25em;}
        h1{font-size:36px;letter-spacing:-2px;line-height:36px;}
        h2{font-size:18px;letter-spacing:-1px;margin-left:2px;margin-bottom:14px;}
        p{font-family:Helvetica;}
        a,label{color:#4f7f2a;text-decoration:none;}
        a:hover{color:#f75342;}
        #advert{margin-left:-14px;}
        .main_roundtop{background-image:url('./img/body_top_bg.png');}
        .main_roundbottom{background-image:url('./img/body_bottom_bg.png');}
        #main_content{background-color:#ffffff;}
        h1{color:#222222;}
        h2{color:#969696;}
  </style>

</head>

<body>

<div id="everything">
  <div id="maincontainer_auth">
    <div class="main_roundtop">&nbsp;</div>
    <div id="main_content">
      <h1>Fission Mailed</h1>
      <h2>500 Internal Server Error</h2>
      <hr />
          <pre class="error">$_[0]</pre>
      <br class="clear" />
      </div>
    </div>
    <div class="main_roundbottom">&nbsp;</div>
  </div>
</div>
<div id="copyright">
  &copy; James Aitken &amp; The Vegetable Revolution
</div>
</body>
</html>
|;

my $query = qq{
    INSERT INTO error_log (error, env, get, post, viewer, error_date)
    VALUES (?, ?, ?, ?, ?, NOW())
};

$vr::dbh->prepare($query)->execute(
    $_[0], encode_json \%ENV, encode_json \%GET, encode_json \%POST, encode_json \%vr::viewer
);

};

&_sanitize;
&_get_cookie;
unless ($vr::GET{'action'} eq 'show_shoutbox') {
    &_load_viewer;
    &_check_bans;
    if ($vr::COOKIE{'session_id'} && $vr::viewer{'user_id'}) {
        &_set_session($vr::COOKIE{'session_id'}, $vr::viewer{'user_id'});
    }
} else {
    &_quick_load_viewer;
}

&_director;

sub _sanitize {
    if ($ENV{"REQUEST_METHOD"} eq 'POST') {
        # \w+ doesn't match unicode (despite perldoc saying it does), so untaint some things totally.
        # Parameterized queries stop SQL injection. And we store data raw, not encoded html. Do that on display.
        foreach my $param ($cgi->param) {
            if ($param eq 'action' && $cgi->param($param) =~ /^(\w+)$/) { $POST{"$param"} = $1; }
            elsif ($param eq 'board_id' && $cgi->param($param) =~ /^(\w+)$/) {
                $POST{"$param"} = $1;
            } elsif ($param eq 'user_id' && $cgi->param($param) =~ /^(\w+)$/) {
                $POST{"$param"} = $1;
            } elsif ($param eq 'post_id' && $cgi->param($param) =~ /^(\w+)$/) {
                $POST{"$param"} = $1;
            }

            # Attachments are binary, so no toucha.
            elsif ($param eq 'attachment') { $POST{"$param"} = $cgi->param($param); }
            elsif ($param eq 'Filename') { $POST{"$param"} = $cgi->param($param); }
            elsif ($param eq 'Upload') { $POST{"$param"} = $cgi->param($param); }
            elsif ($param eq 'Filedata') { $POST{"$param"} = $cgi->param($param); }

            # Searching is a multiple select, so don't mess
            elsif ($param eq 'search_boards') {
                my @tmp = $cgi->param($param);
                $POST{"$param"} = \@tmp;
            }

            # Do the bbcode conversion of newlines here. So we don't forget later. We don't like newlines.
            elsif (($param eq 'message' && $cgi->param($param) =~ /^(.*)$/s)
                || ($param eq 'message_one'   && $cgi->param($param) =~ /^(.*)$/s)
                || ($param eq 'message_two'   && $cgi->param($param) =~ /^(.*)$/s)
                || ($param eq 'message_three' && $cgi->param($param) =~ /^(.*)$/s)
                || ($param eq 'message_four'  && $cgi->param($param) =~ /^(.*)$/s)
                || ($param eq 'signature'     && $cgi->param($param) =~ /^(.*)$/s)
                || ($param eq 'about'         && $cgi->param($param) =~ /^(.*)$/s))
            {
                $POST{"$param"} = $1;
                $POST{"$param"} =~ s~\r\n|\r|\n~\[br\]~g;

                # TODO: It re-taints itself unless I do this. WTF?
                if ($POST{"$param"} =~ /^(.*)$/) { $POST{"$param"} = $1; }
            }

            # Strip newlines from all other fields, rather than rejecting them.
            # More userfriendly if someone copypasta's a newline accidentally.
            elsif ($cgi->param($param) =~ /^(.*)$/s) {
                $POST{"$param"} = $1;
                $POST{"$param"} =~ s~\r\n|\r|\n~~sg;

                # TODO: It re-taints itself unless I do this. WTF?
                if ($POST{"$param"} =~ /^(.*)$/) { $POST{"$param"} = $1; }
            }
        }

        if ($POST{'attachment'}) {
            $POST{'attach_file'} = $cgi->param_filename('attachment') =~ s{[^A-Za-z0-9\-\_\.]}{}r;
        }
        if ($POST{'uploadify'})  { $POST{'attach_file'} = $POST{'uploadify'}; }
        if ($POST{'attach_file'} =~ /^(.*)\.(\w{1,4})$/) {
            $POST{'attach_ext'}  = $2;
            $POST{'attach_file'} = "$1.$POST{'attach_ext'}";
        }
    } else {
        foreach my $param ($cgi->param) {
            # warn $param;
            # all get params should be ASCII words, and contain no newlines
            if ($cgi->param($param) =~ /^([A-Za-z0-9\/-_]+)$/) { $GET{"$param"} = $1; }

            # Apart from search_boards and search_query
            elsif ($param eq 'search_boards') { $GET{"$param"} = $cgi->param($param); }
            elsif ($param eq 'search_query')  { $GET{"$param"} = $cgi->param($param); }

        }

        # Set defaults if none passed
        if    (!$GET{'page'})         { $GET{'page'} = 1; }
        elsif ($GET{'page'} eq 'new') { $GET{'page'} = 'new'; }
        elsif ($GET{'page'} eq 'all') { $GET{'page'} = 'all'; }
        else                          { $GET{'page'} =~ s/\D+//g; }
        if (!$GET{'action'}) { $GET{'action'} = "show_portal"; }
        else                 { $GET{'action'} =~ s/\d+//g; }
    }
}

# Shamelessly stolen from CGI::Cookie
sub _get_cookie {
    my $raw_cookie = $ENV{'HTTP_COOKIE'} || $ENV{'COOKIE'};
    my @pairs = split("[;,] ?", $raw_cookie);

    my ($key, $value);
    foreach (@pairs) {
        s/\s*(.*?)\s*/$1/;
        if (/^([^=]+)=(.*)/) {
            $key   = $1;
            $value = $2;
        } else {
            $key   = $_;
            $value = '';
        }
        $vr::COOKIE{$key} = $value;
    }

    if ($vr::COOKIE{'session_id'} =~ /^(\w{32})$/) { $vr::COOKIE{'session_id'} = $1; }
    elsif ($vr::COOKIE{'session_id'}) { die("Your session cookie is fucked, man."); }
}

sub _director {
    no strict;
    no warnings;

    # If you wink in an action I keel you!
    if ($ENV{"REQUEST_METHOD"} eq 'POST') {
        if    ($POST{'action'} =~ /^_/) { die("Can't access private methods"); }
        elsif (!$POST{'action'} && $POST{'Filedata'} && $POST{'Upload'} && $POST{'Filename'}){
            &_start_attachments();
        }
        elsif (!$POST{'action'})        { die("POST: Unable to direct to correct controller"); }
        else                            { &{ $POST{'action'} }; }
    } else {
        if    ($GET{'action'} =~ /^_/) { die("Can't access private methods"); }
        elsif (!$GET{'action'})        { die("GET: Unable to direct to correct controller"); }
        else                           { &{ $GET{'action'} }; }
    }
    use strict;
    use warnings;
}

sub AUTOLOAD {
    no strict;
    no warnings;
    use vars qw($AUTOLOAD);
    my (undef, $sub) = split(/::/, $AUTOLOAD);

    require "../config/subroutines.config";

    if (-f ".$sublist{$sub}") {
        require "." . $sublist{$sub};
        &{$sub};
    } else {
        die "Couldn't find subroutine: $sub";
    }
    use strict;
    use warnings;
}

sub _check_bans {
    open(IPBAN, "$vr::config{'base_path'}/config/ban_ip.config") || die "$!";
    my @ip_lines = <IPBAN>;
    close IPBAN;
    open(USERBAN, "$vr::config{'base_path'}/config/ban_user.config") || die "$!";
    my @user_lines = <USERBAN>;
    close USERBAN;
    open(EMAILBAN, "$vr::config{'base_path'}/config/ban_email.config") || die "$!";
    my @email_lines = <EMAILBAN>;
    close EMAILBAN;

    foreach my $ip (@ip_lines) {
        chomp $ip;
        if ($vr::viewer{'ip_address'} eq $ip && $vr::viewer{'user_id'} ne '1') {
            die "You are banned";
        }
    }

    foreach my $user (@user_lines) {
        chomp $user;
        if ($vr::viewer{'user_name'} eq $user && $vr::viewer{'user_id'} ne '1') {
            die "You are banned";
        }
    }

    foreach my $email (@email_lines) {
        chomp $email;
        if ($vr::viewer{'email'} eq $email && $vr::viewer{'user_id'} ne '1') {
            die "You are banned";
        }
    }
}

# http://www.perlmonks.org/?node_id=665714
# http://masanoriprog.wordpress.com/2008/09/28/closing-dbh-with-active-statement-handles-during-global-destruction/
# If it ever seems like a form submit "hangs" after submitting, but double submitting it works...
# Chances are the DB was closed with a writer lock on it, because it used a sth that I don't destroy here.
# I should never use an sth that is not in here.
END {
    if ($vr::loop)       { $vr::loop->finish;       undef $vr::loop; }
    if ($vr::db)         { $vr::db->finish;         undef $vr::db; }
    if ($vr::viewer)     { $vr::viewer->finish;     undef $vr::viewer; }
    if ($vr::poll_loop)  { $vr::poll_loop->finish;  undef $vr::poll_loop; }
    if ($vr::board_loop) { $vr::board_loop->finish; undef $vr::board_loop; }
    if ($vr::dbh)        { $vr::dbh->disconnect;    undef $vr::dbh; }
}

1;
