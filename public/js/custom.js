/******************************************************************************
  custom.js
  =============================================================================
  Version:		Vegetable Revolution 4.0
  Released:		1st January 2010
  Revision:		$Rev$
  Copyright:	James Aitken <http://www.loonypandora.com>
******************************************************************************/


function insert_quote(message_id) {
  
  message.selection.setContent(message_id);
  
  $("#message_f").focus();
  $("#punymce").focus();  
}

function insert_smiley(code, name) {
  message.selection.setContent('&nbsp;');

  message.selection.setNode(
    message.dom.create('img', { title : code || name, src : '/img/emoticons/' + name + '.gif', 'class' : 'emoticon ' + name })
  );
  
  $("#message_f").focus();
  $("#punymce").focus();  
}

function show_panel(id) {
  // We can't use a toggle here, because the first selector hides the div we want to show
  if ($('#'+id).css("display") == 'none') {
    $('.footer_popup_container').hide();
    $('#'+id).show();
  } else {
    $('#'+id).hide();
  }


  $("#message_f").focus();
  $("#punymce").focus();
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
