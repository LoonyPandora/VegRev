###############################################################################
# VR::Setup.pm
# =============================================================================
# Version:      Vegetable Revolution 4.0
# Released:     1st January 2010
# Author:       James Aitken <http://www.loonypandora.com/>
###############################################################################

package VR::Setup;

use strict;
use warnings;
use YAML;

use base 'Exporter';
use vars '@EXPORT_OK';

@EXPORT_OK = qw(config);

# singleton for storing configuration
my $CONFIGURATION = { };
sub configuration { $CONFIGURATION }

sub config {
  my ($setting, $value) = @_;

  # setter/getter
  (@_ == 2) 
    ? $CONFIGURATION->{$setting} = $value
    : $CONFIGURATION->{$setting} ;
}

sub load_config {
  my $file = './config/settings.yml';
  my $yml = YAML::LoadFile($file) or die "Unable to parse the configuration file: $file";

  foreach my $key (keys %$yml) {
    config($key => $yml->{$key});
  }
  return scalar(keys %$yml);
}

1;