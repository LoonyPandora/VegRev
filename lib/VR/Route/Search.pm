###############################################################################
# VR::Route::Search.pm
# =============================================================================
# Version:      Vegetable Revolution 4.0
# Released:     1st January 2010
# Author:       James Aitken <http://www.loonypandora.com/>
###############################################################################

get r('/search/?') => sub {
  
  
#  &VR::Model::Forum::load_threads($board, '0', '15');

  template 'search';
};


# Search results. Replace with Sphinx ASAP
get r('/search/(\d{1,5})') => sub {
   my ($search_id) = splat;
 
  
  &VR::Model::Search::load_search($search_id, '0', '15');

  template 'search_results';
};





1;