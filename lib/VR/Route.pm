package VR::Route;

use common::sense;
use Dancer ':syntax';


# These are the basic routes and misc aliases


get '/' => sub {
    template 'index';
};

