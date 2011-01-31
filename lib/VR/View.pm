package VR::View;

use common::sense;
use Dancer ':syntax';

use HTML::Entities;
use Time::Duration;
use Time::Local;

# This provides view helpers. Named like this so it's the right namespace



# Access app config in templates
sub config {
    my $setting = shift;    
    my $settings = Dancer::Config->settings;

    return $settings->{config}{$setting};
}


# Generates an img tag when passed an avatar, will pass default avatar if there is none.
sub avatar_img {
    my ($avatar, $usertext) = @_;

    my $base_url = 'http://www.vegetablerevolution.co.uk/uploads';
    
    # We need to encode the individual items, as this function returns HTML
    # And so isn't encoded automagically in the template
    $avatar     = encode_entities($avatar) if $avatar;
    $usertext   = encode_entities($usertext) if $usertext;

    if ($avatar && $avatar =~ /^\d+\.\w{3,4}/) {
        return qq{<img src="$base_url/$avatar" alt="$usertext" />};
    } else {
        return qq{<img src="http://vegrev.local/img/placeholder.png" alt="No Avatar" />};
    }

}


sub time_ago {
    my ($timestamp, $precision) = @_;

    my $seconds = (time - $timestamp);

    if ($seconds < 60) {
        return 'just now';
    } else {
        return ago($seconds, $precision);
    }
}

1;