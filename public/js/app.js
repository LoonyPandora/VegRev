


/* On Page Ready
********************************/

$(document).ready(function() {
    event_binding();
    key_binding();
    init_tooltips();
    init_gallery();
    init_hashgrid();
    init_tabs();
    // enable_punymce();
    enable_tinymce();
});




function emote_to_name(emote) {
    var emote_name;

    $.each(emoticons, function(title) {
        $.each(emoticons[title], function(index) {
            if (emoticons[title][index] === emote) {
                emote_name = title;
            }
        });
    });
    
    return emote_name;
}

var emoticons = {
      smiley : [':)', '=)'],
      unhappy : [':|', '=|'],
      sad : [':(','=('],
      grin : [':D', '=D'],
      surprised : [':o',':O','=o', '=O'],
      wink : [';)'],
      halfhappy : [':/', '=/'],
      tongue : [':P', ':p', '=P', '=p'],
      lol : [],
      mad : [],
      rolleyes : [],
      cool : []
    },
    emoReg = '';

$.each(emoticons, function(title) {
    $.each(emoticons[title], function(index) {
        if (emoReg.length != 0) {
            emoReg += '|';
        }
              
        emoReg += emoticons[title][index].replace(/([^a-zA-Z0-9])/g, '\\$1');
    });
});

emoReg = new RegExp(emoReg, 'g');



function enable_tinymce() {
  $('textarea#message').tinymce({
       // Location of TinyMCE script
       script_url : '/js/tinymce/tiny_mce_src.js',
       // mode : "textareas",
       // General options
       theme : "advanced",
       plugins : "paste,autoresize",

       // Theme options
       theme_advanced_buttons1 : "bold,italic,underline,strikethrough,|,justifyleft,justifycenter,justifyright,fontselect,fontsizeselect,|,forecolor,backcolor,|,sub,sup",
       theme_advanced_buttons2 : "",
       theme_advanced_buttons3 : "",
       theme_advanced_buttons4 : "",
       theme_advanced_toolbar_location : "top",
       theme_advanced_toolbar_align : "left",
       theme_advanced_resizing : false,

       // Example content CSS (should be your site CSS)
       content_css : "/css/punymce.css",

       setup : function(editor) {
         editor.onKeyUp.add(function(editor, o) {
            var text    = editor.getContent(),
                rawtext = editor.getContent({noprocess: true});

            var newtext = text.replace(emoReg, function(a) {
                return '<img class="emoticon" title="' + a + '" src="img/emoticons/'+emote_to_name(a)+'.gif" alt="'+emote_to_name(a)+'" />';
            });

            if (rawtext === newtext) {
                return;
            } else {
                editor.setContent(newtext);
                var last_idx = editor.dom.select('img.emoticon').length - 1;
                editor.selection.select(editor.dom.select('img.emoticon')[last_idx]);
                editor.selection.collapse(0);
            }
         }),

         editor.onPreProcess.add(function(editor, o) {
             if (o.noprocess) {
                 return;
             } else {
                $.each($(o.node).find('img.emoticon'), function(n) {
                   $(this).replaceWith($(this).attr('title'));
                });
             }
         });

       }               
  });
}



function enable_punymce() {

    // <script src="<%= config('static_url') %>/js/punymce/plugins/emoticons/emoticons.js"></script>
    // <script src="<%= config('static_url') %>/js/punymce/plugins/editsource/editsource.js"></script>
    // <script src="<%= config('static_url') %>/js/punymce/plugins/autoresize.js"></script>
    // <script src="<%= config('static_url') %>/js/punymce/plugins/foreblocks.js"></script>
    // <script src="<%= config('static_url') %>/js/punymce/plugins/bbcode.js"></script>
    // <script src="<%= config('static_url') %>/js/punymce/plugins/paste.js"></script>
    // <script src="<%= config('static_url') %>/js/punymce/plugins/tabfocus.js"></script>
    // <script src="<%= config('static_url') %>/js/punymce/plugins/forcenl.js"></script>

    var message = new punymce.Editor({
        id : 'message',
        content_css: '/css/punymce.css',
        editor_css: false,
        toolbar : 'bold',
        spellcheck: true,
        plugins: 'Emoticons,autoresize,EditSource,ForceBlocks,Protect,BBCode',
        // plugins : 'BBCode,Image,Emoticons,Link,Protect,TextColor,EditSource,Safari2x',
        min_width : 530,
        max_width : 530,
        min_height: 60,
        height: 60,
        width : 530,
        resize : true,
        entities : 'numeric',
        emoticons : {
            auto_convert : true
        }
    });


    $('.puny_toolbar a').click(function() {
        message.execCommand('Bold');

        message.resizeBy(0, -20);

        return false;
    });

   
};










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



/* Binding to elements & keys
********************************/

function event_binding() {
    postform_binding();
    all_page_navigation_binding();
    show_quotes();
}


function key_binding() {
  $(document).keyup(function (e) {
    var keyCode = e.keyCode,
    key = { left: 37, up: 38, right: 39, down: 40, space: 32, esc: 27 };

    switch (keyCode) {
      case key.esc:
        close_postform();
      break;
    }
  });
}



/* Showing quoted messages
********************************/

