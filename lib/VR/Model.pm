###############################################################################
# VR::Model.pm
# =============================================================================
# Version:      Vegetable Revolution 4.0
# Released:     1st January 2010
# Author:       James Aitken <http://www.loonypandora.com/>
###############################################################################

package VR;

use strict;
use warnings;

use VR::Model::Admin;
use VR::Model::Archive;
use VR::Model::CMS;
use VR::Model::Config;
use VR::Model::Firehose;
use VR::Model::Forum;
use VR::Model::Gallery;
use VR::Model::Memberlist;
use VR::Model::Message;
use VR::Model::Search;
use VR::Model::Session qw(load_viewer);
use VR::Model::Shoutbox;
use VR::Model::User;

1;