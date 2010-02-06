###############################################################################
# VR::Route::Shoutbox.pm
# =============================================================================
# Version:      Vegetable Revolution 4.0
# Released:     1st January 2010
# Author:       James Aitken <http://www.loonypandora.com/>
###############################################################################



get '/shoutbox/' => sub {

  &VR::Model::Shoutbox::load_shouts('10');

  layout undef;
	template 'shoutbox';
};

1;