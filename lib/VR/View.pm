package VR::View;

use common::sense;
use Dancer ':syntax';

# This provides view helpers. Named like this so it's the right namespace



# Access app config in templates
sub config {
    my $setting = shift;    
    my $settings = Dancer::Config->settings;

    return $settings->{config}{$setting};
}


1;