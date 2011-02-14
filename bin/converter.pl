#!/usr/bin/perl --

use strict;
use warnings;

use DBI;
use Data::Dumper;

our $mysql  = DBI->connect( 'DBI:mysql:database=testing',      'vegrev', 'password', { RaiseError => 1, AutoCommit => 1 } );
our $sqlite = DBI->connect( 'DBI:SQLite:dbname=main.sqlite3',  '',        '',        { RaiseError => 1, AutoCommit => 0 } );

#convert_users();
#convert_shoutbox();
#convert_thread();
#convert_messages();
add_default_taggroup();
add_default_tags();
convert_boards_to_tags();


sub add_default_taggroup {
    my @default_groups = ('Special Tags', 'Forum', 'Gallery', 'Administrative');

    foreach my $group (@default_groups) {
        my $sql = qq{
            INSERT INTO taggroup (title)
            VALUES (?)
        };

        $mysql->do($sql, undef, $group) or die $mysql->errstr;
    }
}


sub add_default_tags {
    my @default_tags = ('Sticky', 'Deleted', 'Locked');

    foreach my $tag (@default_tags) {
        my $sql = qq{
            INSERT INTO tag (title, url_slug, group_id)
            VALUES (?, ?, ?)
        };

        $mysql->do($sql, undef, ($tag, lc($tag), '1')) or die $mysql->errstr;
    }    
}


sub convert_boards_to_tags {
    my $sqlite_sth = $sqlite->prepare("SELECT * FROM boards");
    $sqlite_sth->execute();

    my $total = $sqlite->selectrow_array("SELECT COUNT(*) AS count FROM boards");

    print "CONVERTING BOARDS\n---------------\n\n";
    my $count = 0;
    while (my $row = $sqlite_sth->fetchrow_hashref) {

        my %mapping = (
            'url_slug'      => $row->{'board_id'},
            'title'         => $row->{'board_title'},
            'description'   => $row->{'board_description'},
        );

        if ($row->{'category_id'} eq 'forum') {
            $mapping{'group_id'} = '2';
        } elsif ($row->{'category_id'} eq 'gallery') {
            $mapping{'group_id'} = '3';
        } elsif ($row->{'category_id'} eq 'mods') {
            $mapping{'group_id'} = '4';
        } else {
            $mapping{'group_id'} = '2';
        }

        my @holders;
        while (my ($key, $value) = each %mapping) {
            if (!$value) {
                delete $mapping{$key};
                next;
            }
        }

        my $fields          = join(',', keys %mapping);
        my $placeholders    = join(',', map('?', keys %mapping));
        my @binds           = values %mapping;

        # Don't worry, no SQL injection here.
        my $sql = qq{
            INSERT INTO tag ($fields)
            VALUES ($placeholders)
        };

        $mysql->do($sql, undef, @binds) or die $mysql->errstr;

        $count++;
        print "DONE $count of $total\n";
    }

}


