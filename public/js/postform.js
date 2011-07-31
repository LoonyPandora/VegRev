$(document).ready(function() {
    // key_binding();
    init_tinymce();
    init_postform();    
});




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



/* Postform functions
********************************/

function init_postform() {
    // Post button in the header
    $("#header a.tooltip_up").click(function() { toggle_postform({
        direction: 'up',
        position: 'fixed',
        nudge: 25,
        link: this,
        fields: ['subject', 'message', 'tag_select']
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

        // Hide all form fields, and only show the ones that are needed.
        // Remember #message becomes tinymce, and .chzn becomes "chosen"
        $('#subject, #message, #tag_select, div.chzn-container').hide();
        $.each(options.fields, function(index, value) {
            if (value === 'tag_select') {
                $('div.chzn-container').show();
                return true;
            }

            $('#'+value).show();
        });
        $("input[type='submit']").show();

        $('#postform div.formcontainer').css({opacity: 0});

        mce_control('add', function() {
            // All fields are visible, the element is in position, TinyMCE is active...
            // Let's GO GO GO!
            $('#postform div.formcontainer').animate({opacity: 1.0}, { duration: 50, complete: function() {
                $('#postform').slideDown(100);
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



    $('.mce_toolbar a.link').click(function() {
        $('ul.mce_toolbar.optional li.add_link').show(0, function() {
            $('ul.mce_toolbar.optional li').not('.add_link').hide();
            $('ul.mce_toolbar.optional').slideToggle(200);
        });

        return false;
    });

    $('.mce_toolbar a.video').click(function() {
        $('ul.mce_toolbar.optional li.add_video').show(0, function() {
            $('ul.mce_toolbar.optional li').not('.add_video').hide();
            $('ul.mce_toolbar.optional').slideToggle(200);
        });

        return false;
    });

    $('.mce_toolbar a.picture').click(function() {
        $('ul.mce_toolbar.optional li.add_picture').show(0, function() {
            $('ul.mce_toolbar.optional li').not('.add_picture').hide();
            $('ul.mce_toolbar.optional').slideToggle(200);
        });

        return false;
    });


    $('.mce_toolbar a.attachment').click(function() {
        $('ul.mce_toolbar.optional li.add_attachment').show(0, function() {
            $('ul.mce_toolbar.optional li').not('.add_attachment').hide();
            $('ul.mce_toolbar.optional').slideToggle(200);
        });

        return false;
    });




    $('.mce_toolbar li.add_link a').click(function() {
        var link = validate_url({ string: $('input.urlbox').val() }),
            title = $('input.titlebox').val() || link;

        // Link isn't valid
        if (!link) {
            return false;
        }

        tinymce.execCommand('mceInsertContent', false, '<a href="'+link+'">'+title+'</a>');
        $('input.urlbox').val('');
        $('input.titlebox').val('');
        $('ul.mce_toolbar.optional').slideUp(200);

        return false;
    });



    $('.mce_toolbar li.add_picture a').click(function() {
        var picture = validate_url({ string: $('li.add_picture input').val(), type: 'image' });

        // Picture isn't valid
        if (!picture) {
            return false;
        }

        // We create a new item in the attachment / image list, and a href
        // a href onclick will remove it from the list.
        $('<li/>')
        .append(
            $('<a/>', {
                href: '#',
                title: 'Thumnail Preview'
            }).click(function() {
                $(this).parent().remove();
                return false;
            }).append(
                $('<img/>', {
                    src: picture,
                    alt: picture,
                })
            )
        ).appendTo($('ul#mce_attachments'));

        return false;
    });


    $('ul#mce_attachments li a').click(function() {
        console.log('clicked');
        return false;
    })


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

function validate_url(options) {
    // Empty
    if (!options.string || options.string == '') {
        return false;
    }

    // Not a Full URL
    if ( options.string.indexOf('http://') !== 0 && options.string.indexOf('https://') !== 0 ) {
        options.string = 'http://' + options.string;
    }

    // Not an image with valid extension
    if (options.type === 'image') {
        var valid_extensions = ['jpeg', 'jpg', 'png', 'gif'],
            extension_regex  = valid_extensions.join('$|\\.');
            extension_regex  = new RegExp('\\.'+extension_regex+'$', 'i');

        if ( !options.string.match(extension_regex) ) {
            return false;
        }
    }

    // It's passed all the tests, so return the link
    return options.string;
}
