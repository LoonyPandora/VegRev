###############################################################################
# VR::Route::Forum.pm
# =============================================================================
# Version:      Vegetable Revolution 4.0
# Released:     1st January 2010
# Author:       James Aitken <http://www.loonypandora.com/>
###############################################################################


# Board List
get r('/forum/?') => sub {
  &VR::Model::Forum::load_boards('forum', 'meta');
  &VR::Model::Forum::load_boards('forum', 'chat');
  &VR::Model::Forum::load_boards('forum', 'media');
  
  if ($VR::viewer{'is_vip'}) {
    &VR::Model::Forum::load_boards('forum', 'private');
  }
  if ($VR::viewer{'is_mod'}) {
    &VR::Model::Forum::load_boards('forum', 'private');
    &VR::Model::Forum::load_boards('forum', 'mods');
  }
  
	template 'boards';
};


# Thread List
get r('/forum/(\w+)/?') => sub {
  my ($board) = splat;
    
  &VR::Model::Session::load_board_permissions($board);
  
  if ($VR::viewer{'can_view_threads'}) {
  	&VR::Model::Forum::load_threads($board, '0', '15');
  	&VR::Model::Forum::write_board_viewer($board, $VR::viewer{'user_id'}, $VR::TIMESTAMP);
  }
  
  %VR::tmpl = (
    current_route => "/forum/$board",
    current_page  => 1,
    total_pages   => int(($VR::db->{'board'}{'board_thread_total'}/15)+0.9999),
    page_title    => $VR::db->{'board'}{'board_description'},
  );

  if ($VR::viewer{'can_reply_threads'})   { push (@VR::buttons, 'Start_New_Thread'); }
  if ($VR::viewer{'can_start_polls'})     { push (@VR::buttons, 'Start_Poll'); }

  template 'threads';
};


# Later Pages of a Board
get r('/forum/(\w+)/(\d{1,8})/?') => sub {
  my ($board, $page) = splat;
  my $offset = ($page*15) - 15;

  &VR::Model::Session::load_board_permissions($board);
  
  if ($VR::viewer{'can_view_threads'}) {
  	&VR::Model::Forum::load_threads($board, $offset, '15');
  	&VR::Model::Forum::write_board_viewer($board, $VR::viewer{'user_id'}, $VR::TIMESTAMP);
  }

  %VR::tmpl = (
    current_route => "/forum/$board",
    current_page => $page,
    total_pages => int(($VR::db->{'board'}{'board_thread_total'}/15)+0.9999),
    page_title    => $VR::db->{'board'}{'board_description'},
  );

  if ($VR::viewer{'can_reply_threads'})   { push (@VR::buttons, 'Start_New_Thread'); }
  if ($VR::viewer{'can_start_polls'})     { push (@VR::buttons, 'Start_Poll'); }

  template 'threads';
};


# Viewing a Thread
get r('/forum/(\w+)/?([0-9a-zA-Z-]+-[0-9]{9,10})/?') => sub {
  my ($board, $thread) = splat;
  my $thread_id = $thread; 
  $thread_id =~ s/(.*?)?([0-9]{9,10})$/$2/g;

  &VR::Model::Session::load_board_permissions($board);
    
  if ($VR::viewer{'can_view_threads'}) {
  	&VR::Model::Forum::load_messages($thread_id, '0', '15');
  	&VR::Model::Forum::write_thread_viewer($thread_id, $VR::viewer{'user_id'}, $VR::TIMESTAMP);
  	&VR::Model::Forum::load_thread_viewers($thread_id);
  }
  
  %VR::tmpl = (
    current_route => "/forum/$board/$thread",
    current_page  => 1,
    total_pages   => int(($VR::db->{'thread'}{'thread_messages'}/15)+0.9999),
    page_title    => $VR::db->{'thread'}{'thread_subject'},
  );

  if ($VR::viewer{'can_reply_threads'})                   { push (@VR::buttons, 'Reply_To_Thread'); }
  if ($VR::viewer{'can_start_polls'})                     { push (@VR::buttons, 'Add_Poll'); }
  if ($VR::viewer{'is_admin'} || $VR::viewer{'is_mod'})   { push (@VR::buttons, 'Admin'); }
 
  template 'messages';
};


# Viewing Later pages of a Thread
get r('/forum/(\w+)/?([0-9a-zA-Z-]+-[0-9]{9,10})/(\d{1,8})/?') => sub {
  my ($board, $thread, $page) = splat;
  my $thread_id = $thread; 
  $thread_id =~ s/(.*?)?([0-9]{9,10})$/$2/g;

  my $offset = ($page*15) - 15;
  
  &VR::Model::Session::load_board_permissions($board);
  
  if ($VR::viewer{'can_view_threads'}) {
  	&VR::Model::Forum::load_messages($thread_id, $offset, '15');
  	&VR::Model::Forum::write_thread_viewer($thread_id, $VR::viewer{'user_id'}, $VR::TIMESTAMP);
  	&VR::Model::Forum::load_thread_viewers($thread_id);
  }
 
  %VR::tmpl = (
    current_route => "/forum/$board/$thread",
    current_page  => $page,
    total_pages   => int(($VR::db->{'thread'}{'thread_messages'}/15)+0.9999),
    page_title    => $VR::db->{'thread'}{'thread_subject'},
  );

  if ($VR::viewer{'can_reply_threads'})                   { push (@VR::buttons, 'Reply_To_Thread'); }
  if ($VR::viewer{'can_start_polls'})                     { push (@VR::buttons, 'Add_Poll'); }
  if ($VR::viewer{'is_admin'} || $VR::viewer{'is_mod'})   { push (@VR::buttons, 'Admin'); }

  template 'messages';
};


