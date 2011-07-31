
$(document).ready(function() {
    init_quotes();
});



/* Showing quoted messages
********************************/

function init_quotes() {
    $('.in_reply_to li').click(function() {

        if ($(this).css('height') != '20px') {
            $(this).animate({height: '20px'}, { queue: false, duration: 100 } );
        } else {
            // Can't animate to auto height
            $(this).css('height', 'auto');
        }

        return false; 
    });
}

