package VR::Route::Forum;

use common::sense;
use Dancer ':syntax';
use Dancer::Plugin::Database;

prefix '/forum';


# There is always a page variable passed to this, as it is a forwarded route from '/'
get qr{/(\d+)/?$} => sub {
    my ($page) = splat;

    my $per_page  = 30;
    my $offset    = ($per_page * $page) - $per_page;

    my $sth = database->prepare(
        q{
            SELECT thread.id, subject, url_slug, UNIX_TIMESTAMP(last_updated) AS last_updated, user_name, display_name, avatar, usertext,
                (SELECT count(*) FROM message WHERE message.thread_id = thread.id) AS replies
            FROM thread
            LEFT JOIN user ON latest_post_user_id = user.id
            ORDER BY last_updated DESC
            LIMIT ?, ?
        }
    );

    $sth->execute($offset, $per_page);

    template 'forum', {
        page_title      => 'The Forum',
        recent_threads  => $sth->fetchall_arrayref({}),
    };
};



true;
