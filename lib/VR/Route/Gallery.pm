package VR::Route::Gallery;

use common::sense;
use Dancer ':syntax';
use Dancer::Plugin::Database;

prefix '/gallery';


# Gallery shows recent posts, and all albums
get '/' => sub {
    my ($page) = splat;

    my $per_page  = 18;
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
    my $recent = $sth->fetchall_hashref('id');

    my @thread_ids   = keys %{$recent};
    my $placeholders = join(',', map('?', @thread_ids));

    my $tag_sth = database->prepare(
        qq{
            SELECT thread_id, tag.title FROM tagged_thread
            LEFT JOIN tag ON tagged_thread.tag_id = tag.id
            WHERE thread_id IN ($placeholders)
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

    template 'gallery', {
        page_title      => 'The Forum',
        recent_threads  => \@recent_threads,
    };
};


# Matches tags - multiple tags are separated by a + - the R of CRUD
# splat keyword doesn't seem to work, so have to use it via params.
# This regex matches tags and pages too. A bit fugly, but DRY.
get qr{/([\w+\-]+)/?(\d+)?/?$} => sub {
    my (@tags)  = split(/\+/, params->{splat}[0]);
    my $page    = params->{splat}[1];

    template 'gallery';
};


# POST'ing to this url gives us the C-UD of CRUD.
# In practical terms, it's used when creating a new thread and nothing else.
post qr{/([\w+\-]+)/?(\d+)?/?$} => sub {
    my (@tags)  = split(/\+/, params->{splat}[0]);
    my $page    = params->{splat}[1];

    redirect '/';
};


true;
