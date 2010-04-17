###############################################################################
# VR::Route::Message.pm
# =============================================================================
# Version:      Vegetable Revolution 4.0
# Released:     1st January 2010
# Author:       James Aitken <http://www.loonypandora.com/>
###############################################################################


get r('/messages/?(\d{1,10})?/?') => sub {
  my ($page) = splat;
  my $offset = ($page*15) - 15;
  if ($offset < 0 ) { $offset = 0; $page = 1; }

  if ($VR::viewer{'is_guest'}) { redirect('/'); }
  
  &VR::Model::Message::load_inbox($VR::viewer{'user_id'}, $offset, '15');

  %VR::tmpl = (
    current_route => "/messages",
    current_page  => $page,
    total_pages   => int(($VR::db->{'private_total'}{'total_messages'}/15)+0.9999),
    page_title    => 'inbox',
  );

  template 'inbox';
};


get '/messages/sent' => sub {
  
  
#  &VR::Model::Forum::load_threads($board, '0', '15');

  template 'sent_messages';
};


get r('/messages/inbox/(\d{1,10})/?') => sub {  
  my ($pm_thread) = splat;
  
#  &VR::Model::Forum::load_threads($board, '0', '15');

  template 'private_thread';
};



1;