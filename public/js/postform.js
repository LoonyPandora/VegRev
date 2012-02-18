$(document).ready(function() {
    init_tinymce();

    // Workaround for tinyMCE in a modal
    // https://github.com/twitter/bootstrap/issues/549
    $('#postform').bind('shown', function() {
        mce_control('remove');
    });

    $('#postform').bind('shown', function() {
        mce_control('add');
    });
    
    $('#postform').bind('hide', function() {
        mce_control('remove');
    });


    $('#tag_select').chosen();


    $('#messageform').submit(function() { 
        // inside event callbacks 'this' is the DOM element so we first 
        // wrap it in a jQuery object and then invoke ajaxSubmit 
        $(this).ajaxSubmit(); 
 
        // !!! Important !!! 
        // always return false to prevent standard browser submit and page navigation 
        return false; 
    }); 



});




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

    $('#message').tinymce({
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

        height: 140,
        min_height: 140,
        autoresize_min_height: 140,
        autoresize_bottom_margin: 40,

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
    $('.mce_toolbar .sprite-edit-bold a').click(      function() { tinymce.execCommand('bold');          return false; });
    $('.mce_toolbar .sprite-edit-italic a').click(    function() { tinymce.execCommand('italic');        return false; });
    $('.mce_toolbar .sprite-edit-underline a').click( function() { tinymce.execCommand('underline');     return false; });
    $('.mce_toolbar .sprite-edit-strike a').click(    function() { tinymce.execCommand('strikethrough'); return false; });

    $('.mce_toolbar .sprite-edit-alignment-left a').click(  function() { tinymce.execCommand('justifyleft');   return false; });
    $('.mce_toolbar .sprite-edit-alignment-center a').click(  function() { tinymce.execCommand('justifycenter'); return false; });
    $('.mce_toolbar .sprite-edit-alignment-right a').click( function() { tinymce.execCommand('justifyright');  return false; });

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

    $('.mce_toolbar .sprite-edit-highlight a').click(function() {
        tinymce.execCommand('ForeColor', false, '#ffff00');
        tinymce.execCommand('HiLiteColor', false, '#ffff00');
        return false;
    });

    // TODO trigger a re-render efficiently
    $('.mce_toolbar.emoticons').click(function() {
        tinymce.execCommand('mceInsertContent', false, ':\)&nbsp;');
        return false;
    });

    $('.mce_toolbar .sprite-edit-quotation a').click(function() {
        tinymce.execCommand('mceBlockQuote');
        return false;
    });



    // Items that load a sub toolboar
    $('.mce_toolbar .sprite-link a').click(function() {
        $('ul.mce_toolbar.add_link').stop(true, true).slideToggle(200);
        return false;
    });

    $('.mce_toolbar .sprite-youtube a').click(function() {
        $('ul.mce_toolbar.add_youtube').stop(true, true).slideToggle(200);
        return false;
    });

    $('.mce_toolbar .sprite-picture a').click(function() {
        $('ul.mce_toolbar.add_picture').stop(true, true).slideToggle(200);
        return false;
    });

    $('.mce_toolbar .sprite-attachment a').click(function() {
        $('ul.mce_toolbar.add_attachment').stop(true, true).slideToggle(200);
        return false;
    });

    $('.mce_toolbar .sprite-emoticon a').click(function() {
        $('ul.mce_toolbar.emoticons').stop(true, true).slideToggle(200);
        return false;
    });

    $('.mce_toolbar .sprite-edit-extra a').click(function() {
        $('ul.mce_toolbar.extra_formatting').stop(true, true).slideToggle(200);
        return false;
    });



    // Functions within the secondary toolbar
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
        return false;
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
