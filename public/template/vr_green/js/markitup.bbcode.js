// ----------------------------------------------------------------------------
// markItUp!
// ----------------------------------------------------------------------------
// Copyright (C) 2008 Jay Salvat
// http://markitup.jaysalvat.com/
// ----------------------------------------------------------------------------
mySettings = {
  nameSpace:          "bbcode", // Useful to prevent multi-instances CSS conflict
  markupSet: [
      {name:'Bold', key:'B', openWith:'[b]', closeWith:'[/b]'}, 
      {name:'Italic', key:'I', openWith:'[i]', closeWith:'[/i]'}, 
      {name:'Underline', key:'U', openWith:'[u]', closeWith:'[/u]'}, 
      {name:'Strike', openWith:'[s]', closeWith:'[/s]'}, 
      {name:'Spoiler', openWith:'[spoiler]', closeWith:'[/spoiler]'}, 
      {separator:'---------------' },
      {name:'Picture', key:'P', replaceWith:'[img][![Image URL:]!][/img]'}, 
      {name:'Flash', replaceWith:'[flash][![YouTube Video / Flash File URL:]!][/flash]'}, 
      {name:'Link', key:'L', openWith:'[url=[![Link URL:]!]]', closeWith:'[/url]', placeHolder:'Your text to link here...'},
      {separator:'---------------' },
      {name:'Colors', dropMenu: [
          {name:'Yellow', openWith:'[color=yellow]', closeWith:'[/color]', className:"col1-1" },
          {name:'Orange', openWith:'[color=orange]', closeWith:'[/color]', className:"col1-2" },
          {name:'Red', openWith:'[color=red]', closeWith:'[/color]', className:"col1-3" },
          {name:'Blue', openWith:'[color=blue]', closeWith:'[/color]', className:"col2-1" },
          {name:'Purple', openWith:'[color=purple]', closeWith:'[/color]', className:"col2-2" },
          {name:'Green', openWith:'[color=green]', closeWith:'[/color]', className:"col2-3" },
          {name:'White', openWith:'[color=white]', closeWith:'[/color]', className:"col3-1" },
          {name:'Gray', openWith:'[color=gray]', closeWith:'[/color]', className:"col3-2" },
          {name:'Black', openWith:'[color=black]', closeWith:'[/color]', className:"col3-3" },
      ]},
      {name:'Size', key:'S', dropMenu :[
          {name:'8px', openWith:'[size=8]', closeWith:'[/size]' },
          {name:'10px', openWith:'[size=10]', closeWith:'[/size]' },
          {name:'12px', openWith:'[size=12]', closeWith:'[/size]' },
          {name:'16px', openWith:'[size=16]', closeWith:'[/size]' },
          {name:'21px', openWith:'[size=21]', closeWith:'[/size]' },
          {name:'36px', openWith:'[size=36]', closeWith:'[/size]' },
          {name:'48px', openWith:'[size=48]', closeWith:'[/size]' },
          {name:'72px', openWith:'[size=72]', closeWith:'[/size]' },
      ]},
      {name:'Font', key:'S', dropMenu :[
          {name:'Verdana', openWith:'[font="Verdana"]', closeWith:'[/font]' },
          {name:'Impact', openWith:'[font="Impact"]', closeWith:'[/font]' },
          {name:'Comic Sans', openWith:'[font="Comic Sans MS"]', closeWith:'[/font]' },
          {name:'Courier New', openWith:'[font="Courier New"]', closeWith:'[/font]' },
          {name:'Georgia', openWith:'[font="Georgia"]', closeWith:'[/font]' },
          {name:'Trebuchet', openWith:'[font="Trebuchet MS"]', closeWith:'[/font]' },
          {name:'Webdings', openWith:'[font="Webdings"]', closeWith:'[/font]' },
      ]},
      {separator:'---------------' },
      {name:'Quotes', openWith:'[quote]', closeWith:'[/quote]'}, 
      {name:'Code', openWith:'[code]', closeWith:'[/code]'}, 
      {separator:'---------------' },
      {name:'Left', openWith:'[left]', closeWith:'[/left]'}, 
      {name:'Center', openWith:'[center]', closeWith:'[/center]'}, 
      {name:'Right', openWith:'[right]', closeWith:'[/right]'}, 
      {separator:'---------------' },
      {name:'Sup', openWith:'[sup]', closeWith:'[/sup]'}, 
      {name:'Sub', openWith:'[sub]', closeWith:'[/sub]'}, 
      {name:'Move', openWith:'[move]', closeWith:'[/move]'}, 
      {name:'Edit', openWith:'[edit]', closeWith:'[/edit]'}, 
   ]
};

var mySmileys = new Array(
'<ul id="emoticon_bar" style="clear: both;">',
'<li class="markItUpButton button_smiley"><a href="#" title=" :)">:)</a></li>',
'<li class="markItUpButton button_wink"><a href="#" title=" ;)">;)</a></li>',
'<li class="markItUpButton button_cheesy"><a href="#" title=" :D">:D</a></li>',
'<li class="markItUpButton button_grin"><a href="#" title=" ;D">;D</a></li>',
'<li class="markItUpButton button_smug"><a href="#" title=" /:)">/:)</a></li>',
'<li class="markItUpButton button_angry"><a href="#" title=" &gt;:(">&gt;:(</a></li>',
'<li class="markItUpButton button_sad"><a href="#" title=" :(">:(</a></li>',
'<li class="markItUpButton button_shocked"><a href="#" title=" :o">:o</a></li>',
'<li class="markItUpButton button_cool"><a href="#" title=" 8-)">8-)</a></li>',
'<li class="markItUpButton button_huh"><a href="#" title=" :?">:?</a></li>',
'<li class="markItUpButton button_rolleyes"><a href="#" title=" ::)">::)</a></li>',
'<li class="markItUpButton button_tongue"><a href="#" title=" :P">:P</a></li>',
'<li class="markItUpButton button_embarassed"><a href="#" title=" :[">:[</a></li>',
'<li class="markItUpButton button_lipsrsealed"><a href="#" title=" :X">:X</a></li>',
'<li class="markItUpButton button_undecided"><a href="#" title=" :-/">:-/</a></li>',
'<li class="markItUpButton button_kiss"><a href="#" title=" :*">:*</a></li>',
'<li class="markItUpButton button_cry"><a href="#" title=" :\'(">:\'(</a></li>',
'<li class="markItUpButton button_evil"><a href="#" title=" &gt;:D">&gt;:D</a></li>',
'<li class="markItUpButton button_thumbsup"><a href="#" title=" ^^d">^^d</a></li>',
'</ul>'
).join("\n");