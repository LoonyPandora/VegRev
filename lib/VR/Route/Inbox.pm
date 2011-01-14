package VR::Route::Inbox;

use common::sense;
use Dancer ':syntax';
use Dancer::Plugin::Database;

prefix '/inbox';


# Shows all messages, with page numbers
get qr{/(\d+)?/?$} => sub {
    my ($page) = splat;

    template 'inbox';
};


true;
