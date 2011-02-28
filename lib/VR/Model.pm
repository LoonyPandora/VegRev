package VR::Model;

use common::sense;
use Dancer ':syntax';
use Dancer::Plugin::Database;

use Data::Dumper;
use base 'Exporter';
use vars '@EXPORT_OK';

@EXPORT_OK = qw(pagination users_online fill_session write_thread_receipt read_thread_receipt get_thread_meta get_messages);


# Loads the current viewer, and places their pertinent info into their session
sub fill_session {
    my ($user_id) = @_;

    my $user = database->prepare(q{
        SELECT id AS user_id, user_name, display_name, stealth_login, template, language, avatar, usertext, gmt_offset
        FROM user
        WHERE user.id = ?
        LIMIT 1
    });

    $user->execute($user_id);

    my $user_data = $user->fetchrow_hashref();

    while (my ($key, $value) = each %{$user_data}) {
        session($key => $value);
    }
}

sub get_messages {
    my ($thread_id, $offset, $limit) = @_;

    my $messages = database->prepare(
        q{
            SELECT message.id, message.body, user.user_name, user.display_name, user.usertext, user.signature, user.avatar, UNIX_TIMESTAMP(message.timestamp) AS message_timestamp, INET_NTOA(message.ip_address) AS message_ip_address, attachment.id AS attachment_id, original_name
            FROM message
            LEFT JOIN user ON user.id = user_id
            LEFT JOIN attachment ON attachment.message_id = message.id
            WHERE message.thread_id = ?
            AND message.deleted != 1
            LIMIT ?, ?
        }
    );
    $messages->execute($thread_id, $offset, $limit);

    return $messages;
}


sub write_thread_receipt {
    my ($thread_id, $user_id) = @_;

    my $sth = database->prepare(q{
        INSERT INTO thread_read_receipt (thread_id, user_id)
        VALUES (?, ?)
        ON DUPLICATE KEY UPDATE timestamp = NOW()
    });

    $sth->execute($thread_id, $user_id) or die "couldn't write_read_receipt";

}


sub read_thread_receipt {
    my ($thread_id) = @_;

    my $sth = database->prepare(
        q{
            SELECT user.user_name, user.id, user.display_name
            FROM thread_read_receipt
            LEFT JOIN user ON user.id = user_id
            WHERE thread_id = ?
            AND TIMESTAMP > DATE_SUB(NOW(), INTERVAL 10 MINUTE)
        }
    );

    $sth->execute($thread_id);

    return $sth;
}


sub get_thread_meta {
    my ($thread_id) = @_;

    my $meta = database->prepare(
        q{
            SELECT subject, url_slug, UNIX_TIMESTAMP(start_date) AS start_date, UNIX_TIMESTAMP(last_updated) AS last_updated, (
                SELECT count(id)
                FROM message
                WHERE message.thread_id = thread.id
                AND message.deleted != 1
            ) AS replies
            FROM thread
            WHERE thread.id = ?
            LIMIT 1
        }
    );
    $meta->execute($thread_id);

    my $tags = database->prepare(
        q{
            SELECT tag.title
            FROM tagged_thread
            LEFT JOIN tag ON tagged_thread.tag_id = tag.id
            WHERE tagged_thread.thread_id = ?
        }
    );
    $tags->execute($thread_id);

    return ($meta, $tags);
}




sub users_online {
    my ($minutes) = @_;

    my $online = database->prepare(q{
        SELECT session_data
        FROM session
        WHERE timestamp > DATE_SUB(NOW(), INTERVAL ? MINUTE)
    });

    $online->execute($minutes);
    my $all_session_data = $online->fetchall_arrayref({});

    my @tmp = map { Dancer::Serializer::JSON::from_json($_->{'session_data'}) } @{$all_session_data};
    my @user_id_array = map { $_->{'user_id'} } @tmp;

    # If there are no online users, we return empty arrayref.
    my @empty;
    return \@empty unless defined scalar @user_id_array;

    my $users = database->prepare(q{
        SELECT user_name, display_name, avatar, usertext
        FROM user
        WHERE id IN (} . join(',', map('?', @user_id_array)) . q{)
    });

    $users->execute(@user_id_array);

    return $users->fetchall_arrayref({});
}



# I shouldn't generate HTML here, that's a templates job.
# But you shouldn't have logic like this in a template
# I want to keep templates simple, so this is the lesser evil.
sub pagination {
    my ($current_page, $total_pages, $base_url) = @_;

    my $pages_menu = q{<div id="page_selector_block"><select>};
    for (1 .. $total_pages) {
        if ($current_page == $_) {
            $pages_menu .= qq{<option value="$_" selected="selected">$_ of $total_pages</option>};
        } else {
            $pages_menu .= qq{<option value="$_">$_</option>};
        }
    }    
    $pages_menu .= qq{\n</select></div};

    if ($total_pages == 1) {
        $pages_menu = '';
    }

    my $next_prev_block = q{<ul>};    
    if ($total_pages == 1) {
        $next_prev_block .= qq{\n    <li>One Page</li>};
    } elsif ($current_page == 1) {
        $next_prev_block .= qq{\n    <li><a href="$base_url/} . ($current_page + 1) . q{">Next Page &#x2192;</a></li>};
    } elsif ($current_page < $total_pages) {
        $next_prev_block .= qq{\n    <li><a href="$base_url/} . ($current_page - 1) . q{">&#x2190; Prev Page</a></li>};
        $next_prev_block .= qq{\n    <li><a href="$base_url/} . ($current_page + 1) . q{">Next Page &#x2192;</a></li>};
    } elsif ($current_page == $total_pages) {
        $next_prev_block .= qq{\n    <li><a href="$base_url/} . ($current_page - 1) . q{">&#x2190; Prev Page</a></li>};
    }
    $next_prev_block .= qq{\n</ul>};

    return {
        'pages_menu'        => $pages_menu,
        'next_prev_block'   => $next_prev_block,
    };
}



1;