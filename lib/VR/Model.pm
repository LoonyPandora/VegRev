package VR::Model;

use common::sense;

use Dancer::Plugin::Database;

use base 'Exporter';
use vars '@EXPORT_OK';

@EXPORT_OK = qw(load_user_data);


# Each route prefix can use this module, getting the precise functions it requires
# Nothing more, nothing less. If this gets too large, we'll need to split it up.
# Current estimates put it around 800 loc - which is manageable.
# Though if it needs to be split up, should probably use DBIC instead...


sub load_user_data {
    my ($user_name, $fields) = @_;

    if (!$fields) { $fields = qw[id user_name display_name]; }

    my $sth = database->prepare(
        # TODO, use proper bind vars
        qq{
            SELECT * FROM user
            WHERE user_name = ?
        }
    );
    
    $sth->execute($user_name);
    return $sth;
}


# FORMAT OF THREAD DATA STRUCTURE - prelim
# $t = {
#   'meta'  =>  {
#                   'subject'   =>  'blah',
#                   'viewers'   =>  [
#                                       {
#                                           'user_id'       =>  '1',
#                                           'username'      =>  'admin',
#                                           'displayname'   =>  'LoonyPandora',
#                                      },
#                                   ],
#               },
#   '1000'  =>  {
#                   'body'          =>  'nlah',
#                   'user_id'       =>  '1',
#                   'username'      =>  'admin',
#                   'displayname'   =>  'LoonyPandora',
#                   'datetime'      =>  '2010-01-01 11:11:11',
#                   'quotes'        =>  [
#                                           {
#                                               'user_id'       =>  '1',
#                                               'username'      =>  'admin',
#                                               'displayname'   =>  'LoonyPandora',
#                                               'content'       =>  'blah',
#                                               'datetime'      =>  '2010-01-01 11:11:11',
#                                           },
#                                           {
#                                               'user_id'       =>  '1',
#                                               'username'      =>  'admin',
#                                               'displayname'   =>  'LoonyPandora',
#                                               'content'       =>  'blah',
#                                               'datetime'      =>  '2010-01-01 11:11:11',
#                                           },
#                                       ],
#               },
#               
#   }

