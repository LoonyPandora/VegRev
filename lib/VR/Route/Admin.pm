package VR::Route::Admin;

use common::sense;
use Dancer ':syntax';
use Dancer::Plugin::Database;

prefix '/admin';


get '/' => sub {
    redirect '/';
};


true;
