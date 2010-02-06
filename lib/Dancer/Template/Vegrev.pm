###############################################################################
# Dancer::Template::Vegrev.pm
# =============================================================================
# Version:      Vegetable Revolution 4.0
# Released:     1st January 2010
# Author:       James Aitken <http://www.loonypandora.com/>
###############################################################################

package Dancer::Template::Vegrev;
use FileHandle;

use strict;

# Warnings make it moan if I use a variable in a template that I don't export
#use warnings;

sub render($$$) {
  my ($self, $template, $tokens) = @_;

	$self->load("$template");
	$self->setq(%{$tokens});

	return $self->fill;
}

sub new {
  my $name = shift;
  my $self = bless { hash => {} }, ref($name) || $name;

  return $self unless ref($name);

  ## inherit parent configuration
  while (my($k, $v) = each %{$name}) {
    $self->{$k} = $v unless $k eq 'buff';
  }
  $self;
}

sub setq {
    my $self = shift;
    my %pair = @_;

    while (my($key, $val) = each %pair) {
      $self->{hash}->{$key} = $val;
    }
    $self;
}

sub load {
    my $self = shift;
    my $file = shift;

    $file = new FileHandle($file) || die($!) unless ref($file);
    $self->pack(join("", <$file>), @_);
}

sub pack {
    my $self = shift;
    my $buff = shift;
    my %opts = @_;
    my $temp;

    $self->{DELIM}   = [map { quotemeta } @{$opts{DELIM}}] if $opts{DELIM};
    $self->{DELIM} ||= [qw(<% %>)];

    my $L = $self->{DELIM}->[0];
    my $R = $self->{DELIM}->[1];

    undef $self->{buff};
    
    # LoonyPandora: untaint templates. No-one makes them but me, so they are trusted.
    # Not running under taint atm - so just remove this for now
#    $buff =~ /(.*)/s;
#    $buff = $1;

    # Remove uneccesary newlines - Makes view source prettier.
    $buff =~ s|\s+\n|\n|sg;
    $buff =~ s|\n{2,}||sg;

    while ($buff) {
        ## match: <%= ... %>
        if ($buff =~ s|^$L=(.*?)$R||s) {
          $self->{buff} .= qq{\$_handle->(do { $1 \n});} if $1;
        }
        ## match: <% ... %>
        elsif ($buff =~ s|^$L(.*?)$R||s) {
          $self->{buff} .= qq{$1\n} if $1;
        }
        ## match: ... <% or ...
        elsif ($buff =~ s|^(.*?)(?=$L)||s) {
          if ($temp = $1) {
            $temp =~ s|[\{\}]|\\$&|g;
            $self->{buff} .= qq{\$_handle->(q{$temp});};
          }
        }
        ## match: ... (EOF) or <% ... (EOF)
        else {
            last;
        }
    }

    if ($temp = $buff) {
        $temp =~ s|[\{\}\\]|\\$&|g;
        $self->{buff} .= qq{\$_handle->(q{$temp});};
    }

    $self;
}

sub fill {
    my $self = shift;
    my %opts = @_;
    my $from = $opts{PACKAGE} || caller;
    my $name;
    my $eval;

    no strict;
    
    $name = ref($from) || $from;
    
    $eval = eval qq{
        package $name; sub { my \$v = eval(\$_[0]); \$@ ? \$@ : \$v; };
    };
    
    ## export stored data to target namespace
    while (my($key, $val) = each %{$self->{hash}}) {
      $ {"${name}::${key}"} = $val;
    }

    $eval->(q{$_handle = sub { $_OBUFFER .= $_[0]; };});

    $eval->(qq{ undef \$_OBUFFER; $self->{buff}; \$_OBUFFER; });
}

sub render_partial {
    my $self = shift;
    my $file = shift;
    my $vars = shift || {};
    my $package = $file;
    
    $file .= ".tt" if $file !~ /\.tt$/;
    $file = Dancer::FileUtils::path(Dancer::Config::setting('views'), 'partials', $file);

    return $self->new->load($file)->setq(%{$vars})->fill(PACKAGE => 'VR::Template::Partial::'.$package);
}


1;