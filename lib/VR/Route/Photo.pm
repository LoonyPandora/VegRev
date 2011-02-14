package VR::Route::Photo;

use common::sense;
use Dancer ':syntax';
use Dancer::Plugin::Database;

prefix '/photo';


# You need to specify a thread, otherwise redirect to front page
get '/' => sub {
    redirect '/';
};


# Matches /photos/:photo_id-:url_slug/:page - URL slug is acutally ignored.
get qr{/(\d+)\-?[\w\-]+?/?(\d+)?/?$} => sub {
    my ($photo_id, $page) = splat;

    template 'photo';
};


# Posting new replies to a thread, url slug is ignored.
post qr{/(\d+)\-?[\w\-]+?/?(\d+)?/?$} => sub {
    my ($photo_id, $page) = splat;

    template 'photo';
};


true;
