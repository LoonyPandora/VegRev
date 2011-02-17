package VR::Route::Thread;

use common::sense;
use Dancer ':syntax';
use Dancer::Plugin::Database;

use POSIX qw/ceil/;

use VR::Model qw/pagination/;


prefix '/thread';


# You need to specify a thread, otherwise redirect to front page
get '/' => sub {
    redirect '/';
};


# Matches /thread/:thread_id-:url_slug/:page - URL slug is acutally ignored.
get qr{/(\d+)\-?[\w\-]+?/?(\d+)?/?$} => sub {
    my ($thread_id, $page) = splat;

    my $per_page  = 20;

    my $meta = database->prepare(
        q{
            SELECT subject, (
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
    
    my $meta_info = $meta->fetchrow_hashref();
    my $total_pages = ceil($meta_info->{'replies'} / $per_page);

    # Sanity Check the page
    $page = 1 unless $page;
    $page = $total_pages if $page > $total_pages;


    my $offset = ($per_page * $page) - $per_page;

    my $messages = database->prepare(
        q{
            SELECT body, user_name, display_name, usertext, signature, avatar, UNIX_TIMESTAMP(timestamp) AS timestamp, INET_NTOA(ip_address) AS ip_address
            FROM message
            LEFT JOIN user ON user.id = user_id
            WHERE thread_id = ?
            AND message.deleted != 1
            LIMIT ?, ?
        }
    );
    $messages->execute($thread_id, $offset, $per_page);

    template 'thread', {
        page_title  => $meta_info->{'subject'},
        messages    => $messages->fetchall_arrayref({}),
        thread_meta => $meta_info,
        pagination  => pagination($page, $total_pages),
    };
};



true;
