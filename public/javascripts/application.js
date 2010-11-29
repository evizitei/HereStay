function redirectToFbApp(app_name, path){
  if (window.top === window.self){
    document.write = "";
    window.top.location = 'http://apps.facebook.com/'+ app_name +'/?redirect_to=' + path;
    setTimeout(function(){document.body.innerHTML='';},1);
    window.self.onload=function(evt){document.body.innerHTML='';};
  }
}

function newMessages(data){
  var messages = "";
  var count = 0
  $.each(data, function(i, item) {
    messages = messages + "<p>" + item.message +"<a href='"+ item.url +"'>Go To Discussion</a></p>"
    user_data["last_message"] = item.id;
    count++;
    $.jGrowl("<p>" + item.message +"<a href='"+ item.url +"'>Go To Discussion</a></p>");
  });
  
  //$.fancybox(('<h2>New Messages!</h2>' + messages),{
  //      'autoDimensions'	: true,
  //			'width'         		: 'auto','height'        		: 'auto',
  //			'transitionIn'		: 'swing','transitionOut'		: 'swing'
  //});
   //$.jGrowl("new message");
  if(count > 0) {window.location.href = '#top';}
}
function scrollTo(x,y){
        $("body").append('<iframe id="scrollTop" style="border:none;width:1px;height:1px;position:absolute;top:-10000px;left:-100px;" src="" onload="$(\'#scrollTop\').remove();"></iframe>');
    }

function checkNewMessages(chat_check_url){
  if(typeof( window[ 'user_data' ] ) != "undefined" ){
    chat_check_url = user_data.chat_check_url;
    delete user_data.chat_check_url;
    
    setInterval(function() {
      $.ajax({
        url: chat_check_url,
        type: "GET",
              data: user_data,
              dataType: "json",
              success: newMessages,
      })
    }, 10000);
  }
}

$(document).ready(function() {
  /* Initial new message poll */
  checkNewMessages();
  
  /* Initial clue Tips */
  $('a.clueTip').cluetip({
    showTitle: false,
    width: 580,
    height: 'auto',
    sticky: true,
    activation: 'click',
    fx: { open: 'slideDown' },
    ajaxCache: true,
    'ajaxSettings': {dataType: 'script'}
  });
});