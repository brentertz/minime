/*
Application.js should hold your primary application script.
http://paulirish.com/2009/markup-based-unobtrusive-comprehensive-dom-ready-execution/
*/
$(function(){
	$.ajaxSetup({ 
	  'beforeSend': function(xhr) {
	    xhr.setRequestHeader("Accept", "text/javascript");
	  }
	});
});	