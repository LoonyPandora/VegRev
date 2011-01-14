package VR::Route;

use common::sense;
use Dancer ':syntax';


# These are the basic routes and misc aliases


get '/' => sub {
    template 'index';
};


get '/user/:user_name' => sub {
    redirect "/profile/" . params->{'user_name'};;
};

true;