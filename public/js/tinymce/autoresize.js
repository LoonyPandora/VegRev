(function(punymce) {

    punymce.plugins.autoresize = function(ed) {

        ed.onInit.add(function() {
            var event     = punymce.Event,
                doc       = ed.getDoc(),
                iframe    = ed.getIfr();

            event.add(doc, 'change', function(e) {
                resize();
            });

            event.add(doc, 'keyup', function(e) {
                resize();
            });

            event.add(doc, 'paste', function(e) {
                resize();
            });

            function resize() {
                var actualHeight  = $(iframe).height(),
                    nativeHeight  = doc.body.scrollHeight,
                    resizeHeight  = nativeHeight - actualHeight;

                if (nativeHeight > actualHeight) {
                    $('iframe').animate({
                        height: actualHeight + resizeHeight + 'px'
                    }, 100);

                    // $(iframe).css({height: actualHeight + resizeHeight + 'px'}).animate('slow');
                }
            }

        });

    };
})(punymce);


