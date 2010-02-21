###############################################################################
# VR::Route::Portal.pm
# =============================================================================
# Version:      Vegetable Revolution 4.0
# Released:     1st January 2010
# Author:       James Aitken <http://www.loonypandora.com/>
###############################################################################


get '/' => sub {
  my (undef, undef, undef, $day_today, $month_today, undef)          = gmtime ($VR::TIMESTAMP);
	my (undef, undef, undef, $day_plusone, $month_plusone, undef)      = gmtime ($VR::TIMESTAMP + 86400);
	my (undef, undef, undef, $day_plustwo, $month_plustwo, undef)      = gmtime ($VR::TIMESTAMP + 172800);
	my (undef, undef, undef, $day_plusthree, $month_plusthree, undef)  = gmtime ($VR::TIMESTAMP + 259200);
  $month_today++; $month_plusone++; $month_plustwo++; $month_plusthree++;
  
  &VR::Model::Portal::load_recent_posts('25');
  &VR::Model::Portal::load_recent_photos('gallery', '10', 'comments');

  &VR::Model::Portal::load_birthdays($day_today, $month_today, 'bday_today');
  &VR::Model::Portal::load_birthdays($day_plusone, $month_plusone, 'bday_tomorrow');
  &VR::Model::Portal::load_birthdays($day_plustwo, $month_plustwo, 'bday_two_days');
  &VR::Model::Portal::load_birthdays($day_plusthree, $month_plusthree, 'bday_three_days');

  &VR::Model::Portal::get_stats;

  &VR::Model::Portal::get_online_users;
  &VR::Model::Portal::get_online_user_avatars;
  
  &VR::Model::Portal::load_news('3');

  
  template 'portal';
};


1;