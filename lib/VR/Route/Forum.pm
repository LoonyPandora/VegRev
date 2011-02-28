package VR::Route::Forum;

use common::sense;
use Dancer ':syntax';
use Dancer::Plugin::Database;
use Data::Dumper;

use POSIX qw/ceil/;

use VR::Model qw/pagination/;

prefix '/forum';


# There is always a page variable passed to this, as it is a forwarded route from '/'
get qr{/(\d+)/?$} => sub {
    my ($page) = splat;

    my $per_page  = 30;
    my $offset    = ($per_page * $page) - $per_page;

    my $meta        = get_meta();
    my $meta_info   = $meta->fetchrow_hashref();
    my $total_pages = ceil($meta_info->{'total_threads'} / $per_page);

    # Sanity Check the page
    $page = 1 unless $page;
    $page = $total_pages if $page > $total_pages;

    my $offset = ($per_page * $page) - $per_page;

    my $recent_threads = get_threads($offset, $per_page);

    template 'forum', {
        page_title      => 'The Forum',
        recent_threads  => $recent_threads,
        pagination      => pagination($page, $total_pages, '/forum'),
    };
};


# This is tags
get qr{/([\w-]+)/?(\d+)?/?$} => sub {
    my ($tag, $page) = splat;

    my @tags = split(/-/, $tag);

    my $per_page  = 30;
    my $offset    = ($per_page * $page) - $per_page;

    my $meta        = get_meta();
    my $meta_info   = $meta->fetchrow_hashref();
    my $total_pages = ceil($meta_info->{'total_threads'} / $per_page);

    # Sanity Check the page
    $page = 1 unless $page;
    $page = $total_pages if $page > $total_pages;

    my $offset = ($per_page * $page) - $per_page;

    my $recent_threads = get_threads($offset, $per_page);

    template 'forum', {
        page_title      => 'Tag Mode',
        pagination      => pagination('1', '999', '/forum'),
    };
};





sub get_threads {
    my ($offset, $per_page, $tag_ref) = @_;

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
    my $recent = $sth->fetchall_hashref('id');

    my @thread_ids = keys %{$recent};

    my $tag_sth = database->prepare(
        qq{
            SELECT thread_id, tag.title FROM tagged_thread
            LEFT JOIN tag ON tagged_thread.tag_id = tag.id
            WHERE thread_id IN (} . join(',', map('?', @thread_ids)) . q{)
        }
    );

    $tag_sth->execute(@thread_ids);
    foreach my $row (@{$tag_sth->fetchall_arrayref({})}) {
        push (@{$recent->{$row->{'thread_id'}}->{'tags'}}, $row->{'title'});
    }

    my @recent_threads;
    foreach my $asdf ( sort { $a <=> $b } keys %{$recent} ) {
        push (@recent_threads, $recent->{$asdf});
    }

    return \@recent_threads;
}



sub get_meta {
    my ($page, $tag_ref) = @_;

# TODO FIXME. There is a discrepancy between total threads from this count, and acutal visible threads.

    my $meta = database->prepare(
        q{
            SELECT COUNT(thread_id) AS total_threads
            FROM tagged_thread
            WHERE tag_id IN (
                SELECT id
                FROM tag
                WHERE tag_id != 2
            )
        }
    );

# REmoved browse by tag for now
# WHERE url_slug IN (} . join(',', map('?', @{$tag_ref})) . q{)
# $meta->execute(@{$tag_ref});

    $meta->execute();

    return $meta;
}


true;
