package VR::Route::Forum;

use common::sense;
use Dancer ':syntax';

prefix '/forum';


# You need to specify a tag, otherwise redirect to front page
get '/' => sub {
    redirect '/';
};


true;