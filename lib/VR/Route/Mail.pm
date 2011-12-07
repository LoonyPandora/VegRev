package VR::Route::Mail;

use common::sense;
use Dancer ':syntax';
use Dancer::Plugin::Database;

use Data::Dumper;


prefix '/mail';


# Shows all messages, no pagination
get qr{/?$} => sub {
    set layout => undef;
    set template => 'xslate';

    template 'mail' , {
        messages => get_mail_threads('1')
    };
};


# Shows an individual conversation
get qr{/view/(\d+)?/?$} => sub {
    my ($conversation) = splat;

    set layout => undef;
    set template => 'xslate';

    template 'mail_view' , {
        messages => get_mail_messages($conversation)
    };
};


sub get_mail_messages {
    my ($user_id) = @_;

    my $viewer_id = 1;

    my $sth = database->prepare(q{
        SELECT mail.id, ip_address, timestamp, body, sender.display_name AS sender, receiver.display_name AS receiver
        FROM mail
        LEFT JOIN USER AS sender ON sent_to = sender.id
        LEFT JOIN USER AS receiver ON sent_from = receiver.id
        WHERE sent_from IN (?, ?)
        AND sent_to IN (?, ?)
        ORDER BY timestamp DESC
    });

    $sth->execute($viewer_id, $user_id, $viewer_id, $user_id);
    my $recent = $sth->fetchall_arrayref({});
    
    die Dumper($recent);
    
}



sub get_mail_threads {
    my ($user_id) = @_;

    my $sth = database->prepare(q{
        SELECT DISTINCT(user_id), display_name, avatar
        FROM
        (SELECT sent_from AS user_id, timestamp
        FROM mail
        WHERE sent_to = ?

        UNION ALL

        SELECT sent_to AS user_id, timestamp
        FROM mail
        WHERE sent_from = ?
        
        ORDER BY timestamp DESC) AS view
        LEFT JOIN user ON user_id = user.id
    });

    $sth->execute($user_id, $user_id);
    my $recent = $sth->fetchall_arrayref({});
}




true;
