$(document).ready(function() {
    init_gallery();
});



/* Resize gallery pictures
********************************/

function init_gallery() {
    var container = $('ul.upload_list');

    if (!container.length) { return; }

    container.imagesLoaded(function(){
        container.masonry({
            itemSelector : 'li'
        });
    });

}

