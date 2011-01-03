package VR::Model;

use common::sense;

use Dancer::Plugin::Database;

use base 'Exporter';
use vars '@EXPORT_OK';

@EXPORT_OK = qw( );


# Each route prefix can use this module, getting the precise functions it requires
# Nothing more, nothing less. If this gets too large, we'll need to split it up.
# Current estimates put it around 800 loc - which is manageable.
# Though if it needs to be split up, should probably use DBIC instead...


