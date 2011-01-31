package VR::Route;

use common::sense;
use Dancer ':syntax';

# These are misc aliases and forwarding only routes


# Front page is always page 1 of the forum
get '/' => sub {
    forward '/forum/1/';
};


# Redirection for old fashioned route to user profiles
get '/user/:user_name' => sub {
    redirect "/profile/" . params->{'user_name'};;
};

true;