package VR::Route::Photo;

use common::sense;
use Dancer ':syntax';
use Dancer::Plugin::Database;

use Data::Dumper;
use POSIX qw/ceil/;

use VR::Model qw/pagination write_thread_receipt read_thread_receipt get_thread_meta get_messages/;

prefix '/photo';


# You need to specify a thread, otherwise redirect to front page
get '/' => sub {
    redirect '/';
};


# Matches /photos/:photo_id-:url_slug/:page - URL slug is acutally ignored.
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

    # Need to write before we read so we ourselves appear in the readers list
    write_thread_receipt($thread_id, session('user_id'));
    my $readers = read_thread_receipt($thread_id);

    $meta_info->{'reading'}      = $readers->fetchall_hashref('id');
    $meta_info->{'content_kind'} = 'Photo';

    template 'photo', {
        page_title   => $meta_info->{'subject'},
        messages     => $all_messages,
        thread_meta  => $meta_info,
        pagination   => pagination($page, $total_pages, "/thread/$thread_id-" . $meta_info->{'url_slug'}),
        actions      => [
            { 'title' => 'Reply', 'url' => '/post_reply', icon => '/img/icons/star_16.png' },
        ]
    };
};



true;
