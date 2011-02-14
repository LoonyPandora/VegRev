package VR::Route::Chat;

use common::sense;
use Dancer ':syntax';
use Dancer::Plugin::Database;

prefix '/chat';


# Shows all messages from that user, with pagination
get qr{/(\w+)/?(\d+)?/?$} => sub {
    my ($user_name) = splat;

    template 'chat';
};


# Posting a new message
post qr{/(\w+)/?(\d+)?/?$} => sub {
    redirect '/';
};

true;
