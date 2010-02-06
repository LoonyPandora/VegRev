###############################################################################
# VR::Route::Gallery.pm
# =============================================================================
# Version:      Vegetable Revolution 4.0
# Released:     1st January 2010
# Author:       James Aitken <http://www.loonypandora.com/>
###############################################################################


# Overview of albums
get '/gallery' => sub {
  
  &VR::Model::Gallery::load_albums();

  template 'gallery';
};


# Viewing contents of album
get r('/gallery/(\w+)/?') => sub {
  my ($album) = splat;
  
  &VR::Model::Session::load_board_permissions($album);

  if ($VR::viewer{'can_view_threads'}) {
    &VR::Model::Gallery::load_photo_list($album, '0', '16');
  	&VR::Model::Forum::write_board_viewer($album, $VR::viewer{'user_id'}, $VR::TIMESTAMP);
  }

  %VR::tmpl = (
    current_route => "/gallery/$album",
    current_page  => 1,
    total_pages   => int(($VR::db->{'album'}{'board_thread_total'}/15)+0.9999),
    page_title    => $VR::db->{'album'}{'board_description'},
  );

  if ($VR::viewer{'can_reply_threads'})   { push (@VR::buttons, 'Upload_Photo'); }

  template 'album';
};


# Later Pages of an Album
get r('/gallery/(\w+)/(\d{1,8})/?') => sub {
  my ($album, $page) = splat;
  $offset = ($page*15) - 15;

  &VR::Model::Session::load_board_permissions($album);
  
  if ($VR::viewer{'can_view_threads'}) {
    &VR::Model::Gallery::load_photo_list($album, $offset, '16');
  	&VR::Model::Forum::write_board_viewer($album, $VR::viewer{'user_id'}, $VR::TIMESTAMP);
  }

  %VR::tmpl = (
    current_route => "/gallery/$album",
    current_page => $page,
    total_pages => int(($VR::db->{'album'}{'board_thread_total'}/15)+0.9999),
    page_title    => $VR::db->{'album'}{'board_description'},
  );

  if ($VR::viewer{'can_reply_threads'})   { push (@VR::buttons, 'Upload_Photo'); }

  template 'album';
};



# Viewing a Photo
get r('/gallery/(\w+)/?([0-9a-zA-Z-]+-[0-9]{9,10})/?') => sub {
  my ($album, $thread) = splat;
  my $thread_id = $thread; 
  $thread_id =~ s/(.*?)?([0-9]{9,10})$/$2/g;

  &VR::Model::Session::load_board_permissions($album);
    
  if ($VR::viewer{'can_view_threads'}) {
  	&VR::Model::Gallery::load_photo($thread_id, '0', '99');
  	&VR::Model::Forum::write_thread_viewer($thread_id, $VR::viewer{'user_id'}, $VR::TIMESTAMP);
  	&VR::Model::Forum::load_thread_viewers($thread_id);
  }
  
  %VR::tmpl = (
    current_route => "/gallery/$album/$thread",
    current_page  => 1,
    total_pages   => int(($VR::db->{'album'}{'thread_messages'}/15)+0.9999),
    page_title    => $VR::db->{'album'}{'thread_subject'},
  );

  if ($VR::viewer{'can_reply_threads'})                   { push (@VR::buttons, 'Add_Comment'); }
  if ($VR::viewer{'can_start_polls'})                     { push (@VR::buttons, 'Add_Poll'); }
  if ($VR::viewer{'is_admin'} || $VR::viewer{'is_mod'})   { push (@VR::buttons, 'Admin'); }
 
  template 'photo';
};


1;