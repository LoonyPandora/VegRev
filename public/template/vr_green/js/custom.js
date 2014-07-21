/******************************************************************************
  script.js
  =============================================================================
  Version:        Vegetable Revolution 3.0
  Released:        1st February 2009
  Revision:        $Rev$
  Copyright:        James Aitken <http://loonypandora.co.uk>
******************************************************************************/

function pagenav(startpage, endpage, currentURL, currentpage) {

    var newHTML = '<a>&nbsp;</a>';

    for (var i = 0; i < 10; i++) {
        if (startpage > endpage) {
            break;
        }

        if (startpage != 0) {

            if (currentpage == startpage) {
                var selected = ' class=\"selected\"';
            } else {
                var selected = '';
            }

            newHTML += '<a href="' + currentURL + '/' + startpage + '/"' + selected + '>' + startpage + '</a>';
        }
        startpage++;
    }

    newHTML += '<a>all</a><a>&nbsp;</a>'

    document.getElementById('pagination_box').innerHTML = newHTML;

}

function toggle_admin_nav() {
    var admin_nav = document.getElementById("admin_nav");

    if (admin_nav.style.display != 'block') {
        admin_nav.style.display = 'block';
    } else {
        admin_nav.style.display = 'none';
    }
}

function hide_admin_nav() {
    var admin_nav = document.getElementById("admin_nav");

    if (admin_nav) {
        admin_nav.style.display = 'none';
    }
}

function shoutboxSubmit() {
    document.shout_form.real_shout_message.value = document.shout_form.shout_message.value;
    document.shout_form.shout_message.value = '';
    document.shout_form.shout_message.focus();
}

function shoutReload() {
    var f = document.getElementById('shoutbox');
    f.contentWindow.location.reload(true);
}
