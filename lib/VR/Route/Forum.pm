package VR::Route::Forum;

use common::sense;
use Dancer ':syntax';


prefix '/forum';


get '/' => sub {
    template 'index';
};
