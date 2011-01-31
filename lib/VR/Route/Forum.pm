package VR::Route::Forum;

use common::sense;
use Dancer ':syntax';
use Dancer::Plugin::Database;

prefix '/forum';



get qr{/(\d+)/?$} => sub {
    my ($page) = splat;

    my $threads_per_page = 30;
    my $offset = ($threads_per_page * $page) - $threads_per_page;

    my $sth = database->prepare(
        q{
            SELECT thread.id, subject, url_slug, last_updated, user_name, display_name, avatar, usertext,
                (SELECT count(*) FROM message WHERE message.thread_id = thread.id) AS replies
            FROM thread
            LEFT JOIN user ON latest_post_user_id = user.id
            ORDER BY last_updated DESC
            LIMIT ?, ?
        }
    );

    $sth->execute($offset, $threads_per_page);
    my $recent_threads = $sth->fetchall_arrayref({});

    template 'forum', {
        recent_threads => $recent_threads,
    };
};



true;
