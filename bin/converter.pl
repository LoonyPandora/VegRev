#!/usr/bin/perl --

use strict;
use warnings;

use DBI;
use Data::Dumper;

our $mysql  = DBI->connect( 'DBI:mysql:database=testing',      'vegrev', 'password', { RaiseError => 0, AutoCommit => 1 } );
our $sqlite = DBI->connect( 'DBI:SQLite:dbname=main.sqlite3',  '',        '',        { RaiseError => 1, AutoCommit => 0 } );

our %boards_to_tags = (
    'literature'       => '4',
    'media'            => '5',
    'rants'            => '6',
    'faq'              => '7',
    'talk'             => '8',
    'spam'             => '9',
    'private'          => '10',
    'news'             => '11',
    'megazine_letters' => '12',
    'teletext'         => '13',
    'art'              => '14',
    'avatars'          => '15',
    'meets'            => '16',
    'members'          => '17',
    'random'           => '18',
    'mods_only'        => '19',
    'temp_board'       => '20',
    'archive'          => '21',
    'yahoo'            => '22',
);


convert_users();
convert_shoutbox();

add_default_taggroup();
add_default_tags();

convert_boards_to_tags();
convert_thread();
convert_messages();

convert_pm();

convert_poll();

convert_to_quotes();



sub convert_to_quotes {
    my $mysql_sth = $mysql->prepare("SELECT id, body FROM message WHERE body LIKE '%[quote=%'");
    $mysql_sth->execute();

    # Quote formats: 
    # [quote="lmc|Cradle Days|1280332254|833281|1292585028"]     <--- Last is timestamp of message being quoted.
    # [quote=Hairey_Jezza  link=1017272120/0#5 date=1017885809]  <--- date is the field we want

    my $total = $mysql->selectrow_array("SELECT COUNT(*) FROM message WHERE body LIKE '%[quote=%'");

    print "CONVERTING QUOTES\n---------------\n\n";
    my $count = 0;
    while (my $message = $mysql_sth->fetchrow_hashref) {

        my @matches = ($message->{'body'} =~ m{\[quote=(.+?)\]}g);

        foreach my $match (@matches) {
            
            if ($match =~ m{\|}) {
                my (undef, undef, undef, $message_id, undef) = split('|', $match);
            
                my $quote_sth = $mysql->prepare("SELECT id, body FROM message WHERE id = ?");
                $quote_sth->execute($message_id);
                my $quote_message = $quote_sth->fetchrow_hashref();

                # TODO, add proper error checking.
                if (!$quote_message) { next; }

                my $quoted_body = strip_bbcode($quote_message->{'body'});
                        
                my $sql = q{
                    INSERT INTO quote (message_id, message_id_quoted, body)
                    VALUES (?, ?, ?)
                };

                # TODO: Make sure we clean the quoted body of all bbcode.
                $mysql->do($sql, undef, ($message->{'id'}, $quote_message->{'id'}, $quoted_body)) or die $mysql->errstr;

            } elsif ($match =~ m{date=(\d+)}) {

                my $timestamp = $1;

                my $quote_sth = $mysql->prepare("SELECT id, body FROM message WHERE timestamp = FROM_UNIXTIME(?)");
                $quote_sth->execute($timestamp);
                my $quote_message = $quote_sth->fetchrow_hashref();

                # TODO, add proper error checking.
                if (!$quote_message) { next; }

                my $quoted_body = strip_bbcode($quote_message->{'body'});

                my $sql = q{
                    INSERT INTO quote (message_id, message_id_quoted, body)
                    VALUES (?, ?, ?)
                };

                # TODO: Make sure we clean the quoted body of all bbcode.
                $mysql->do($sql, undef, ($message->{'id'}, $quote_message->{'id'}, $quoted_body)) or die $mysql->errstr;
                
            }

            $count++;
            print "DONE $count of $total\n";
        }
    }
}


