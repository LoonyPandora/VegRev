###############################################################################
# controllers/user.pl
# =============================================================================
# Version:    Vegetable Revolution 3.0
# Released:   1st June 2009
# Revision:   $Rev$
# Copyright:  James Aitken <http://www.loonypandora.com>
###############################################################################

use strict;

sub show_login_form {
    if (!$vr::viewer{'is_guest'}) { &_redirect(''); }

    $vr::tmpl{'page_title'} = 'Login';
    $tmpl::form_action = 'do_user_login';
    &_format_template;
}

sub show_registration_form {
    if (!$vr::viewer{'is_guest'}) { &_redirect(''); }

    $vr::tmpl{'page_title'} = 'Register';
    $tmpl::form_action = 'do_user_registration';
    &_format_template;
}

sub do_user_registration {
    if ($vr::POST{'username'} !~ /\w+/)       { die $vr::POST{'username'}; }
    if ($vr::POST{'email'} !~ /\w+@\w+\./)    { die $vr::POST{'email'}; }
    if (lc($vr::POST{'captcha'}) ne 'orange') { die $vr::POST{'captcha'}; }
    if (!$vr::POST{'agree'})                  { die $vr::POST{'agree'}; }
    if (!$vr::POST{'password'} || length($vr::POST{'password'}) < 4) {
        die $vr::POST{'password'};
    }
    if ($vr::POST{'robots'}) { die $vr::POST{'robots'}; }

    my $enc_pass = &_old_insecure_md5_password($vr::POST{'password'});

    my $subject  = qq{[VR] Please Activate Your Account};
    my $body
        = qq~These are the details of your account on The Vegetable Revolution, please keep them safe
  
Username: $vr::POST{'username'}
Password: $vr::POST{'password'}

Activation Link: $vr::config{'base_url'}/activate/$vr::POST{'username'}/$enc_pass/

You must visit the activation link above before you can log in.


-- LoonyPandora
~;

    $vr::dbh->begin_work;
    eval {
        &_pregeister_user($vr::POST{'username'}, $vr::POST{'email'}, $vr::POST{'password'});
        &_sendmail($vr::POST{'email'}, $subject, $body);
        $vr::dbh->commit;
    };
    if ($@) { die "Died because: $@"; }
    else {
        &_redirect('login');
    }
}

sub do_user_activation {

    $vr::dbh->begin_work;
    eval {
        &_get_user_id_from_name($vr::GET{'user'});
        &_do_user_activation($vr::GET{'user'}, $vr::GET{'key'});
        &_update_site_stats('user');

        #    &_sendmail($vr::POST{'email'}, $message);
        $vr::dbh->commit;
    };
    if ($@) { &_redirect(''); }
    else {
        # IE needs expires, doesn't support max-age - so write the stupid date here.
        print qq~Set-Cookie: session_id=$vr::GET{'key'}; path=/; domain=$vr::config{'domain'}\n~;
        &_redirect('');
    }

}

sub show_forgot_password_form {
    if (!$vr::viewer{'is_guest'}) { &_redirect(''); }

    $vr::tmpl{'page_title'} = 'Forgot Password';
    $tmpl::form_action = 'do_reset_password';
    &_format_template;
}

sub do_reset_password {
    if ($vr::POST{'email'} !~ /\w+@\w+\./)    { die $vr::POST{'email'}; }
    if (lc($vr::POST{'captcha'}) ne 'orange') { die $vr::POST{'captcha'}; }
    if ($vr::POST{'robots'})                  { die $vr::POST{'robots'}; }

    my $pass_chars = 'abcdefghijkmnpqrstuvwxyz23456789ABCDEFGHJKLMNPQRSTUVWXYZ';
    my $plain_pass = '';

    while (length($plain_pass) < 9) {
        $plain_pass .= substr($pass_chars, (int(rand(length($pass_chars)))), 1);
    }

    my $subject = qq{[VR] Your New Password};
    my $body    = qq~You forgot your password, so we reset it for you.

We suggest you change the password as soon as you log in. And remember it for next time.
  
New Password: $plain_pass


-- LoonyPandora
~;

    $vr::dbh->begin_work;
    eval {
        &_do_reset_password($vr::POST{'email'}, $plain_pass);
        &_sendmail($vr::POST{'email'}, $subject, $body);
        $vr::dbh->commit;
    };
    if ($@) { die "Died because: $@"; }
    else {
        &_redirect('forgot_password');
    }
}

sub do_user_logout {
    print qq~Set-Cookie: session_id=$vr::COOKIE{'session_id'}; expires=Thursday, 01-Jan-1970 00:00:01 GMT; path=/; domain=$vr::config{'domain'}; HttpOnly\n~;
    &_redirect('');
}

sub do_user_login {
    my $session_id_chars = 'abcdefghijkmnpqrstuvwxyz23456789ABCDEFGHJKLMNPQRSTUVWXYZ0123456789';
    my $session_id = '';

    while (length($session_id) < 32) {
        $session_id .= substr($session_id_chars, (int(rand(length($session_id_chars)))), 1);
    }

    $vr::dbh->begin_work;
    eval { &_authenticate_login($vr::POST{'email'}, $vr::POST{'password'}); };

    if ($@) { die "Died because: $@"; }


    my $expires = '';
    if   ($vr::POST{'remember'}) { $expires = ' expires=Tuesday, 19-Jan-2038 03:14:06 GMT;'; }
    else                         { $expires = ''; }

    if ($vr::db{'user_id'}) {
        &_set_session($session_id, $vr::db{'user_id'});

        # IE needs expires, doesn't support max-age - so write the stupid date here.
        print qq~Set-Cookie: session_id=$session_id;$expires path=/; domain=$vr::config{'domain'}; HttpOnly\n~;
        &_redirect('');
    } else {
        &_redirect('login');
    }
}






1;
