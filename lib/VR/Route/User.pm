###############################################################################
# VR::Route::User.pm
# =============================================================================
# Version:      Vegetable Revolution 4.0
# Released:     1st January 2010
# Author:       James Aitken <http://www.loonypandora.com/>
###############################################################################


# Viewing a profile
get r('/user/([0-9a-zA-Z-_]+)/?') => sub {
  my ($user_name) = splat;  
  
  &VR::Model::User::load_profile($user_name);

  template 'profile';
};


# Editing a profile
get r('/user/([0-9a-zA-Z-_]+)/settings/?') => sub {
  my ($board, $page) = splat;
  
  
#  &VR::Model::User::load_threads($board, '0', '15');

  template 'edit_profile';
};



1;