sub convert_poll {
    my $sqlite_sth = $sqlite->prepare("SELECT * FROM polls");
    $sqlite_sth->execute();
    
    my $total = $sqlite->selectrow_array("SELECT COUNT(*) AS count FROM polls");

    print "CONVERTING POLLS\n---------------\n\n";
    my $count = 0;

    my $mysql_sth = $mysql->prepare("SELECT id FROM thread WHERE start_date = FROM_UNIXTIME(?) LIMIT 1");
    while (my $row = $sqlite_sth->fetchrow_hashref) {
        $mysql_sth->execute($row->{'thread_id'});
        my $thread_id = $mysql_sth->fetchrow_arrayref();
    
        # Hardcore Data Munging!
        $mysql_sth->execute($row->{'thread_id'} + 1);
        my $thread_id_plus_one = $mysql_sth->fetchrow_arrayref();
        $mysql_sth->execute($row->{'thread_id'} + 2);
        my $thread_id_plus_two = $mysql_sth->fetchrow_arrayref();
        $mysql_sth->execute($row->{'thread_id'} - 1);
        my $thread_id_minus_one = $mysql_sth->fetchrow_arrayref();
        $mysql_sth->execute($row->{'thread_id'} - 2);
        my $thread_id_minus_two = $mysql_sth->fetchrow_arrayref();
    
        $mysql_sth->execute($row->{'poll_start_time'});
        my $start_time = $mysql_sth->fetchrow_arrayref();
        $mysql_sth->execute($row->{'poll_start_time'} + 1);
        my $start_time_plus_one = $mysql_sth->fetchrow_arrayref();
        $mysql_sth->execute($row->{'poll_start_time'} + 2);
        my $start_time_plus_two = $mysql_sth->fetchrow_arrayref();
        $mysql_sth->execute($row->{'poll_start_time'} - 1);
        my $start_time_minus_one = $mysql_sth->fetchrow_arrayref();
        $mysql_sth->execute($row->{'poll_start_time'} - 2);
        my $start_time_minus_two = $mysql_sth->fetchrow_arrayref();
    
        $thread_id //= $start_time;
        $thread_id //= $thread_id_plus_one;
        $thread_id //= $thread_id_plus_two;
        $thread_id //= $thread_id_minus_one;
        $thread_id //= $thread_id_minus_two;
        
        $thread_id //= $start_time_plus_one;
        $thread_id //= $start_time_plus_two;
        $thread_id //= $start_time_minus_one;
        $thread_id //= $start_time_minus_two;
    
        if (!$thread_id) { warn "skipping $row->{'thread_id'} - no corresponding thread"; $count++; next; }
    
        my %mapping = (
            'thread_id'  => @{$thread_id},
            'start_time' => $row->{'poll_start_time'},
            'question'   => $row->{'question'},
            'multi_vote' => $row->{'multi'},
            'locked'     => $row->{'poll_locked'},
            'user_id'    => $row->{'user_id'},
        );
    
        my @holders;
        while (my ($key, $value) = each %mapping) {
            if (!$value) {
                delete $mapping{$key};
                next;
            }
    
            if ($key eq 'start_time') {
                push(@holders, 'FROM_UNIXTIME(?)');
            } else {
                push(@holders, '?');
            }
        }
    
        my $fields          = join(',', keys %mapping);
        my $placeholders    = join(',', @holders);
        my @binds           = values %mapping;
    
        # Don't worry, no SQL injection here.
        my $sql = qq{
            INSERT INTO poll ($fields)
            VALUES ($placeholders)
        };
    
        $mysql->do($sql, undef, @binds) or die $mysql->errstr;
    
        my $poll_option_sth = $sqlite->prepare("SELECT * FROM poll_options WHERE thread_id = ?");
        $poll_option_sth->execute($row->{'thread_id'});
    
        while (my $option = $poll_option_sth->fetchrow_hashref) {
            $mysql->do(q{
                INSERT INTO poll_option (id, text, poll_id)
                VALUES (?, ?, ?)},
                undef,
                ($option->{'poll_option_id'}, $option->{'poll_option'}, @{$thread_id})) or die $mysql->errstr;
        }
    
        $count++;
        print "DONE $count of $total\n";
    }

    my $poll_vote_sth = $sqlite->prepare("SELECT * FROM poll_votes");
    $poll_vote_sth->execute();

    while (my $vote = $poll_vote_sth->fetchrow_hashref) {
        # Use the thread_id for a timestamp - we never recorded vote time before...
        # Also skip if that option doesn't exist - we skip them up above, let this just fail.
        # We get junk errors, but this is a one shot script, so screw it.
        $mysql->do(q{
            INSERT INTO poll_vote (user_id, option_id, ip_address, timestamp)
            VALUES (?, ?, INET_ATON(?), FROM_UNIXTIME(?))},
            undef,
            ($vote->{'user_id'}, $vote->{'poll_option_id'}, $vote->{'poll_ip_address'}, $vote->{'thread_id'})
        ) or next;
    }

}


