package VR::Route::User;

use common::sense;
use Dancer ':syntax';
use Dancer::Plugin::Database;

prefix '/user';


# Matches GET /user/:user_name
get qr{/(\w+)} => sub {
    my ($user_name) = splat;

    my $sth = database->prepare(
        q{ SELECT * FROM user WHERE user_name = ? }
    );

    $sth->execute($user_name);
    my $user = $sth->fetchall_hashref('id');

    # Send to 404 if user doesn't exist
    unless (scalar keys %{$user}) {
        return pass();
    }

    template 'user', {
        user => values %{$user},
    };
};


true;