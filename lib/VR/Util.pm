###############################################################################
# VR::Util.pm
# =============================================================================
# Version:      Vegetable Revolution 4.0
# Released:     1st January 2010
# Author:       James Aitken <http://www.loonypandora.com/>
###############################################################################

package VR::Util;

use strict;
use warnings;



sub write_db {
  my ($sql, $bind) = @_;
  
  $VR::dbh->begin_work;
  eval {
    my $query = $VR::dbh->prepare(${$sql});
    $query->execute(@{$bind});
    $VR::dbh->commit;
	  $VR::QUERY_COUNT++;
  };
	if ($@) {
		die "Failed: ".(caller(1))[3]."\nLine: ".(caller(1))[2]."\nReason: $@";
		eval { $VR::dbh->rollback while $VR::dbh->transaction_level; };
	}
}


# $return is a straight hashref
sub fetch_db_noref {
  my ($sql, $bind, $return) = @_;
  
  my $query = $VR::dbh->prepare(${$sql});
  $query->execute(@{$bind});
  $query->bind_columns(\(@{$return}{@{$query->{NAME_lc}}}));
  $query->fetch;
	$VR::QUERY_COUNT++;
}

# $return is a ref to hashref
sub fetch_db {
  my ($sql, $bind, $return) = @_;
  
  my $query = $VR::dbh->prepare(${$sql});
  $query->execute(@{$bind});
  $query->bind_columns(\(@{${$return}}{@{$query->{NAME_lc}}}));
  $query->fetch;
	$VR::QUERY_COUNT++;
}

# Issues a fetchall_hashref $key is an array
sub fetchall_db {
  my ($sql, $bind, $return, $key) = @_;
  
  my $query = $VR::dbh->prepare(${$sql});
  $query->execute(@{$bind});
  ${$return} = $query->fetchall_hashref($key);
	$VR::QUERY_COUNT++;  
}

sub read_db {
  my ($sql, $bind, $sth, $return) = @_;
  
  ${$sth} = $VR::dbh->prepare(${$sql});
  ${$sth}->execute(@{$bind});
  ${$sth}->bind_columns(\(@{${$return}}{@{${$sth}->{NAME_lc}}}));
	$VR::QUERY_COUNT++;
}

1;