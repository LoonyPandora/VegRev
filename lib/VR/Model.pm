package VR::Model;

use common::sense;
use Dancer ':syntax';
use Dancer::Plugin::Database;

use Data::Dumper;
use base 'Exporter';
use vars '@EXPORT_OK';

@EXPORT_OK = qw(pagination users_online fill_session);


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

    my $pages_menu = q{<select>};
    for (1 .. $total_pages) {
        if ($current_page == $_) {
            $pages_menu .= qq{\n    <option value="$_" selected="selected">$_ of $total_pages</option>};
        } else {
            $pages_menu .= qq{\n    <option value="$_">$_</option>};
        }
    }    
    $pages_menu .= qq{\n</select>};

    my $next_prev_block = q{<ul id="nextprev">};    
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