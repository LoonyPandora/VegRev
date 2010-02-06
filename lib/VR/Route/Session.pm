###############################################################################
# VR::Route::Session.pm
# =============================================================================
# Version:      Vegetable Revolution 4.0
# Released:     1st January 2010
# Author:       James Aitken <http://www.loonypandora.com/>
###############################################################################

get '/login' => sub {
  
  
#  &VR::Model::Forum::load_threads($board, '0', '15');

  template 'login';
};

get '/register' => sub {
  
  
#  &VR::Model::Forum::load_threads($board, '0', '15');

  template 'register';
};


get '/iforgot' => sub {
  
  
#  &VR::Model::Forum::load_threads($board, '0', '15');

  template 'iforgot';
};


post '/logout' => sub {
  
  
#  &VR::Model::Forum::load_threads($board, '0', '15');

};



1;