sub convert_messages {
    my $sqlite_sth = $sqlite->prepare("SELECT * FROM messages LEFT JOIN threads ON threads.thread_id = messages.thread_id ORDER BY message_id ASC");
    $sqlite_sth->execute();

    my $total = $sqlite->selectrow_array("SELECT COUNT(*) AS count FROM messages");

    print "CONVERTING MESSAGES\n-------------------\n\n";
    my $count = 0;

    my $mysql_sth = $mysql->prepare("SELECT id FROM thread WHERE start_date = FROM_UNIXTIME(?) LIMIT 1");
    while (my $row = $sqlite_sth->fetchrow_hashref) {
        $mysql_sth->execute($row->{'thread_id'});
        my $thread_id = $mysql_sth->fetchrow_arrayref();

        if (!$thread_id) { next; }

        my %mapping = (
            'id'                => $row->{'message_id'},
            'user_id'           => $row->{'user_id'},
            'thread_id'         => @{$thread_id},
            'ip_address'        => $row->{'message_ip'},
            'timestamp'         => $row->{'message_time'},
            'edited_timestamp'  => $row->{'edited_time'},
            'editor_id'         => $row->{'editor_id'},
            'deleted'           => $row->{'message_deleted'},
            'body'              => $row->{'message_body'},
        );

        my @holders;
        while (my ($key, $value) = each %mapping) {
            if (!$value) {
                delete $mapping{$key};
                next;
            }

            if ($key ~~ @{['timestamp','edited_time']}) {
                push(@holders, 'FROM_UNIXTIME(?)');
            } elsif ($key ~~ @{['ip_address']}) {
                if ($value =~ m/ /) {
                    my @tmp = split(/ /, $value);
                    $mapping{$key} = $tmp[$#tmp];
                } elsif ($value =~ m/,/) {
                    my @tmp = split(/,/, $value);
                    $mapping{$key} = $tmp[$#tmp];
                } elsif ($value =~ m/\|/) {
                    my @tmp = split(/\|/, $value);
                    $mapping{$key} = $tmp[$#tmp];
                }

                if ($value !~ /\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/) {
                    $mapping{$key} = '127.0.0.3';
                }

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
            INSERT INTO message ($fields)
            VALUES ($placeholders)
        };

        $mysql->do($sql, undef, @binds) or die $mysql->errstr;

        $count++;
        print "DONE $count of $total\n";
    }
}


sub convert_thread {
    my $sqlite_sth = $sqlite->prepare("SELECT * FROM threads ORDER BY thread_id ASC");
    $sqlite_sth->execute();

    my $total = $sqlite->selectrow_array("SELECT COUNT(*) AS count FROM threads");

    print "CONVERTING THREADS\n------------------\n\n";
    my $count = 0;
    while (my $row = $sqlite_sth->fetchrow_hashref) {
        my %mapping = (
            #'id'                   # Now using auto increment ID's
            'subject'               => $row->{'thread_subject'},
            'url_slug'              => $row->{'thread_subject'},
            'icon'                  => $row->{'thread_icon'},
            'start_date'            => $row->{'thread_id'},
            'last_updated'          => $row->{'thread_last_message_time'},
            'started_by_user_id'    => $row->{'thread_starter_id'},
            'latest_post_user_id'   => $row->{'thread_last_user_id'},
            'first_message_id'      => $row->{'thread_first_message_id'},
        );

        my @holders;
        while (my ($key, $value) = each %mapping) {
            if (!$value) {
                delete $mapping{$key};
                next;
            }

            if ($key ~~ @{['start_date', 'last_updated']}) {
                push(@holders, 'FROM_UNIXTIME(?)');
            } elsif ($key ~~ @{['url_slug']}) {
                my $new_value = lc($value);
                $new_value =~ s/[^\w\s]//g;
                $new_value =~ s/^\s+//g;
                $new_value =~ s/\s+$//g;
                $new_value =~ s/\s+/\-/g;
                $new_value =~ s/\_+/\-/g;

                if (!$new_value) { $new_value = 'no-subject'; }

                $mapping{$key} = $new_value;
                push(@holders, '?');
            } else {
                push(@holders, '?');
            }
        }

        my $fields          = join(',', keys %mapping);
        my $placeholders    = join(',', @holders);
        my @binds           = values %mapping;

        # Don't worry, no SQL injection here.
        my $sql = qq{
            INSERT INTO thread ($fields)
            VALUES ($placeholders)
        };

        $mysql->do($sql, undef, @binds) or die $mysql->errstr;

        $count++;
        print "DONE $count of $total\n";
    }
}


sub convert_shoutbox {
    my $sqlite_sth = $sqlite->prepare("SELECT * FROM shoutbox");
    $sqlite_sth->execute();

    my $total = $sqlite->selectrow_array("SELECT COUNT(*) AS count FROM shoutbox");

    print "CONVERTING SHOUTBOX\n-------------------\n\n";
    my $count = 0;
    while (my $row = $sqlite_sth->fetchrow_hashref) {
        my %mapping = (
            'id'            => $row->{'shout_id'},
            'user_id'       => $row->{'user_id'},
            'ip_address'    => $row->{'shout_ip_address'},
            'time'          => $row->{'shout_time'},
            'deleted'       => $row->{'shout_deleted'},
            'body'          => $row->{'shout_body'},
        );

        my @holders;
        while (my ($key, $value) = each %mapping) {
            if (!$value) {
                delete $mapping{$key};
                next;
            }

            if ($key ~~ @{['time']}) {
                push(@holders, 'FROM_UNIXTIME(?)');
            } elsif ($key ~~ @{['ip_address']}) {
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
            INSERT INTO shoutbox ($fields)
            VALUES ($placeholders)
        };

        $mysql->do($sql, undef, @binds) or die $mysql->errstr;

        $count++;
        print "DONE $count of $total\n";
    }
}


sub convert_users {
    my $sqlite_sth = $sqlite->prepare("SELECT * FROM users");
    $sqlite_sth->execute();

    my $total = $sqlite->selectrow_array("SELECT COUNT(*) AS count FROM users");

    print "CONVERTING USERS\n----------------\n\n";
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

        $mysql->do($sql, undef, @binds) or die $mysql->errstr;

        $count++;
        print "DONE $count of $total\n";
    }
}



1;