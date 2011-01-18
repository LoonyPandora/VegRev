#!/usr/bin/perl --

use strict;
use warnings;

use DBI;

our $mysql  = DBI->connect( 'DBI:mysql:database=testing', 'vegrev', 'password', { RaiseError => 1, AutoCommit => 1 } );
our $sqlite = DBI->connect( 'DBI:SQLite:dbname=main.sqlite3', '', '', { RaiseError => 1, AutoCommit => 0 } );


#convert_users();





sub convert_users {
    my $sqlite_sth = $sqlite->prepare("SELECT * FROM users");

    $sqlite_sth->execute();

    my $count = 0;
    while (my $row = $sqlite_sth->fetchrow_hashref) {

        my %mapping = (
            'id'                => $row->{'user_id'},
            'user_name'         => $row->{'user_name'},
            'display_name'      => $row->{'display_name'},
            'real_name'         => $row->{'real_name'},
            'email'             => lc($row->{'email'}),
            'password'          => $row->{'password'},
            'hide_email'        => $row->{'hide_email'},
            'mail_notify'       => $row->{'pm_notify'},
            'stealth_login'     => $row->{'stealth_login'},
            'template'          => $row->{'template'},
            'language'          => $row->{'language'},
            'tumblr'            => $row->{'tumblr'},
            'last_fm'           => $row->{'last_fm'},
            'homepage'          => $row->{'homepage'},
            'icq'               => $row->{'icq'},
            'msn'               => lc($row->{'msn'}),
            'yim'               => $row->{'yim'},
            'aim'               => $row->{'aim'},
            'gtalk'             => lc($row->{'gtalk'}),
            'skype'             => $row->{'skype'},
            'twitter'           => $row->{'twitter'},
            'flickr'            => $row->{'flickr'},
            'deviantart'        => $row->{'deviantart'},
            'vimeo'             => $row->{'vimeo'},
            'youtube'           => $row->{'youtube'},
            'facebook'          => $row->{'facebook'},
            'myspace'           => $row->{'myspace'},
            'bebo'              => $row->{'bebo'},
            'avatar'            => $row->{'avatar'},
            'usertext'          => $row->{'usertext'},
            'signature'         => $row->{'signature'},
            'biography'         => $row->{'biography'},
            'gender'            => $row->{'gender'},
            'birthday'          => $row->{'birthday'},
            'gmt_offset'        => $row->{'timezone'},
            'registration'      => $row->{'reg_time'},
            'last_online'       => $row->{'last_online'},
            'last_ip'           => $row->{'last_ip'},
            'post_count'        => $row->{'user_post_num'},
            'shout_count'       => $row->{'user_shout_num'},
            'account_disabled'  => $row->{'user_deleted'},
        );

        my @holders;

        while (my ($key, $value) = each %mapping) {
            if (!$value) {
                delete $mapping{$key};
                next;
            }

            if ($key eq 'language' && $value eq 'English') {
                delete $mapping{$key};
                next;
            }
            
            if ($key eq 'usertext' && $value =~ m/Vegetable Revolution/i) {
                if ($value =~ m/Vegetable Revolution/i || $value =~ m/YaBB/i) {
                    delete $mapping{$key};
                    next;
                }
            }

            if ($key ~~ @{['registration', 'last_online']}) {
                push(@holders, 'FROM_UNIXTIME(?)');
            } elsif ($key ~~ @{['last_ip']}) {
                push(@holders, 'INET_ATON(?)');
            } else {
                push(@holders, '?');
            }
        }

        my $fields          = join(',', keys %mapping);
        my $placeholders    = join(',', @holders);
        my @binds           = values %mapping;

        # Don't worry, no SQL injection here.
        my $sql = qq{
            INSERT INTO user ($fields)
            VALUES ($placeholders)
        };

        $mysql->do($sql, undef, @binds);

        $count++;
        print "DONE $count $row->{'user_name'}\n";
    }
    
}

1;