sub convert_pm {
    my $sqlite_sth = $sqlite->prepare("SELECT * FROM pm_messages ORDER BY pm_post_time ASC");
    $sqlite_sth->execute();
    
    my $total = $sqlite->selectrow_array("SELECT COUNT(*) AS count FROM pm_messages");

    print "CONVERTING PRIVATE MESSAGES\n---------------\n\n";
    my $count = 0;
    while (my $row = $sqlite_sth->fetchrow_hashref) {
        my %mapping = (
            'ip_address' => $row->{'pm_ip'},
            'timestamp'  => $row->{'pm_post_time'},
            'body'       => $row->{'pm_body'},
            'sent_from'  => $row->{'pm_sender_id'},
            'sent_to'    => $row->{'pm_receiver_id'},
        );

        my @holders;
        while (my ($key, $value) = each %mapping) {
            if (!$value) {
                delete $mapping{$key};
                next;
            }

            if ($key eq 'timestamp') {
                push(@holders, 'FROM_UNIXTIME(?)');
            } elsif ($key eq 'ip_address') {
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
            INSERT INTO mail ($fields)
            VALUES ($placeholders)
        };

        $mysql->do($sql, undef, @binds) or die $mysql->errstr;

        $count++;
        print "DONE $count of $total\n";
    }
}


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

        if ($row->{'attachment'}) {
            $mysql->do(q{
                    INSERT INTO attachment (message_id, original_name)
                    VALUES (?, ?)
                }, undef, ($row->{'message_id'}, $row->{'attachment'})
            ) or die $mysql->errstr;
        }

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
        my $thread_id = $mysql->{'mysql_insertid'};

        my $tag_sql = qq{
            INSERT INTO tagged_thread (tag_id, thread_id)
            VALUES (?, ?)
        };

        $mysql->do($tag_sql, undef, ($boards_to_tags{$row->{'board_id'}}, $thread_id)) or die $mysql->errstr;

        if ($row->{'thread_deleted'}) {
            my $deleted_sql = qq{
                INSERT INTO tagged_thread (tag_id, thread_id)
                VALUES (?, ?)
            };

            $mysql->do($deleted_sql, undef, ('2', $thread_id)) or die $mysql->errstr;
        } elsif ($row->{'thread_locked'}) {
            my $locked_sql = qq{
                INSERT INTO tagged_thread (tag_id, thread_id)
                VALUES (?, ?)
            };

            $mysql->do($locked_sql, undef, ('3', $thread_id)) or die $mysql->errstr;   
        }

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



sub strip_bbcode {
    my ($string) = @_;

    my @delete_content      = qw(img quote youtube flash);
    my @remove_formatting   = qw(b i u s glb move tt left center centre right sub sup spoiler edit);

    foreach my $tag (@delete_content) {
        $string =~ s{\[$tag\](.*?)\[/$tag\]}{}isg;
        $string =~ s{\[$tag\]}{}isg;
        $string =~ s{\[/$tag\]}{}isg;
    }

    foreach my $tag (@remove_formatting) {
        $string =~ s{\[$tag\](.*?)\[/$tag\]}{$1}isg;
        $string =~ s{\[$tag\]}{}isg;
        $string =~ s{\[/$tag\]}{}isg;
    }

    $string =~ s~\[color=([A-Za-z0-9# ]+)\](.+?)\[/color\]~$2~isg;
    $string =~ s~\[font=([A-Za-z0-9'" ]+)\](.+?)\[/font\]~$2~isg;
    $string =~ s~\[size=([6-9]|[1-7][0-9])?\](.*?)\[/size\]~$2~isg;
    $string =~ s~\[font="(.*?)"\](.*?)\[/font\]~$2~isg;
    $string =~ s~\[url=(http[s]?://)?(.+?)\](.+?)\[/url\]~http://$2~isg;
    $string =~ s~\[url\](http[s]?://)?(.+?)\[/url\]~http://$2~isg;

    $string =~ s{\[quote=[^\]]+\](.+?)\[/quote\]}{}isg;

    $string =~ s{\[quote=[^\]]+\]}{}isg;
    $string =~ s{\[/quote\]}{}isg;

    $string =~ s~\[br\]~\n~ig;

    $string =~ s/^\s+//ig;
    $string =~ s/\s+$//ig;
    $string =~ s/^\n+//ig;
    $string =~ s/\n+$//ig;

    $string =~ s/\n{2,}/\n\n/ig;

    return $string;
}



1;