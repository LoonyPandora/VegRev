package VegRev::User;

use v5.14;
use feature 'unicode_strings';
use utf8;
use common::sense;

use Moo;
use Data::Dumper;
use Dancer qw(:moose);
use Dancer::Plugin::Database;


has id               => ( is => 'rw' );
has user_name        => ( is => 'rw' );
has display_name     => ( is => 'rw' );
has real_name        => ( is => 'rw' );
has email            => ( is => 'rw' );
has password         => ( is => 'rw' );
has hide_email       => ( is => 'rw' );
has mail_notify      => ( is => 'rw' );
has stealth_login    => ( is => 'rw' );
has theme            => ( is => 'rw' );
has language         => ( is => 'rw' );
has tumblr           => ( is => 'rw' );
has last_fm          => ( is => 'rw' );
has homepage         => ( is => 'rw' );
has icq              => ( is => 'rw' );
has msn              => ( is => 'rw' );
has yim              => ( is => 'rw' );
has aim              => ( is => 'rw' );
has gtalk            => ( is => 'rw' );
has skype            => ( is => 'rw' );
has twitter          => ( is => 'rw' );
has flickr           => ( is => 'rw' );
has deviantart       => ( is => 'rw' );
has vimeo            => ( is => 'rw' );
has youtube          => ( is => 'rw' );
has facebook         => ( is => 'rw' );
has myspace          => ( is => 'rw' );
has bebo             => ( is => 'rw' );
has avatar           => ( is => 'rw' );
has usertext         => ( is => 'rw' );
has signature        => ( is => 'rw' );
has biography        => ( is => 'rw' );
has gender           => ( is => 'rw' );
has birthday         => ( is => 'rw' );
has gmt_offset       => ( is => 'rw' );
has registration     => ( is => 'rw' );
has last_online      => ( is => 'rw' );
has last_ip          => ( is => 'rw' );
has post_count       => ( is => 'rw' );
has shout_count      => ( is => 'rw' );
has account_disabled => ( is => 'rw' );




# Loads a user when you've given an id
sub load_extra {
    my $self   = shift;
    my $fields = shift;

    # Pass an arrayref of fields to load. Defaults to all
    $fields = $fields // ['*'];

    my $sth = database->prepare('
        SELECT '. join(",", @$fields ).' FROM user WHERE id = ?
        LIMIT 1
    ');

    $sth->execute($self->id);

    return VegRev::User->new(
       $sth->fetchall_arrayref({})->[0]
    );
}



# Stores any useful information about the user in the session
sub store_session {
    my $self = shift;

    session(user_id      => $self->id);
    session(user_name    => $self->user_name);
    session(display_name => $self->display_name);
    session(theme        => $self->theme);
    session(language     => $self->language);
    session(avatar       => $self->avatar);
    session(gmt_offset   => $self->gmt_offset);

}



1;
