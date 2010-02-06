###############################################################################
# VR::Route::Firehose.pm
# =============================================================================
# Version:      Vegetable Revolution 4.0
# Released:     1st January 2010
# Author:       James Aitken <http://www.loonypandora.com/>
###############################################################################

get '/firehose' => sub {
  
  
#  &VR::Model::Forum::load_threads($board, '0', '15');

  template 'firehose';
};


get '/firehose/:user_name' => sub {
  
  
#  &VR::Model::Forum::load_threads($board, '0', '15');

  template 'firehose';
};


1;