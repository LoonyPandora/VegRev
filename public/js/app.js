


/* On Page Ready
********************************/

$(document).ready(function() {
    key_binding();
    init_tooltips();
    init_gallery();
    init_hashgrid();
    init_tabs();
    init_tinymce();
    init_postform();
    init_quotes();
});












/* COMPLETE FUNCTIONS
********************************/


/* Sets up TinyMCE
********************************/


function emo_regex() {
    var emoticons = init_emoticons(),
        emoRegex  = '';

    $.each(emoticons, function(title) {
        $.each(emoticons[title], function(index) {
            if (emoRegex.length != 0) {
                emoRegex += '|';
            }
            emoRegex += emoticons[title][index].replace(/([^a-zA-Z0-9])/g, '\\$1');
        });
    });

    emoRegex = new RegExp(emoRegex, 'g');
    
    return emoRegex;
}

function emote_to_name(emote) {
    var emoticons = init_emoticons(),
        emote_name;

    $.each(emoticons, function(title) {
        $.each(emoticons[title], function(index) {
            if (emoticons[title][index] === emote) {
                emote_name = title;
            }
        });
    });

    return emote_name;
}

function init_emoticons() {
    var emoticons = {
        smiley:     [':)', '=)'],
        unhappy:    [':|', '=|'],
        sad:        [':(', '=('],
        grin:       [':D', '=D'],
        surprised:  [':o', ':O', '=o', '=O'],
        wink:       [';)'],
        halfhappy:  [':-/', '=/'],
        tongue:     [':P', ':p', '=P', '=p'],
        lol:        [],
        mad:        [],
        rolleyes:   [],
        cool:       []
    };

    return emoticons;
}

