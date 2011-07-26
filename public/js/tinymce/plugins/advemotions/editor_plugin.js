/**
 * editor_plugin_src.js
 *
 * Copyright 2009, Moxiecode Systems AB
 * Released under LGPL License.
 *
 * License: http://tinymce.moxiecode.com/license
 * Contributing: http://tinymce.moxiecode.com/contributing
 */

(function(tinymce) {
    
    function emote() {
            var emoticons = {
            happy : [':)', '=)'],
            unhappy : [':|', '=|'],
            sad : [':(','=('],
            grin : [':D', '=D'],
            surprised : [':o',':O','=o', '=O'],
            wink : [';)'],
            halfhappy : [':/', '=/'],
            tounge : [':P', ':p', '=P', '=p'],
            lol : [],
            mad : [],
            rolleyes : [],
            cool : []
        };

            console.log(emoticons);

    }
    
    
    tinymce.create('tinymce.plugins.AdvancedEmotionsPlugin', {
        init : function(ed, url) {

            emote();
        },

        getInfo : function() {
            return {
                longname : 'Advanced Emotions',
                author : 'James Aitken',
                authorurl : 'http://www.loonypandora.co.uk',
                infourl : 'http://www.loonypandora.co.uk',
                version : '1.0'
            };
        }
    });

    // Register plugin
    tinymce.PluginManager.add('advemotions', tinymce.plugins.AdvancedEmotionsPlugin);
})(tinymce);
