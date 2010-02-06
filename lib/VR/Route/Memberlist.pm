###############################################################################
# VR::Route::Memberlist.pm
# =============================================================================
# Version:      Vegetable Revolution 4.0
# Released:     1st January 2010
# Author:       James Aitken <http://www.loonypandora.com/>
###############################################################################

get '/members' => sub {
  
  
#  &VR::Model::Forum::load_threads($board, '0', '15');

  template 'memberlist';
};



get '/members/:sort' => sub {
  
  
#  &VR::Model::Forum::load_threads($board, '0', '15');

  template 'memberlist';
};


1;