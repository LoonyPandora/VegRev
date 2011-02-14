package VR::Route::Search;

use common::sense;
use Dancer ':syntax';
use Dancer::Plugin::Database;

prefix '/search';


# Straight up GET search, last param is the query
get qr{/([\w+\-]+)/?(.*)?/?$} => sub {
    template 'search';
};



true;