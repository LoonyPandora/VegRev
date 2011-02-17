package VR::Model;

use common::sense;
use Dancer ':syntax';

use base 'Exporter';
use vars '@EXPORT_OK';

@EXPORT_OK = qw(pagination);




# I shouldn't generate HTML here, that's a templates job.
# But you shouldn't have logic like this in a template
# I want to keep templates simple, so this is the lesser evil.
sub pagination {
    my ($current_page, $total_pages) = @_;

    my $pages_menu = q{<select>};
    for (1 .. $total_pages) {
        if ($current_page == $_) {
            $pages_menu .= qq{\n    <option value="$_" selected="selected">$_</option>};
        } else {
            $pages_menu .= qq{\n    <option value="$_">$_</option>};
        }
    }    
    $pages_menu .= qq{\n</select>};

    my $next_prev_block = q{<ul>};    
    if ($total_pages == 1) {
        $next_prev_block .= qq{\n    <li>One Page</li>};
    } elsif ($current_page == 1) {
        $next_prev_block .= qq{\n    <li><a href="#} . ($current_page + 1) . q{">Next Page</a></li>};
    } elsif ($current_page < $total_pages) {
        $next_prev_block .= qq{\n    <li><a href="#} . ($current_page - 1) . q{">Prev Page</a></li>};
        $next_prev_block .= qq{\n    <li><a href="#} . ($current_page + 1) . q{">Next Page</a></li>};
    } elsif ($current_page == $total_pages) {
        $next_prev_block .= qq{\n    <li><a href="#} . ($current_page - 1) . q{">Prev Page</a></li>};
    }
    $next_prev_block .= qq{\n</ul>};

    return {
        'pages_menu'        => $pages_menu,
        'next_prev_block'   => $next_prev_block,
    };
}

1;