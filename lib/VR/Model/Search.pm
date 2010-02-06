###############################################################################
# VR::Model::Search.pm
# =============================================================================
# Version:      Vegetable Revolution 4.0
# Released:     1st January 2010
# Author:       James Aitken <http://www.loonypandora.com/>
###############################################################################

package VR::Model::Search;

use strict;
use warnings;
use base 'Exporter';
use vars '@EXPORT_OK';

@EXPORT_OK = qw();


# sub load_search {
#   my ($search_id, $offset, $limit) = @_;
#   
#   my ($search, $limit, $begin_time, $end_time, $board_string, $offset) = @_;
# 
# 
#   my $static_sql = q|
# SELECT searches.search_query, searches.search_type
# FROM searches
# WHERE searchs.search_id = ?
# LIMIT 1
# |;
# 
#   my @static_bind = (
#     $search_id,
#   );
# 
# 
#   &VR::Util::fetch_db(\$static_sql, \@static_bind, \$VR::db->{'search'});
# 
# 
#   $VR::db->{'thread'}{'search_query'} = $vr::dbh->quote("%".$VR::db->{'thread'}{'search_query'}."%");
# 
#   
#   my $sql = qq|
# SELECT DISTINCT messages.message_id, messages.thread_id, messages.message_body, messages.message_time, threads.thread_subject, threads.board_id, boards.category_id, users.user_id, users.user_name, users.display_name, users.avatar, special_groups.spec_group_color
# FROM messages
# INNER JOIN threads AS threads ON threads.thread_id = messages.thread_id
# INNER JOIN boards AS boards ON threads.board_id = boards.board_id
# INNER JOIN users AS users ON users.user_id = messages.user_id
# LEFT JOIN special_groups AS special_groups ON users.spec_group_id = special_groups.spec_group_id
# WHERE messages.message_body LIKE $VR::db->{'thread'}{'search_query'}
# AND boards.category_id = 'forum'
# AND boards.vip_only != '1'
# AND boards.mods_only != '1'
# AND messages.message_deleted != '1'
# AND messages.message_time <= ? AND messages.message_time  >= ?
# AND threads.board_id IN ($board_string)
# GROUP BY messages.thread_id
# ORDER BY messages.message_time DESC
# LIMIT ?, ?
# }|;
# 
#   my @bind = (
#     $VR::db->{'thread'}{'search_query'},
#     $VR::db->{'thread'}{'search_type'},
#     $offset,
#     $limit,
#   );
# }
# 
# 
1;