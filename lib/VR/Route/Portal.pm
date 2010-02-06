###############################################################################
# VR::Route::Portal.pm
# =============================================================================
# Version:      Vegetable Revolution 4.0
# Released:     1st January 2010
# Author:       James Aitken <http://www.loonypandora.com/>
###############################################################################


get '/' => sub {
  
  
#  &VR::Model::Forum::load_threads($board, '0', '15');

  template 'portal';
};

1;