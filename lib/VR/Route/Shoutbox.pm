package VR::Route::Shoutbox;

use common::sense;
use Dancer ':syntax';
use Dancer::Plugin::Database;

prefix '/shoutbox';


# Reading shouts
get '/' => sub {
    template 'shoutbox';
};


# Posting a new shout
post '/' => sub {
    redirect '/';
};


# Loads the archives
get '/archive' => sub {
    template 'shoutbox';
};


true;