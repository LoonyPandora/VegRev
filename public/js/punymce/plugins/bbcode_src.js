(function(punymce) {
	punymce.plugins.BBCode = function(ed) {
		// Convert XML into BBCode
		ed.onGetContent.add(function(ed, o) {
			if (o.format == 'bbcode' || o.save) {
				// example: <strong> to [b]
				punymce.each([
				  [/<(br\s*\/)>/gi, "\n"],
    			[/<a href=\"(.*?)\".*?>(.*?)<\/a>/gi,"[url=$1]$2[/url]"],

					[/<[^<]*color=\"#ffff00\"[^<]*>(.*?)<\/font>/gi,"[spoiler]$1[/spoiler]"],

					[/<[^<]*color=\"([^\"]+)\"[^<]*>(.*?)<\/font>/gi,"[color=$1]$2[/color]"],
					
					// Have to to these individually, since we have execCommand and want it in pixels
					[/<[^<]*size=\"1\"[^<]*>(.*?)<\/font>/gi,"[size=8]$1[/size]"],
					[/<[^<]*size=\"2\"[^<]*>(.*?)<\/font>/gi,"[size=10]$1[/size]"],
					[/<[^<]*size=\"3\"[^<]*>(.*?)<\/font>/gi,"[size=12]$1[/size]"],
					[/<[^<]*size=\"4\"[^<]*>(.*?)<\/font>/gi,"[size=14]$1[/size]"],
					[/<[^<]*size=\"5\"[^<]*>(.*?)<\/font>/gi,"[size=18]$1[/size]"],
					[/<[^<]*size=\"6\"[^<]*>(.*?)<\/font>/gi,"[size=24]$1[/size]"],
					[/<[^<]*size=\"7\"[^<]*>(.*?)<\/font>/gi,"[size=36]$1[/size]"],


					[/<[^<]*face=\"([^\"]+)\"[^<]*>(.*?)<\/font>/gi,"[font=$1]$2[/font]"],
					[/<[^<]*font-family: ([^\"]+);[^>]*>(.*?)<\/span>/gi,"[font=$1]$2[/font]"],


					[/<[^<]*font-size: x-small;[^>]*>(.*?)<\/span>/gi,"[size=8]$1[/size]"],
					[/<[^<]*font-size: small;[^>]*>(.*?)<\/span>/gi,"[size=10]$1[/size]"],
					[/<[^<]*font-size: medium;[^>]*>(.*?)<\/span>/gi,"[size=12]$1[/size]"],
					[/<[^<]*font-size: large;[^>]*>(.*?)<\/span>/gi,"[size=14]$1[/size]"],
					[/<[^<]*font-size: x-large;[^>]*>(.*?)<\/span>/gi,"[size=18]$1[/size]"],
					[/<[^<]*font-size: xx-large;[^>]*>(.*?)<\/span>/gi,"[size=24]$1[/size]"],
					[/<[^<]*font-size: -webkit-xxx-large;[^>]*>(.*?)<\/span>/gi,"[size=36]$1[/size]"],



					[/<[^<]*center[^<]*>(.*?)<\/div>/gi,"[center]$1[/center]"],
					[/<[^<]*right[^<]*>(.*?)<\/div>/gi,"[right]$1[/right]"],
					[/<[^<]*left[^<]*>(.*?)<\/div>/gi,"$1"],


					[/<img.*?src=\"([^\"]+)\".*?\/>/gi,"[img]$1[/img]"],
					[/<(br\s*\/)>/gi, "\n"],
          [/<p.*?title=\"([^\"]+)\|([^\"]+)\|([^\"]+)\|([^\"]+)\".*?>(.*?)<\/p>/gi,"[quotemeta][name]$1[/name][thread]$2[/thread][post]$3[/post][timestamp]$4[/timestamp][/quotemeta]"],
					
    			[/<(\/?)(blockquote)[^>]*>/gi, "[$1quote]"],
					[/<(\/?)(strong|b)>/gi, "[$1b]"], // BRs get matched by this... see below.
					[/<(\/?)(em|i)[^>]*>/gi, "[$1i]"],
					[/<(\/?)s>/gi, "[$1s]"], // Spans get matched by this, if we do a [^>]* - gives us erroneous [s] tags...
					[/<(\/?)u[^>]*>/gi, "[$1u]"],
					[/<(\/?)(code|pre)[^>]*>/gi, "[$1code]"],
					[/<p>/gi, ""],
					[/<\/p>/gi, ""],
					[/&quot;/gi, "\""],
					[/&lt;/gi, "<"],
					[/&gt;/gi, ">"],
					[/&amp;/gi, "&"],
					[/<[^>]+>/gi, ""]
				], function (v) {
					o.content = o.content.replace(v[0], v[1]);
				});
			}
		});

		ed.onSetContent.add(function(ed, o) {
			if (o.format == 'bbcode' || o.load) {
				// example: [b] to <strong>
				punymce.each([
    			[/\[(\/?)b\]/gi,"<$1strong>"],
					[/\[(\/?)i\]/gi,"<$1em>"],
					[/\[(\/?)u\]/gi,"<$1u>"],
					[/\[(\/?)s\]/gi,"<$1s>"],
					[/\[(\/?)code\]/gi,"<$1pre>"],
					[/\[url\](.*?)\[\/url\]/gi,"<a href=\"$1\">$1</a>"],
					[/\[url=([^\]]+)\](.*?)\[\/url\]/gi,"<a href=\"$1\">$2</a>"],
					[/\[img\](.*?)\[\/img\]/gi,"<img src=\"$1\" />"],
					[/\[spoiler\](.*?)\[\/spoiler\]/gi,"<font color=\"#ffff00\">$1</font>"],
					[/\[color=(.*?)\](.*?)\[\/color\]/gi,'<font color=\"$1\">$2</font>'],
				], function (v) {
					o.content = o.content.replace(v[0], v[1]);
				});
			}
		});
	};
})(punymce);
