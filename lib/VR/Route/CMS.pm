###############################################################################
# VR::Route::CMS.pm
# =============================================================================
# Version:      Vegetable Revolution 4.0
# Released:     1st January 2010
# Author:       James Aitken <http://www.loonypandora.com/>
###############################################################################


get '/:page' => sub {
  
  
#  &VR::Model::Forum::load_threads($board, '0', '15');

  template 'cms';
};

1;