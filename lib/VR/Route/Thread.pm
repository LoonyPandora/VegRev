package VR::Route::Thread;

use common::sense;
use Dancer ':syntax';
use Dancer::Plugin::Database;
use Data::Dumper;
use POSIX qw/ceil/;

use VR::Model qw/pagination write_thread_receipt read_thread_receipt get_thread_meta get_messages load_poll/;


prefix '/thread';


# You need to specify a thread, otherwise redirect to front page
get '/' => sub {
    redirect '/';
};


# Matches /thread/:thread_id-:url_slug/:page - URL slug is acutally ignored.
get qr{/(\d+)\-?[\w\-]+?/?(\d+)?/?$} => sub {
    my ($thread_id, $page) = splat;

    my $per_page  = 20;

    my ($meta, $tags)       = get_thread_meta($thread_id);
    my $meta_info           = $meta->fetchrow_hashref();
    $meta_info->{'tagged'}  = $tags->fetchall_arrayref();

    my $total_pages   = ceil($meta_info->{'replies'} / $per_page);

    # Sanity Check the page
    $page = 1 unless $page;
    $page = $total_pages if $page > $total_pages;

    my $offset = ($per_page * $page) - $per_page;

    my $messages = get_messages($thread_id, $offset, $per_page);

    my $all_messages = $messages->fetchall_arrayref({});
    my @ids = map { $_->{'id'} } @{$all_messages};

    my $quote = get_quotes(\@ids);
    my ($poll_meta, $poll_options, $poll_votes) = load_poll($thread_id);


    # Need to write before we read so we ourselves appear in the readers list
    write_thread_receipt($thread_id, session('user_id'));
    my $readers = read_thread_receipt($thread_id);

    $meta_info->{'reading'}      = $readers->fetchall_hashref('id');
    $meta_info->{'content_kind'} = 'Thread';

    template 'thread', {
        page_css     => 'thread',
        page_title   => $meta_info->{'subject'},
        messages     => $all_messages,
        quotes       => $quote->fetchall_hashref([ qw(message_id message_id_quoted) ]),
        thread_meta  => $meta_info,
        poll         => {
            'has_poll'  => 1,
            'meta'      => $poll_meta->fetchrow_hashref(),
            'options'   => $poll_options->fetchall_hashref([ qw(id) ]),
            'votes'     => $poll_votes->fetchall_hashref([ qw(option_id user_id) ]),
        },
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




true;
