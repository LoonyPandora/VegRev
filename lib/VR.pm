###############################################################################
# VR.pm
# =============================================================================
# Version:      Vegetable Revolution 4.0
# Released:     1st January 2010
# Author:       James Aitken <http://www.loonypandora.com/>
###############################################################################

package VR;

use Dancer;
use Time::HiRes qw(time);
use Time::Local;

use DBIx::Transaction;

use VR::Setup qw(config);
use VR::Model;
use VR::Util;
use VR::Helper;

# Remember to restart app to get it to load settings
&VR::Setup::load_config;

# TODO: Move this into the language files.
our @long_month_names = qw(January February March April May June July August September October November December);
our @month_names = qw(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec);


$SIG{__DIE__} = sub {
#  print "Content-Type: text/html\n\n";
#  print "$_[0]";
};

# Change this line to load the routes specific to a site
load (
  'VR/Route/Portal.pm',   # Always First
  'VR/Route/Session.pm',
  'VR/Route/Firehose.pm',
  'VR/Route/Config.pm',
  'VR/Route/Forum.pm',
  'VR/Route/Archive.pm',
  'VR/Route/Gallery.pm',
  'VR/Route/Message.pm',
  'VR/Route/User.pm',
  'VR/Route/Search.pm',
  'VR/Route/Memberlist.pm',
  'VR/Route/Shoutbox.pm',
  'VR/Route/CMS.pm',      #  Always Last
);

# DBIx::Transaction allows nested transactions. This is useful. So we use it.
# Check Autocommit if sessions seem to be not working
our $dbh = DBIx::Transaction->connect(config('database'), config('db_user'), config('db_pass'), { RaiseError => 1, AutoCommit => 0 });
$dbh->do("SET NAMES utf8");

# APP STARTS HERE!!!! WOOO YEAH C'MON!!!!
before sub {
#print "Content-Type: text/html\n\n";
  our %viewer   = ();
  our $viewer   = undef;
  our %sth      = ();
  our $sth      = undef;
  our %db       = ();
  our $db       = undef;
  our %tmpl     = ();
  our $tmpl     = undef;
  our @buttons  = ();
  our %tmp      = ();
  our $tmp      = undef;

  our $QUERY_COUNT  = undef;
  our $START_TIME   = time();               # Just basic timing for HTML display.
  our $TIMESTAMP    = int(timegm(gmtime));  # This could change during script execution
  
  layout 'main';

  &VR::Model::Session::load_viewer;  
  &VR::Model::Session::update_session($VR::viewer{'user_id'}, $VR::viewer{'last_online'}, $VR::viewer{'ip_address'});
};




true;
