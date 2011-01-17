#!/usr/bin/perl --

package converter;
use strict;
use warnings;

use Time::HiRes qw(time);
use Time::Local;

use DBIx::Transaction;

our $mysql  = DBIx::Transaction->connect( 'DBI:mysql:database=testing', 'vegrev', 'password', { RaiseError => 1, AutoCommit => 0 } );
our $sqlite = DBIx::Transaction->connect( 'DBI:SQLite:dbname=main.sqlite3', '', '', { RaiseError => 1, AutoCommit => 0 } );

convert_users();

sub convert_users {
    my $sqlite_sth = $sqlite->prepare("SELECT * FROM users");

    $sqlite_sth->execute();

    my $count = 0;
    $mysql->begin_work;
    while (my $row = $sqlite_sth->fetchrow_hashref) {
        my $sql = q{
            INSERT INTO user (
                id,                 user_name,      display_name,       real_name,          email,
                password,           hide_email,     mail_notify,        stealth_login,      template,
                language,           tumblr,         last_fm,            homepage,           icq,
                msn,                yim,            aim,                gtalk,              skype,
                twitter,            flickr,         deviantart,         vimeo,              youtube,
                facebook,           myspace,        bebo,               avatar,             usertext,
                signature,          biography,      gender,             birthday,           gmt_offset,
                registration,       last_online,    last_ip,            post_count,         shout_count,
                account_disabled
            )
            VALUES (
                ?, ?, ?, ?, ?,
                ?, ?, ?, ?, ?,
                ?, ?, ?, ?, ?,
                ?, ?, ?, ?, ?,
                ?, ?, ?, ?, ?,
                ?, ?, ?, ?, ?,
                ?, ?, ?, ?, ?,
                FROM_UNIXTIME(?), FROM_UNIXTIME(?), INET_ATON(?), ?, ?,
                ?
            )
        };

        my @bind = (
            $row->{'user_id'},      $row->{'user_name'},        $row->{'display_name'},    $row->{'real_name'},        $row->{'email'},  
            $row->{'password'},     $row->{'hide_email'},       $row->{'pm_notify'},       $row->{'stealth_login'},    $row->{'template'},
            $row->{'language'},     $row->{'tumblr'},           $row->{'last_fm'},         $row->{'homepage'},         $row->{'icq'},  
            $row->{'msn'},          $row->{'yim'},              $row->{'aim'},             $row->{'gtalk'},            $row->{'skype'},  
            $row->{'twitter'},      $row->{'flickr'},           $row->{'deviantart'},      $row->{'vimeo'},            $row->{'youtube'},  
            $row->{'facebook'},     $row->{'myspace'},          $row->{'bebo'},            $row->{'avatar'},           $row->{'usertext'},  
            $row->{'signature'},    $row->{'biography'},        $row->{'gender'},          $row->{'birthday'},         $row->{'timezone'},  
            $row->{'reg_time'},     $row->{'last_online'},      $row->{'last_ip'},         $row->{'user_post_num'},    $row->{'user_shout_num'},
            $row->{'user_deleted'}
        );

        $mysql->do($sql, undef, @bind);
    
        $count++;

        if ( $count % 1000 == 0 ) {
            print "COMMIT $count\n";
            $converter::mysql->commit;
            $converter::mysql->begin_work;
        }
    }
    
    print "COMMIT $count\n";
    $converter::mysql->commit;
}

