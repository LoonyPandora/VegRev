###############################################################################
# VR::Route::Message.pm
# =============================================================================
# Version:      Vegetable Revolution 4.0
# Released:     1st January 2010
# Author:       James Aitken <http://www.loonypandora.com/>
###############################################################################

get '/messages' => sub {
  
  
#  &VR::Model::Forum::load_threads($board, '0', '15');

  template 'inbox';
};


get '/messages/sent' => sub {
  
  
#  &VR::Model::Forum::load_threads($board, '0', '15');

  template 'sent_messages';
};


get r('/messages/(\d{1,10})/?') => sub {  
  my ($pm_thread) = splat;
  
#  &VR::Model::Forum::load_threads($board, '0', '15');

  template 'private_thread';
};



1;