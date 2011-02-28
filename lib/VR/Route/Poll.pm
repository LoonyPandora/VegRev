package VR::Route::Poll;

use common::sense;
use Dancer ':syntax';
use Dancer::Plugin::Database;
use Dancer::Plugin::Ajax;

prefix '/poll';


ajax '/view/:poll_id' => sub {
    redirect '/';
};


ajax '/vote/:poll_id' => sub {
    redirect '/';
};


ajax '/result/:poll_id' => sub {
    redirect '/';
};








true;
