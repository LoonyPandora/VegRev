package VR::Route;

use common::sense;
use Dancer ':syntax';

# These are misc aliases and forwarding only routes


# Front page is always page 1 of the forum
# TODO DANCER BUG - forward doesn't pass along session details
# hence you appear to be logged out on the front page
get '/' => sub {
    forward '/forum/1/';
};


# TODO DANCER BUG - forward doesn't work with regex matched routes
get '/gallery' => sub {
    forward '/gallery/1/';
};

get '/gallery/' => sub {
    forward '/gallery/1/';
};


# Redirection for old fashioned route to user profiles
get '/user/:user_name' => sub {
    redirect "/profile/" . params->{'user_name'};;
};

true;