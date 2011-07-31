


/* On Page Ready
********************************/

$(document).ready(function() {
    init_tooltips();
    init_hashgrid();
    init_tabs();
    
    
    // $('#tag_select').chosen();
    
});












/* COMPLETE FUNCTIONS
********************************/







/* Enables tabs
********************************/

function init_tabs() {
    var tabs = $('ul.tabs');

    tabs.each(function(i) {
        //Get all tabs
        var tab = $(this).find('> li > a');
        tab.click(function(e) {

            //Get Location of tab's content
            var contentLocation = $(this).attr('href');

            //Let go if not a hashed one
            if (contentLocation.charAt(0) == "#") {

                e.preventDefault();

                //Make Tab Active
                tab.removeClass('active');
                $(this).addClass('active');

                //Show Tab Content & add active class
                $(contentLocation).show().addClass('active').siblings().hide().removeClass('active');

            }
        });
    });
}


/* Enables the grid
********************************/

function init_hashgrid() {
    var grid = new hashgrid({
        numberOfGrids: 1
    });
}



/* Link title tooltips
********************************/

function init_tooltips() {

    // Find some way to make this work with absolute positioned elems
    // Inside relative positioned ones
    
    $("a[title]").hover(function(){
        var parent = {
            top:    $(this).position().top  || $(this).offset().top,
            left:   $(this).position().left || $(this).offset().left,
            height: $(this).outerHeight(),
            width:  $(this).outerWidth()
        };

        this.old_title = this.title;
        this.title = "";

        $("body")
            .append('<div id="tooltip"><div class="arrow"></div>'+ this.old_title +'</div>');

        $("#tooltip")
            .css("top",  (parent.top + parent.height + 5) + "px")
            .css("left", (parent.left + (parent.width /2) - ($('#tooltip').outerWidth() / 2)) + "px")
            .fadeIn(100);

        $("#tooltip .arrow")
            .css("left", ($('#tooltip').outerWidth() / 2) + "px");

    },
    function(){
        this.title = this.old_title;
        $("#tooltip").remove();
    });    
};




