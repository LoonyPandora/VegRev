package VR::Route::Member;

use common::sense;
use Dancer ':syntax';
use Dancer::Plugin::Database;

prefix '/member';


# Matches GET /profile/:user_name
get qr{/(\d+)$} => sub {
    my ($page) = splat;

    template 'member';
};


true;