function redirectToFbApp(app_name, path){
  if (window.top === window.self){
    document.write = "";
    window.top.location = 'http://apps.facebook.com/'+ app_name +'/?redirect_to=' + path;
    setTimeout(function(){document.body.innerHTML='';},1);
    window.self.onload=function(evt){document.body.innerHTML='';};
  }
}

function redirectTo(path){
  document.write = "";
  window.location.href = path;
  setTimeout(function(){document.body.innerHTML='';},1);
  window.self.onload=function(evt){document.body.innerHTML='';};
}

function runFbInit(){
  var appID = $('meta[property="og:app_id"]').attr("content");
  FB.init({appId: appID, status: true, cookie: true,xfbml: true});
  FB.Event.subscribe('auth.login', function(response) {       
    reloadLocation();
  });
  FB.Event.subscribe('comments.add', function(r) {
    if(typeof(comment_handler) != "undefined"){
      storeComment();
    }
  }) 
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
        success: newMessages
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
        dataType: "json"
      })
    }
  });  
}

function redrawPhotos(){
  $('#cluetip-inner #preview_images').html($('#picture-fields').html());
  $('.count-photos').html($('#picture-fields .photo').size())
  if($('#picture-fields .photo').size() > 3){
    $('.thumbs-left-logic, .thumbs-right-logic').show();
  }else{
    $('.thumbs-left-logic, .thumbs-right-logic').hide();
  }
}
function customFBloginButton(url){
  FB.login(function(response) {
    if (response.session) {
      window.top.location.href = url;
    } else {
    }
  }, {perms:'publish_stream,offline_access,user_birthday,email,user_location'});
}

function timedRefresh(timeoutPeriod) {
  setTimeout("location.reload(true);",timeoutPeriod);
}

function parseAvailabilityButtons(){
  $('a.availabilities_button').cluetip({
    showTitle: false,
    width: 240,
    height: 'auto',
    sticky: true,
    activation: 'click',
    fx: { open: 'slideDown' },
    ajaxCache: false,
    'ajaxSettings': {},
    closeText: "<img src='/images/close.png'/>"
  });
  $('.calendar .prev-nav a').live('click', function(){
    var parent = $(this).parents('.calendar');
    parent.find('.ajax-loader').show();
    $.get(this.href,{}, function(data){
      parent.replaceWith(data);      
    })
    return false; 
  })
  
}

$(document).ready(function() {
  
  $("#search").textPlaceholder();
  
  /* Initial new message poll */
  checkNewMessages();
  
  parseAvailabilityButtons();
  
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
  
  $('#photo_picture').live('change', function(){
    $(this).parents('form').submit();
    $(this).val('');
    $('.ajax_photo_loader').show();
  })
  
  $('a.change-photo-logic').cluetip({
    showTitle: false,
    width: 350,
    height: 'auto',
    sticky: true,
    activation: 'click',
    local: true, 
    hideLocal: true,
    onShow: function(ct, c){
      redrawPhotos();
    }
  });
  
  $('.remove-picture-logic').live('click', function(){
    if(confirm('Are you sure?')){
      var block = $('#picture-fields #' + $(this).attr('rel'));
      if($('#picture-fields .photo').size() > 1){
        if (($('#primary_photo_id').val() != '') && (block.find('input').val() == $('#primary_photo_id').val())){
          $('#primary_photo_id').val('0');
          $('#primary_photo').attr('src','/images/no_photo.png');
        }
        block.remove();
      }else{
        alert("You can't delete last photo! You must upload new photo before.");
      }
      redrawPhotos();
    }
    return false;
  })
  
  $('.make-primary-logic').live('click', function(){
    $('#picture-fields .photo').removeClass('primary');
    $('#picture-fields #ph' + $(this).attr('rel')).addClass('primary');
    $('#primary_photo_id').val($(this).attr('rel'));
    $('#primary_photo').attr('src',$('#picture-fields #ph' + $(this).attr('rel') + ' img').attr('src'));
    redrawPhotos();
    return false;
  })
  
  $('.thumbs-right-logic').live('click', function () {
    $('#picture-fields .photo:first').clone().appendTo("#picture-fields");
    $('#picture-fields .photo:first').remove();
    redrawPhotos();
    return false;
  }, {  duration: 400, speed: 0.95, min: 200  })
  
  $('.thumbs-left-logic').live('click', function () {
    $('#picture-fields .photo:last').clone().prependTo("#picture-fields");
    $('#picture-fields .photo:last').remove();
    redrawPhotos();
    return false;
  }, {  duration: 400, speed: 0.95, min: 200  })
  
  $('.load-remote-photo-logic').live('click', function(){
    $('.ajax_photo_loader').show();
    var rel = $(this).attr('rel');
    $.post('/photos/ajaxupload_remote',{'remote_photo': this.href}, function(data){
       $('#picture-fields .photo').removeClass('primary');
       $('#picture-fields #rph' + rel).replaceWith(data);
       $('#primary_photo_id').val($('#picture-fields .primary input').val());
       $('#primary_photo').attr('src',$('#picture-fields .primary img').attr('src'));
       redrawPhotos();
       $('.ajax_photo_loader').hide();
    })
    return false;
  })
  $('.terminate-chat-logic').live('click', function(){
    if(confirm('Are you sure?')){
      var parent = $(this).parents('.property'); 
      $.post(this.href, {}, function(){
        parent.remove();
      })      
    } 
    return false;   
  })
});