package VR::Route::User;

use common::sense;
use Dancer ':syntax';
use Dancer::Plugin::Database;


prefix '/user';

# Matches GET /user/:user_name
get qr{/(\w+)} => sub {
    my ($user_name) = splat;

    my $sth = database->prepare(
      q{SELECT * FROM user WHERE user_name = ?}
    );

    $sth->execute($user_name);

    template 'user', {
      user => values %{$sth->fetchall_hashref('id')}
    };
};


true;