$(document).ready(function() {

    $('.post_reply').click(function() {
        $('#in_reply_to').val($(this).parent().parents('li').attr('id'));
        $('#postform').modal('show');
        return false;
    });
    

});


