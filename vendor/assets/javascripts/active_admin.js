//= require active_admin/base

$( document ).ready(function() {

  $('li#issue_submit_action input').click(function() {
    //alert( "Handler for .click() called." );
    $('input#issue_file').after('<span style="background-color: blue; color: white; padding: 5px; margin-left: 10px;">Uploading...</span>');
  });

}) 
