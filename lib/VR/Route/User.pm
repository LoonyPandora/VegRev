###############################################################################
# VR::Route::User.pm
# =============================================================================
# Version:      Vegetable Revolution 4.0
# Released:     1st January 2010
# Author:       James Aitken <http://www.loonypandora.com/>
###############################################################################


get '/user/:user_name/settings' => sub {
  my $user_name = params->{user_name};
  $user_name =~ s/\W+//sg;
  
  
#  &VR::Model::Forum::load_threads($board, '0', '15');

  template 'edit_profile';
};


get '/user/:user_name' => sub {
  my $user_name = params->{user_name};
  $user_name =~ s/\W+//sg;
  
  
#  &VR::Model::Forum::load_threads($board, '0', '15');

  template 'profile';
};




1;