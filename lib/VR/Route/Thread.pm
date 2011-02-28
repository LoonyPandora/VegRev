package VR::Route::Thread;

use common::sense;
use Dancer ':syntax';
use Dancer::Plugin::Database;
use Data::Dumper;
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

    my ($meta, $tags)       = get_meta($thread_id);
    my $meta_info           = $meta->fetchrow_hashref();
    my $readers             = read_thread_receipt($thread_id);
    $meta_info->{'tagged'}  = $tags->fetchall_arrayref();
    $meta_info->{'reading'} = $readers->fetchall_hashref('id');

    my $total_pages   = ceil($meta_info->{'replies'} / $per_page);

    # Sanity Check the page
    $page = 1 unless $page;
    $page = $total_pages if $page > $total_pages;

    my $offset = ($per_page * $page) - $per_page;

    my $messages = get_messages($thread_id, $offset, $per_page);

    my $all_messages = $messages->fetchall_arrayref({});
    my @ids = map { $_->{'id'} } @{$all_messages};

    my $quote = get_quotes(\@ids);

    write_read_receipt($thread_id, session('user_id'));

    template 'thread', {
        page_title   => $meta_info->{'subject'},
        messages     => $all_messages,
        quotes       => $quote->fetchall_hashref([ qw(message_id message_id_quoted) ]),
        thread_meta  => $meta_info,
        pagination   => pagination($page, $total_pages, "/thread/$thread_id-" . $meta_info->{'url_slug'}),
        actions      => [
            { 'title' => 'Reply', 'url' => '/post_reply', icon => '/img/icons/star_16.png' },
        ]
    };
};



## Data Getters ##


sub get_quotes {
    my ($id_ref) = @_;

    my $quote = database->prepare(q{
        SELECT message_id, message_id_quoted, quote.body, UNIX_TIMESTAMP(message.timestamp) AS message_timestamp, user.user_name, user.display_name, user.avatar, user.usertext
        FROM quote
        LEFT JOIN message ON message_id_quoted = message.id
        LEFT JOIN user ON message.user_id = user.id
        WHERE message_id IN (} . join(',', map('?', @{$id_ref})) . q{)
    });

    $quote->execute(@{$id_ref});
    return $quote;
}


sub get_meta {
    my ($thread_id) = @_;

    my $meta = database->prepare(
        q{
            SELECT subject, url_slug, (
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


sub get_messages {
    my ($thread_id, $offset, $limit) = @_;

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
    $messages->execute($thread_id, $offset, $limit);

    return $messages;
}


sub write_read_receipt {
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



true;
