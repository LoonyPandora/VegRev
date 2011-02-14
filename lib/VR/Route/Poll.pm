package VR::Route::Photo;

use common::sense;
use Dancer ':syntax';
use Dancer::Plugin::Database;

prefix '/poll';


get '/view/:poll_id' => sub {
    redirect '/';
};


get '/vote/:poll_id' => sub {
    redirect '/';
};


get '/result/:poll_id' => sub {
    redirect '/';
};

true;