# TODO: Make this work with read times, rather than just last page.
# Maybe remove it altogether, and just put last unread page in links auto-stylee?
get r('/forum/(\w+)/?([0-9a-zA-Z-]+-[0-9]{9,10})/new/?') => sub {
  my ($board, $thread) = splat;
  my $thread_id = $thread; 
  $thread_id =~ s/(.*?)?([0-9]{9,10})$/$2/g;

  &VR::Model::Session::load_board_permissions($board);
  
  if ($VR::viewer{'can_view_threads'}) {
  	&VR::Model::Forum::load_messages($thread_id, '0', '1');
  }

  my $total_pages = int(($VR::db->{'thread'}{'thread_messages'}/15)+0.9999);
  
  &Dancer::Helpers::redirect ("/forum/$board/$thread/$total_pages", 301);
};



# Showing 'all' pages - really just 10 at a time.
get r('/forum/(\w+)/?([0-9a-zA-Z-]+-[0-9]{9,10})/all-(\d{1,8})/?') => sub {
  my ($board, $thread, $page) = splat;
  my $thread_id = $thread; 
  $thread_id =~ s/(.*?)?([0-9]{9,10})$/$2/g;

  my $offset = ($page*150) - 150;

  &VR::Model::Session::load_board_permissions($board);
  
  if ($VR::viewer{'can_view_threads'}) {
  	&VR::Model::Forum::load_messages($thread_id, $offset, '150');
  	&VR::Model::Forum::write_thread_viewer($thread_id, $VR::viewer{'user_id'}, $VR::TIMESTAMP);
  	&VR::Model::Forum::load_thread_viewers($thread_id);
  }
 
  %VR::tmpl = (
    current_route => "/forum/$board/$thread",
    current_page  => $page,
    total_pages   => int(($VR::db->{'thread'}{'thread_messages'}/150)+0.9999),
    page_title    => $VR::db->{'thread'}{'thread_subject'},
  );

  if ($VR::viewer{'can_reply_threads'})                   { push (@VR::buttons, 'Reply_To_Thread'); }
  if ($VR::viewer{'can_start_polls'})                     { push (@VR::buttons, 'Add_Poll'); }
  if ($VR::viewer{'is_admin'} || $VR::viewer{'is_mod'})   { push (@VR::buttons, 'Admin'); }

  template 'messages';
};


# POST ACTIONS #

# Posting a reply - Rememeber we don't post to a page...
post r('/forum/(\w+)/?([0-9a-zA-Z-]+-[0-9]{9,10})/?') => sub {
  my ($board, $thread) = splat;
  my $thread_id = $thread; 
  $thread_id =~ s/(.*?)?([0-9]{9,10})$/$2/g;

  my $message = params->{'message'};
  $message =~ s/\r\n/[br]/isg;
  $message =~ s/\n/[br]/isg;
  $message =~ s/\r/[br]/isg;

  &VR::Model::Session::load_board_permissions($board);

  if ($VR::viewer{'can_reply_threads'}) {
  	&VR::Model::Forum::post_reply($VR::viewer{'user_id'}, $board, $thread_id, $VR::viewer{'ip_address'}, $VR::TIMESTAMP, params->{'attachment'}, $message, $thread, params->{'quote_message'});
  }
  
  &Dancer::Helpers::redirect ("/forum/$board/$thread/new", 301);
};


# Posting a New Thread - Rememeber we don't post to a page...
post r('/forum/(\w+)/?') => sub {
  my ($board) = splat;
  
  &VR::Model::Session::load_board_permissions($board);

  if ($VR::viewer{'can_start_threads'}) {
  	&VR::Model::Forum::post_thread($VR::viewer{'user_id'}, $board, $VR::TIMESTAMP, $VR::viewer{'ip_address'}, $VR::TIMESTAMP, params->{'attachment'}, params->{'message'}, params->{'subject'});
  }
  
  my $thread_link = params->{'subject'};
  $thread_link =~ s/ /-/g;
  $thread_link =~ s/-+/-/g;
  $thread_link =~ s/&amp;/and/g;
  $thread_link =~ s/[^0-9a-zA-Z-]+//ig;
  $thread_link .= "-$VR::TIMESTAMP";

  &Dancer::Helpers::redirect("/forum/$board/$thread_link", 301);
};


1;




