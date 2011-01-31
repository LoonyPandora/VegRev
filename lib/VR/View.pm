package VR::View;

use common::sense;
use Dancer ':syntax';

use HTML::Entities;
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
    
    $avatar     = encode_entities($avatar);
    $usertext   = encode_entities($usertext);

    if ($avatar && $avatar =~ /^\d+\.\w{3,4}/) {
        return qq{<img src="$base_url/$avatar" alt="$usertext" />};
    } else {
        return qq{<img src="http://vegrev.local/img/placeholder.png" alt="No Avatar" />};
    }
    
}

1;