function init_tinymce() {
    var emoRegex = emo_regex();
    tinymce_binding();

    $('#postform textarea#message').tinymce({
        theme: "advanced",
        skin: "vegrev",
        plugins: "paste,autoresize,tabfocus",

        paste_auto_cleanup_on_paste: true,
        paste_block_drop: true,
        paste_strip_class_attributes: 'all',
        paste_remove_spans: true,
        paste_remove_styles: true,

        theme_advanced_buttons1: "",
        theme_advanced_buttons2: "",
        theme_advanced_buttons3: "",
        theme_advanced_buttons4: "",
        theme_advanced_toolbar_location: "top",
        theme_advanced_toolbar_align: "left",
        theme_advanced_resizing: true,
        theme_advanced_resize_horizontal : false,

        relative_urls: false,

        height: 80,
        min_height: 80,
        autoresize_min_height: 80,
        autoresize_bottom_margin: 20,

        setup: function(editor) {
            editor.onKeyUp.add(function(editor, o) {
                var text    = editor.getContent(),
                    rawtext = editor.getContent({
                        noprocess: true
                    });

                var newtext = text.replace(emoRegex,
                function(a) {
                    return '<img class="emoticon" title="' + a + '" src="/img/emoticons/' + emote_to_name(a) + '.gif" alt="' + emote_to_name(a) + '" />';
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
                    $.each($(o.node).find('img.emoticon'),
                    function(n) {
                        $(this).replaceWith($(this).attr('title'));
                    });
                }
            });

        }
    });

}

function tinymce_binding() {
    $('.mce_toolbar a.bold').click(      function() { tinymce.execCommand('bold');          return false; });
    $('.mce_toolbar a.italic').click(    function() { tinymce.execCommand('italic');        return false; });
    $('.mce_toolbar a.underline').click( function() { tinymce.execCommand('underline');     return false; });
    $('.mce_toolbar a.strike').click(    function() { tinymce.execCommand('strikethrough'); return false; });

    $('.mce_toolbar a.left').click(   function() { tinymce.execCommand('justifyleft');   return false; });
    $('.mce_toolbar a.center').click( function() { tinymce.execCommand('justifycenter'); return false; });
    $('.mce_toolbar a.right').click(  function() { tinymce.execCommand('justifyright');  return false; });

    $('.mce_toolbar a.sup').click( function() { tinymce.execCommand('superscript'); return false; });
    $('.mce_toolbar a.sub').click( function() { tinymce.execCommand('subscript');   return false; });


    $('.mce_toolbar select.fontname').change(function() {
        tinymce.execCommand('FontName', false, $(this).val());
        return false;
    });

    $('.mce_toolbar select.fontsize').change(function() {
        tinymce.execCommand('FontSize', false, $(this).val());
        return false;
    });

    $('.mce_toolbar select.fontcolor').change(function() {
        tinymce.execCommand('ForeColor', false, $(this).val());
        tinymce.execCommand('HiLiteColor', false, '#fff');
        return false;
    });


    $('.mce_toolbar a.spoiler').click(function() {
        tinymce.execCommand('ForeColor', false, '#ffff00');
        tinymce.execCommand('HiLiteColor', false, '#ffff00');
        return false;
    });

    // TODO trigger a re-render efficiently
    $('.mce_toolbar.emoticons').click(function() {
        tinymce.execCommand('mceInsertContent', false, ':\)&nbsp;');
        return false;
    });

    $('.mce_toolbar a.quote').click(function() {
        tinymce.execCommand('mceBlockQuote');
        return false;
    });

    $('#get_content').click(function() {
        console.log($('#postform textarea#message').html());
    });

}

function mce_control(type, callback) {
    // So we can have a callback when we've completed
    if (type === 'add') {
        tinymce.execCommand( 'mceAddControl', false, 'message' );
    } else {
        tinymce.execCommand( 'mceRemoveControl', false, 'message' );
    }

    if (callback && typeof(callback) === "function") {
        callback();
    }
}




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



/* Binds escape to close form
********************************/

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



/* Postform functions
********************************/

function init_postform() {
    // Post button in the header
    $("#header a.tooltip_up").click(function() { toggle_postform({
        direction: 'up',
        position: 'fixed',
        nudge: 25,
        link: this,
        fields: ['subject', 'message']
    });
        return false;
    });

    // Replying to an individual message
    $(".actions a.post_reply").click(function() { toggle_postform({
        direction: 'up',
        position: 'static',
        nudge: 15,
        link: this,
        fields: ['message']
    });
        return false;
    });

    $("#close_postform").click(function() { close_postform(); return false; } );
}

function toggle_postform(options) {
    // Set some defaults
    options.alignment = { top: 'auto', left: 'auto', bottom: 'auto', right:  'auto'};
    options.parent    = {
        top:    $(options.link).position().top  || $(options.link).offset().top,
        left:   $(options.link).position().left || $(options.link).offset().left,
        height: $(options.link).outerHeight(),
        width:  $(options.link).outerWidth()
    };

    // Hide the postform, and move it about while hidden.
    $('#postform').slideUp(100, function() {
        // We've clicked the same link twice, so leave it hidden
        if ( $(options.link).hasClass('active_postform_link') ) {
            $(options.link).removeClass('active_postform_link');
            return;
        }

        // Remove TinyMCE as it goes wonky when its moved about in the DOM
        mce_control('remove');

        if (options.position === 'static') {
            show_inline_postform(options);
        } else {
            show_fixed_postform(options);
        }

        // Remove all other instances of the active class before applying it to the clicked link
        $('.active_postform_link').removeClass('active_postform_link');
        $(options.link).addClass('active_postform_link');

        // Hide all form fields, and only show the ones that are needed Remember textarea#message becomes tinymce
        $('#postform input, #postform textarea, #postform label').hide();
        $.each(options.fields, function(index, value) {  $('#'+value).show(); });
        $("input[type='submit']").show();

        $('#postform div.formcontainer').css({opacity: 0});

        mce_control('add', function() {
            // All fields are visible, the element is in position, TinyMCE is active...
            // Let's GO GO GO!
            $('#postform div.formcontainer').animate({opacity: 1.0}, { duration: 50, complete: function() {
                $('#postform').slideDown(200);
            } });
            
        });
    });
}

function create_postform_arrow(options) {

    switch (options.direction) {
      case 'up':
        options.alignment.top  = (options.parent.top + options.parent.height + options.nudge) + 'px';
        options.tip_horizontal = (options.parent.left + (options.parent.width / 2)) - ($('#wrapper').offset().left + 120);
        options.tip_vertical   = 0;
        break;
      case 'right':
        options.alignment.top  = (options.parent.top + (options.parent.height / 2) - ($("#postform").outerHeight() / 2)) + 5 + 'px';
        options.tip_horizontal = $("#postform").outerWidth();
        options.tip_vertical   = ($("#postform").outerHeight() / 2) + (options.parent.height / 2);
        break;
    };

    // Remove any other arrows before adding a new one.
    $('#postform .arrow').remove();
    $("<div/>", { 'class': 'arrow ' + options.direction })
        .prependTo("#postform")
        .css("top", options.tip_vertical + 'px')
        .css("left", options.tip_horizontal + 'px');

}

function show_fixed_postform(options) {
    $("#postform").appendTo($('#wrapper'));
    $("#postform").css("position", options.position);

    create_postform_arrow(options);

    $("#postform")
        .css("top",         options.alignment.top)
        .css("right",       options.alignment.bottom)
        .css("bottom",      options.alignment.bottom)
        .css("left",        options.alignment.left)
        .css("margin-left", '120px');
}

function show_inline_postform(options) {
    var meta_container = $(options.link).parent().parent().parent();
    $(meta_container).after($('#postform'));
    $(meta_container).css('margin-bottom', options.nudge + 'px');

    create_postform_arrow(options);

    $("#postform")
        .css("position",    options.position)
        .css("margin-left", '0px');
}

function close_postform() {
    $("#postform").slideUp(100, function() {
        $('.active_postform_link').removeClass('active_postform_link');
    });
}


