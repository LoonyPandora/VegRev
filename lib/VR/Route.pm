package VR::Route;

use common::sense;
use Dancer ':syntax';


# These are the basic routes and misc aliases


get '/' => sub {
  
    my $name = session('name');

    $name = "Mr Magoo";
    session (name => $name);

    template 'index';
};

