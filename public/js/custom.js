/******************************************************************************
  custom.js
  =============================================================================
  Version:		Vegetable Revolution 4.0
  Released:		1st January 2010
  Revision:		$Rev$
  Copyright:	James Aitken <http://www.loonypandora.com>
******************************************************************************/


function change_page(current_route) {
  var selected = $("#page_selector option:selected");
  window.location.replace(current_route+'/'+selected.val());
}

function puny_text_color(color) {
  focus_editor();
  message.execCommand('backcolor', 0, '#ffffff');
  message.execCommand('hilitecolor', 0, '#ffffff');
  message.execCommand('forecolor', 0, color);
}

function puny_font_face(face) {
  focus_editor();
  message.execCommand('fontname', 0, face);
}

function puny_unhighlight() {
  focus_editor();
  
  message.execCommand('forecolor', 0, '#000000');
  message.execCommand('backcolor', 0, '#ffffff');
  message.execCommand('hilitecolor', 0, '#ffffff');

  $('#highlight_button').show();
  $('#unhighlight_button').hide();
}


function puny_highlight() {
  focus_editor();

  message.execCommand('forecolor', 0, '#ffff00');
  message.execCommand('backcolor', 0, '#ffff00');
  message.execCommand('hilitecolor', 0, '#ffff00');
  
  $('#highlight_button').hide();
  $('#unhighlight_button').show();
}

function puny_flash_insert(address) {
  // We just add a jpeg, it's a PITA to get a live flash vid. And also useless
  
  focus_editor();
  var youtube = /youtube\.com/i.test(address);
  
  if (youtube) {
    var tmp   = address.replace(/watch\?v=/g,'vi\/');
    var embed = tmp.replace(/http:\/\/.+youtube\.com\//g,'http:\/\/img.youtube.com\/');
    embed = embed + '/2.jpg';

    message.execCommand('insertimage', 0, embed);

  }
}


// TODO: Fix the Line-Height
function puny_text_size(size) {
  focus_editor();

  if (size == 'reset') {
    message.execCommand('removeformat', 0, false);
  } else {
    message.execCommand('fontsize', 0, size);
  }
}


function insert_quote(message_id, thread_id, user_name, display_name, message_time) {
    
  var container_id = '#'+message_id;
  
  
  // HACK HACK HACK - we have to quickly show and hide the punymce area
  // Otherwise we can't insert anything...
  show_panel('reply_to_thread');
//  show_panel('reply_to_thread');

  message.selection.setContent('<blockquote><p class="quotemeta xsmall" title="'+display_name+'|'+thread_id+'|'+message_id+'|'+message_time+'">Quote: <a href="/forum/board/'+thread_id+'/post/'+message_id+'">'+display_name+'</a></p>'+$(container_id).html()+'</blockquote><br />');

  focus_editor();
}

function insert_smiley(code, name) {
  focus_editor();

  message.selection.setContent('&nbsp;');

  message.selection.setNode(
    message.dom.create('img', { title : code || name, src : '/img/emoticons/' + name + '.gif', 'class' : 'emoticon ' + name })
  );
  
  message.selection.setContent('&nbsp;');  
  
  focus_editor();
}

function show_panel(id) {
  // We can't use a toggle here, because the first selector hides the div we want to show
  if ($('#'+id).css("display") == 'none') {
    $('.footer_popup_container').hide();
    $('#'+id).show();
  } else {
    $('#'+id).hide();
  }

  focus_editor();
}


function toggle_quotes(id) {
  if ($('#'+id).height() != '10') {
    $('#'+id).animate({height: "10px"}, 100);
  } else {
    $('#'+id).animate({height: "100%"}, 100); // I know this doesn't work, but hey.
  }

}

function add_poll_option() {
	var id = document.getElementById("number_of_options").value;
	var prev_id = (id - 1);

  if (id < 33) {
  	$("#poll_options_container").append('<label for="poll_option_'+ id +'" id="poll_label_'+ id +'" class="column two tight">Option ' + id + ':</label><input type="text" id="poll_option_'+ id +'" name="poll_option_'+ id +'" class="required column nine flush" /><span class="column flush pollbuttons" id="pollbuttons_'+ id +'"><a href="javascript:add_poll_option();"><img src="/img/silk/add.png" /></a><a href="javascript:del_poll_option('+ id +');"><img src="/img/silk/delete.png" /></a></span>');


  	$("#pollbuttons_"+prev_id).remove();

  	id = (id - 1) + 2;
  	document.getElementById("number_of_options").value = id;
  }
}

function del_poll_option(id) {
	prev_id = (id - 1);
	$("#pollbuttons_"+id).remove();
	$("#poll_option_"+id).remove();
	$("#poll_label_"+id).remove();
	if (prev_id == 2) {
		$("#poll_options_container").append('<span class="column flush pollbuttons" id="pollbuttons_'+ prev_id +'"><a href="javascript:add_poll_option();"><img src="/img/silk/add.png" /></a></span>');
	} else {
		$("#poll_options_container").append('<span class="column flush pollbuttons" id="pollbuttons_'+ prev_id +'"><a href="javascript:add_poll_option();"><img src="/img/silk/add.png" /></a><a href="javascript:del_poll_option('+ prev_id +');"><img src="/img/silk/delete.png" /></a></span>');
	}
	document.getElementById("number_of_options").value = id;
}


function focus_editor() {
  $("#message_f").focus();
  $("#punymce").focus();
  
  message.execCommand('styleWithCSS', 0, false);
}


