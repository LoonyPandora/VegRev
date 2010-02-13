###############################################################################
# VR::Route::Memberlist.pm
# =============================================================================
# Version:      Vegetable Revolution 4.0
# Released:     1st January 2010
# Author:       James Aitken <http://www.loonypandora.com/>
###############################################################################


# Redirect to the default sort order
get r('/members/?') => sub {
  &Dancer::Helpers::redirect ("/members/posts", 301);
};


# Sorted by postcount
get r('/members/posts/?') => sub {

  &VR::Model::Memberlist::load_memberlist_by_postcount('0');

  %VR::tmpl = (
    current_route => "/members/posts",
    current_page  => 1,
    total_pages   => int(($VR::db->{'memberlist'}{'total_members'}/20)+0.9999),
  );
  
  template 'memberlist';
};


# Later pages sorted by postcount
get r('/members/posts/(\d{1,8})/?') => sub {
  my ($page) = splat;
  my $offset = ($page*20) - 20;

  &VR::Model::Memberlist::load_memberlist_by_postcount($offset);

  %VR::tmpl = (
    current_route => "/members/posts",
    current_page  => $page,
    total_pages   => int(($VR::db->{'memberlist'}{'total_members'}/20)+0.9999),
  );

  template 'memberlist';
};


# Sorted by name
get r('/members/name/?') => sub {

  &VR::Model::Memberlist::load_memberlist_by_postcount('0');

  %VR::tmpl = (
    current_route => "/members/posts",
    current_page  => 1,
    total_pages   => int(($VR::db->{'memberlist'}{'total_members'}/20)+0.9999),
  );
  
  template 'memberlist';
};


# Later pages sorted by name
get r('/members/name/(\d{1,8})/?') => sub {
  my ($page) = splat;
  my $offset = ($page*20) - 20;

  &VR::Model::Memberlist::load_memberlist_by_postcount($offset);

  %VR::tmpl = (
    current_route => "/members/posts",
    current_page  => $page,
    total_pages   => int(($VR::db->{'memberlist'}{'total_members'}/20)+0.9999),
  );

  template 'memberlist';
};


# Sorted by join date
get r('/members/date/?') => sub {

  &VR::Model::Memberlist::load_memberlist_by_postcount('0');

  %VR::tmpl = (
    current_route => "/members/posts",
    current_page  => 1,
    total_pages   => int(($VR::db->{'memberlist'}{'total_members'}/20)+0.9999),
  );
  
  template 'memberlist';
};


# Later pages sorted by join date
get r('/members/date/(\d{1,8})/?') => sub {
  my ($page) = splat;
  my $offset = ($page*20) - 20;

  &VR::Model::Memberlist::load_memberlist_by_postcount($offset);

  %VR::tmpl = (
    current_route => "/members/posts",
    current_page  => $page,
    total_pages   => int(($VR::db->{'memberlist'}{'total_members'}/20)+0.9999),
  );

  template 'memberlist';
};


# Sorted by last online
get r('/members/online/?') => sub {

  &VR::Model::Memberlist::load_memberlist_by_postcount('0');

  %VR::tmpl = (
    current_route => "/members/posts",
    current_page  => 1,
    total_pages   => int(($VR::db->{'memberlist'}{'total_members'}/20)+0.9999),
  );
  
  template 'memberlist';
};


# Later pages sorted by last online
get r('/members/online/(\d{1,8})/?') => sub {
  my ($page) = splat;
  my $offset = ($page*20) - 20;

  &VR::Model::Memberlist::load_memberlist_by_postcount($offset);

  %VR::tmpl = (
    current_route => "/members/posts",
    current_page  => $page,
    total_pages   => int(($VR::db->{'memberlist'}{'total_members'}/20)+0.9999),
  );

  template 'memberlist';
};


1;