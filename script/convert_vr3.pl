#!/usr/bin/perl --

###############################################################################
# Convert_VR3.pl
# =============================================================================
# Version:      Vegetable Revolution 4.0
# Released:     1st January 2010
# Author:       James Aitken <http://www.loonypandora.com/>
###############################################################################

package converter;
use strict;

use lib "./lib";
use lib "./lib/perl";

use Time::HiRes qw(time);
use Time::Local;

use DBIx::Transaction;


our $mysql = DBIx::Transaction->connect('DBI:mysql:database=dancer', 'root', 'A1tken379', { RaiseError => 1, AutoCommit => 0 });
our $sqlte = DBIx::Transaction->connect('DBI:SQLite:dbname=/Library/WebServer/Documents/old_vr/db/main.sqlite3', '', '', { RaiseError => 1, AutoCommit => 0 });


our %loop = ();


&convert('users');



sub convert {
  my $sql = qq{
SELECT * FROM $_[0]
  };
  
	$converter::loop = $converter::sqlte->prepare($sql);
	$converter::loop->execute();
	$converter::loop->bind_columns(\(@converter::loop{@{$converter::loop->{NAME_lc}}}));
	
	my $x = 0;
  $converter::mysql->begin_work;

	while ($converter::loop->fetchrow_arrayref) {
  	while ((my $key, my $value) = each(%converter::loop)) {
      $converter::loop{$key} = $converter::mysql->quote($converter::loop{$key});
    }
    
	  my $insert = '';
	  $insert = qq{INSERT INTO $_[0] (};
	  $insert .= join (', ', keys %converter::loop);
	  $insert .= q{) VALUES (};
    $insert .= join (', ', values %converter::loop);
	  $insert .= q{)};
    
    $converter::mysql->do($insert);
    $x++;
    
    if ($x % 1000 == 0) {
      print "COMMIT $x\n";
      $converter::mysql->commit;
      $converter::mysql->begin_work;
    }
	}

  $converter::mysql->commit;

}


