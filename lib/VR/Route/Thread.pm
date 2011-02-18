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

    my $meta_info   = $meta->fetchrow_hashref();
    my $total_pages = ceil($meta_info->{'replies'} / $per_page);

    # Sanity Check the page
    $page = 1 unless $page;
    $page = $total_pages if $page > $total_pages;

    my $offset = ($per_page * $page) - $per_page;

    my $messages = database->prepare(
        q{
            SELECT message.id, message.body, user.user_name, user.display_name, user.usertext, user.signature, user.avatar, UNIX_TIMESTAMP(message.timestamp) AS message_timestamp, INET_NTOA(message.ip_address) AS message_ip_address
            FROM message
            LEFT JOIN USER ON user.id = user_id
            WHERE message.thread_id = ?
            AND message.deleted != 1
            LIMIT ?, ?
        }
    );
    $messages->execute($thread_id, $offset, $per_page);

    my $all_messages = $messages->fetchall_arrayref({});
    my @ids = map { $_->{'id'} } @{$all_messages};
     
    my $quote = database->prepare(q{
        SELECT message_id, message_id_quoted, quote.body, UNIX_TIMESTAMP(message.timestamp) AS message_timestamp, user.user_name, user.display_name, user.avatar, user.usertext
        FROM quote
        LEFT JOIN message ON message_id_quoted = message.id
        LEFT JOIN user ON message.user_id = user.id
        WHERE message_id IN (} . join(',', map('?', @ids)) . q{)
    });
    
    $quote->execute(@ids);

    write_read_receipt($thread_id, session('user_id'));

    template 'thread', {
        page_title  => $meta_info->{'subject'},
        messages    => $all_messages,
        quotes      => $quote->fetchall_hashref([ qw(message_id message_id_quoted) ]),
        thread_meta => $meta_info,
        pagination  => pagination($page, $total_pages),
    };
};


sub write_read_receipt {
    my ($thread_id, $user_id) = @_;

    my $sth = database->prepare(q{
        INSERT INTO thread_read_receipt (thread_id, user_id)
        VALUES (?, ?)
        ON DUPLICATE KEY UPDATE timestamp = NOW();
     });
    
     $sth->execute($thread_id, $user_id);
}



true;
