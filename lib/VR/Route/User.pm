package VR::Route::User;

use common::sense;
use Dancer ':syntax';


prefix '/user';


get '/' => sub {
    template 'index';
};
