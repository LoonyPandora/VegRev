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
has old_password     => ( is => 'ro' );
has hide_email       => ( is => 'rw' );
has mail_notify      => ( is => 'rw' );
has stealth_login    => ( is => 'rw' );
has is_admin         => ( is => 'rw' );
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


sub new_from_email {
    my $self = shift;
    my $args = shift;

    my $sth = database->prepare(q{
        SELECT id, user_name, display_name, email, password, old_password, avatar
        FROM user
        WHERE email = ?
        LIMIT 1
    });
    $sth->execute($args->{email});

    my $user_data = $sth->fetchall_arrayref({})->[0];

    return VegRev::User->new({
        %$user_data,
    });
}


# Loads a user when you've given an id
sub load_extra {
    my $self   = shift;
    my $fields = shift;

    # Pass an arrayref of fields to load. Defaults to all
    $fields = $fields // ['*'];

    my $sth = database->prepare('
        SELECT '. join(",", @$fields ).'
        FROM user
        WHERE id = ?
        LIMIT 1
    ');

    $sth->execute($self->id);
    my $user_data = $sth->fetchall_arrayref({})->[0];

    while (my ($key, $value) = each %{$user_data}) {
        next if $key eq 'old_password'; # It's read-only
        $self->$key($value);
    }

    return $self;
}

sub save {
    my $self   = shift;
    my $fields = shift;

    # Must provide the fields to save. Too risky to save the entire user 
    # might have had an error when loading it, and then we've just lost the user
    if (!$fields) {
        die "No fields passed to save";
    }

    my @update_data = map { $self->$_ } @$fields;
    my $sth = database->prepare('
        UPDATE user
        SET '. join(" = ?, ", @$fields ).' = ?
        WHERE id = ?
        LIMIT 1
    ');
    $sth->execute(@update_data, $self->id);

    return $self;
}


# Returns an arrayref of all recently viewed threads.
sub recently_viewed {
    my $self = shift;
    
    my $recent_sth = database->prepare(q{
        SELECT thread_id, subject, url_slug
        FROM thread_read_receipt
        LEFT JOIN thread ON thread.id = thread_id
        WHERE user_id = ?
        ORDER BY timestamp DESC
        LIMIT 10
    });
    $recent_sth->execute($self->id);

    my $threads = $recent_sth->fetchall_arrayref({});

    return $threads;
}




# Stores any useful information about the user in the session
sub store_session {
    my $self = shift;

    session(user_id        => $self->id);
    session(user_name      => $self->user_name);
    session(display_name   => $self->display_name);
    session(theme          => $self->theme);
    session(language       => $self->language);
    session(avatar         => $self->avatar);
    session(is_admin       => $self->is_admin);
    session(gmt_offset     => $self->gmt_offset);
    session(recent_threads => $self->recently_viewed);
    session(ip_address     => '127.0.0.1');
}



1;
