function redirectToFbApp(app_name, path){
  if (window.top === window.self){
    document.write = "";
    window.top.location = 'http://apps.facebook.com/'+ app_name +'/?redirect_to=' + path;
    setTimeout(function(){document.body.innerHTML='';},1);
    window.self.onload=function(evt){document.body.innerHTML='';};
  }
}

function runFbInit(){
  var appID = $('meta[property="og:app_id"]').attr("content");
  FB.init({appId: appID, status: true, cookie: true,xfbml: true});
}

function showFBComments(el){
  var target = $(el);
  xid = target.attr('xid') || 'true';
  canpost = target.attr('canpost') || 'true';
  candelete = target.attr('candelete') || 'false';
  width = target.attr('width') || 380;
  numposts = target.attr('numposts') || 4;
  send_notification_uid = target.attr('send_notification_uid') || '';
  $(target).replaceWith('<fb:comments xid="'+xid+'" canpost="'+canpost+'" candelete="'+candelete+'" showform="true" publish_feed="true" width='+width+' numposts='+numposts+' send_notification_uid="'+send_notification_uid+'"/>');
  FB.XFBML.parse(target.parent()[0]);
}

function newMessages(data){
  var messages = "";
  var count = 0
  $.each(data, function(i, item) {
    //messages = messages + "<p>" + item.message +"<a href='"+ item.url +"'>Go To Discussion</a></p>"
    user_data["last_message"] = item.id;
    count++;
    message = "<p><b>You have new message:</b><br/>" + item.message +"<br/><a href='"+ item.url +"'>Click to show</a></p>";
    $.jGrowl(message, { life: 20000 });
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

function rentalUnitShare(data){
  var share = {
    method: 'stream.publish',
    display: 'iframe',
    user_message_prompt: 'Share your thoughts about this property',
    message: data.message,
    attachment: {
      name: data.name,
      description: data.description,
      href: data.url,
      media: [
        {
          type: 'image', 
          src: data.image,
          href: data.url
         }
      ]
    }
  };
  FB.ui(share, function(response) {
    if (response && response.post_id) {
      url = '/rental_units/' + data.id + '/store_last_post'
      $.ajax({
        url: url,
        data: {post_id: response.post_id},
        type: "POST",
        dataType: "json",
      })
    }
  });
  
}

$(document).ready(function() {
  /* Initial new message poll */
  checkNewMessages();
  
  /* Initial clue Tips */
  $('a.availabilities_button').cluetip({
    showTitle: false,
    width: 300,
    height: 360,
    sticky: true,
    activation: 'click',
    fx: { open: 'slideDown' },
    ajaxCache: true,
    'ajaxSettings': {dataType: 'script'},
    onShow: function(ct, c){
      $('.calendar').fullCalendar('today');
    }
  });
  
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
  
  $('a.fb_share').click(function(){
    var el = $(this);
    $.ajax({
      url: this.href,
      type: "GET",
      dataType: "json",
      success: function(data){
        rentalUnitShare(data);        
        $('.fb_dialog').prepend('<a name="fb_bottom" style="position:absolute;top:-100px;z-index:9999999999999;"></a>');
        window.location.href = '#fb_bottom';
      }
    })
    return false;
  })
  
  $('.to_back_logic').live('click', function(){
    $(this).parents('form').attr('action','');
    $('#edit_rental_unit').val(1);
    $(this).parents('form').submit();
    return false;
  })
  
  $('#photo_picture').change(function(){
    $(this).parents('form').submit();
    $('#preview_img').attr('src', '/images/ajax_small.gif')
  })
  
  $('#rental_unit_primary_photo_attributes_picture').focus(function(){
    $(this).click();
  });
  
  $('.fb_comments').click(function(){showFBComments(this); return false});
});