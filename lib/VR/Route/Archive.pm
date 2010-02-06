###############################################################################
# VR::Route::Archive.pm
# =============================================================================
# Version:      Vegetable Revolution 4.0
# Released:     1st January 2010
# Author:       James Aitken <http://www.loonypandora.com/>
###############################################################################

get '/archive' => sub {
  
  
#  &VR::Model::Forum::load_threads($board, '0', '15');

  template 'boards';
};



get '/archive/:board' => sub {
  
  
#  &VR::Model::Forum::load_threads($board, '0', '15');

  template 'threads';
};


get '/archive/:board/:thread' => sub {
  
  
#  &VR::Model::Forum::load_threads($board, '0', '15');

  template 'messages';
};


1;