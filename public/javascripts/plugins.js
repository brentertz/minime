/*
Use for jQuery plugins and other 3rd party scripts. 
Put jQuery plugins inside of the (function($){ ... })(jQuery); closure to make sure they're in 
the jQuery namespace safety blanket, especially if they were written by more amateur developers.
*/

// remap jQuery to $
(function($){
 



})(this.jQuery);

// usage: log('inside coolFunc',this,arguments);
// paulirish.com/2009/log-a-lightweight-wrapper-for-consolelog/
window.log = function(){
  log.history = log.history || [];   // store logs to an array for reference
  log.history.push(arguments);
  if(this.console){
    console.log( Array.prototype.slice.call(arguments) );
  }
};

// catch all document.write() calls
// see https://github.com/paulirish/html5-boilerplate/wiki/FAQs
(function(doc){
  var write = doc.write;
  doc.write = function(q){ 
    log('document.write(): ',arguments); 
    if (/docwriteregexwhitelist/.test(q)) write.apply(doc,arguments);  
  };
})(document);