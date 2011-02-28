package VR::Route::Mail;

use common::sense;
use Dancer ':syntax';
use Dancer::Plugin::Database;

prefix '/mail';


# Shows all messages, with page numbers
get qr{/(\d+)?/?$} => sub {
    my ($page) = splat;

    template 'mail';
};


true;
