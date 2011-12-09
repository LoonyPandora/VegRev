package VegRev;

use v5.14;
use feature 'unicode_strings';
use utf8;
use common::sense;

use Dancer ':syntax';

use Time::HiRes qw/time/;

use Dancer::Plugin::Database;
use Data::Dumper;
use POSIX qw/ceil floor/;

use Carp;
use VegRev::User;
use VegRev::Forum;
use VegRev::Thread;
use VegRev::Inbox;
use VegRev::Chat;
use VegRev::Gallery;



use VegRev::ViewHelpers;


our $VERSION = '0.0.1';



# Loads the viewer, should get the user ID from the cookie
# Should also do some authentication here
hook 'before' => sub {
    my $viewer = VegRev::User->new({ id => 1 })->load_extra;
    $viewer->store_session;
};


hook 'before_template' => sub {
    my $tokens = shift;

    $tokens->{theme}        = session->{theme};
    $tokens->{my_user_name} = session->{user_name};

    # Add the Plack::Middleware::Assets used in all routes
#    $tokens->{base_css} = request->env->{'psgix.assets'}->[0];
#    $tokens->{base_js}  = request->env->{'psgix.assets'}->[1];

};




# Make sure we commit any open transactions. The entire request depends on it.
hook 'after' => sub {
  eval      { database->commit; };
  if ($@)   { die "Committing Transaction Failed: $@"; }
};



# Matches / and /:page
get qr{/(\d+)?/?$} => sub {
    my ($page) = splat;

    $page = $page // 1;
    my $per_page = 30;

    my $forum = VegRev::Forum::new_from_tag({
        tag    => undef,
        offset => ($page * $per_page) - $per_page,
        limit  => $per_page,
    });

    template 'forum', {
        forum    => $forum,
        template => 'forum',
    };
};



# Matches /thread/:thread_id-:url_slug/:page - URL slug is acutally ignored.
get qr{/thread/(\d+)\-?[\w\-]+?/?(\d+)?/?$} => sub {
    my ($thread_id, $page) = splat;

    $page = $page // 1;
    my $per_page = 30;

    my $thread = VegRev::Thread::new_from_id({
        id     => $thread_id,
        offset => ($page * $per_page) - $per_page,
        limit  => $per_page,
    });

    template 'thread', {
        template => 'thread',
        thread   => $thread
    };
};



# Matches /inbox
get qr{/inbox/?(\d+)?/?$} => sub {
    my ($page) = splat;

    $page = $page // 1;
    my $per_page = 50;

    my $inbox = VegRev::Inbox->new({
        user_id => session->{user_id},
        offset  => ($page * $per_page) - $per_page,
        limit   => $per_page,
    });

    template 'inbox', {
        inbox    => $inbox,
        template => 'inbox',
    };
};


# Matches /thread/:thread_id-:url_slug/:page - URL slug is acutally ignored.
get qr{/chat/(\d+)/?(\d+)?/?$} => sub {
    my ($chat_id, $page) = splat;

    $page = $page // 1;
    my $per_page = 50;

    my $thread = VegRev::Chat::new_from_id({
        chat_id => $chat_id,
        user_id => session->{user_id},
        offset  => ($page * $per_page) - $per_page,
        limit   => $per_page,
    });

    template 'chat', {
        template => 'thread',
        thread   => $thread
    };
};




# Matches /thread/:thread_id-:url_slug/:page - URL slug is acutally ignored.
get qr{/gallery/?(\d+)?/?$} => sub {
    my ($chat_id, $page) = splat;

    $page = $page // 1;
    my $per_page = 50;

    my $gallery = VegRev::Gallery::new_from_tag({
        offset  => ($page * $per_page) - $per_page,
        limit   => $per_page,
    });

    template 'gallery', {
        template => 'gallery',
        gallery  => $gallery
    };
};




# Redirects to a specific message when given a message id
get qr{/message/?(\d+)?/?$} => sub {
    my ($message_id) = splat;

    # Calculate how many messages are before it in the same thread
    my $thread_sth = database->prepare(q{
        SELECT COUNT(*) as count, thread_id, url_slug
        FROM message
        LEFT JOIN thread ON thread_id = thread.id
        WHERE thread_id = (SELECT thread_id FROM message WHERE message.id = ? LIMIT 1)
        AND message.id <= ?
        AND message.deleted != 1
        LIMIT 1
    });
    $thread_sth->execute($message_id, $message_id);
    my $messages = $thread_sth->fetchall_arrayref({})->[0];

    # TODO - this should be in settings somewhere...
    my $per_page   = 30;
    my $start_page = floor($messages->{count} / $per_page) + 1;

    my $redirect_page = '/thread/' . $messages->{thread_id};
    $redirect_page .= '-' . $messages->{url_slug};


    # Page one threads don't need the page number
    $redirect_page .= '/' . $start_page    if $start_page > 1;

    # First message in thread doesn't need an ID
    $redirect_page .= '#' . $message_id    if $messages->{count} > 1;

    return redirect $redirect_page;
};




1;
