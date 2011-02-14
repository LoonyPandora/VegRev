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

    template 'forum', {
        page_title      => 'The Forum',
        recent_threads  => \@recent_threads,
    };
};



true;
