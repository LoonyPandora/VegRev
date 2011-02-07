package VR::Route::Thread;

use common::sense;
use Dancer ':syntax';
use Dancer::Plugin::Database;

prefix '/thread';


# You need to specify a thread, otherwise redirect to front page
get '/' => sub {
    redirect '/';
};


# Matches /thread/:thread_id-:url_slug/:page - URL slug is acutally ignored.
get qr{/(\d+)\-?[\w\-]+?/?(\d+)?/?$} => sub {
    my ($thread_id, $page) = splat;

    $page //= 1;

    my $per_page  = 20;
    my $offset    = ($per_page * $page) - $per_page;

    my $messages = database->prepare(
        q{
            SELECT body, user_name, display_name, usertext, signature, avatar, UNIX_TIMESTAMP(timestamp) AS timestamp, INET_NTOA(ip_address) AS ip_address
            FROM message
            LEFT JOIN user ON user.id = user_id
            WHERE thread_id = ?
            AND message.deleted = '0'
            LIMIT ?, ?
        }
    );

    my $meta = database->prepare(
        q{
            SELECT subject, (SELECT count(*) FROM message WHERE message.thread_id = thread.id) AS replies
            FROM thread
            WHERE id = ?
            LIMIT 1
        }
    );

    $messages->execute($thread_id, $offset, $per_page);
    $meta->execute($thread_id);
    
    my $meta_info = $meta->fetchrow_hashref();


    template 'thread', {
        page_title  => $meta_info->{'subject'},
        messages    => $messages->fetchall_arrayref({}),
        thread_meta => $meta_info,
    };
};



true;