function show_quotes() {
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



/* Link title tooltips
********************************/

function init_tooltips() {
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




/* All pages sub navigation
********************************/

function all_page_navigation_binding() {
    $('#navigation li.pagecount').click(function() {

        if ($('#wrapper').css('margin-top') !=  '70px') {
            $('#wrapper').animate( { marginTop: '70px' }, { queue: false, duration: 100 } );
        } else {
            $('#wrapper').animate( { marginTop: '100px' }, { queue: false, duration: 100 } );
        }

        $('#all_page_navigation').slideToggle(100);

        return false;
    });
}




/* Postform functions
********************************/

function postform_binding() {
    // Post button in the header
    $("#header a.tooltip_up").click(function() { postform_init(this, {
        direction: 'up',
        position: 'fixed',
        nudge: 25,
        fields: ['subject', 'message']
    });
        return false;
    });

    // Replying to an individual message
    $(".actions a.post_reply").click(function() { postform_init(this, {
        direction: 'up',
        position: 'absolute',
        nudge: 15,
        fields: ['message']
    });
        return false;
    });

    $("#close_postform").click(function() { close_postform(); return false; } );


}


function close_postform() {
    $("#postform").fadeOut(100, function() {
        $('.message .meta, #header a.tooltip_up').removeClass('active_postform_link');
        $('.message .meta').animate( { marginBottom: '0px' }, { queue: false, duration: 100 } );
    });
}


function show_postform(options) {
    // Remove any other arrows before adding a new one.
    $('#postform .arrow').remove();
    $("<div/>", { 'class': 'arrow ' + options.direction })
        .appendTo("#postform")
        .css("top",  options.tip_vertical   + 'px')
        .css("left", options.tip_horizontal + 'px');


    // Finally fade in the form
    $("#postform")
        .css("top",     options.alignment.top)
        .css("right",   options.alignment.bottom)
        .css("bottom",  options.alignment.bottom)
        .css("left",    options.alignment.left)
        .fadeIn(200, function() {
            // focus textarea for easy typing
            // $("#message").focus();
    });
            
}


function postform_init(elem, options) {

    // Default the position values
    options['alignment'] = { top: 'auto', left: 'auto', bottom: 'auto', right:  'auto'};

    // Always do the moving & hiding when the form is hidden
    // It's real ugly otherwise...
    $("#postform").fadeOut(50, function(){
    
        // Determine if this is a reply link, or a new post link
        var meta_elem = $(elem).parent('li').parent('.actions').parent('.meta'),
            is_reply  = meta_elem.length == 1 ? true : false;

        // We've clicked on the same link twice, close up the reply box, and return
        if (is_reply && $(meta_elem).css('margin-bottom') != '0px') {
            $(meta_elem).animate( { marginBottom: '0px' }, { queue: false, duration: 100 } );
            return;
        } else if (!is_reply){
            toggle_postform(elem, options, meta_elem, is_reply);
            return;
        }

        // Slide up all messages except the one we've clicked
        $('.message .meta').not($(meta_elem)).animate( { marginBottom: '0px' }, {
            queue:    false,
            duration: 100,
            complete: function() {
                toggle_postform(elem, options, meta_elem, is_reply);
            }
        });

    });
}


function toggle_postform(elem, options, meta_elem, is_reply) {

    // We've clicked the same link twice - so keep the postform closed & return.
    if ( $(elem).hasClass('active_postform_link') ) {
        $(elem).removeClass('active_postform_link');
        return;
    }

    // Remove all other instances of the active class before applying it to the clicked link
    $('.active_postform_link').removeClass('active_postform_link');
    $(elem).addClass('active_postform_link');

    // Set the position
    $("#postform").css("position", options.position);

    // Show the actual form fields
    $('#postform input, #postform textarea, #postform label, #punymce_container').hide();
    $("input[type='submit']").show();

    $.each(options.fields, function(index, value) { 
        // $("label[for='" + value + "']").show();
        
        // Special case #message - because it's punymce
        
        if (value == 'message') {
            $('#punymce_container').show();
        } else {
            $('#'+value).show();
        }
        
    });

    // Calculate dimensions, AFTER we've done all the resizing / hiding / showing of elements
    var parent = {
        top:    $(elem).position().top  || $(elem).offset().top,
        left:   $(elem).position().left || $(elem).offset().left,
        height: $(elem).outerHeight(),
        width:  $(elem).outerWidth()
    };

    var tooltip = {
        width:  $("#postform").outerWidth(),
        height: $("#postform").outerHeight()
    };

    // Sort out alignment around the element we clicked on, depending on arrow direction
    // NOTE the word is the direction the arrow points - NOT the side that the box appears on
    switch (options.direction) {
      case 'up':
        options.alignment.top     = (parent.top + parent.height + options.nudge) + 'px';
        options['tip_horizontal'] = (parent.left + (parent.width / 2)) - ($('#wrapper').offset().left + 120);
        options['tip_vertical']   = 10;
        break;
      case 'right':
        options.alignment.top      = (parent.top + (parent.height / 2) - (tooltip.height / 2)) + 5 + 'px';
        options['tip_horizontal']  = (tooltip.width);
        options['tip_vertical']    = (tooltip.height / 2) + (parent.height / 2);
        break;
    };

    // Slide the message area down if it's a reply, we've already slid all others back up
    if (is_reply) {
        $(meta_elem).animate( { marginBottom: tooltip.height + 25 + 'px' }, { queue: false, duration: 100, complete: function() {
            show_postform(options);
        }});
    } else {
        if ($('.message .meta').length > 0) {
            $('.message .meta').animate( { marginBottom: '0px' }, { queue: false, duration: 100, complete: function() {
                show_postform(options);
            }});
        } else {
            show_postform(options);
        }
    }

}


