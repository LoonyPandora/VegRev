package VR::Route::User;

use common::sense;
use Dancer ':syntax';
use Dancer::Plugin::Database;

use VR::Model qw(load_user_data);

prefix '/user';

# Matches GET /user/:user_name
get qr{/(\w+)} => sub {
    my ($user_name) = splat;

    # TODO: Add error checking here.
    my $sth = load_user_data($user_name, qw[user_name password]);
    
    template 'user', {
        user => values %{$sth->fetchall_hashref('id')}
    };
};


true;