(function($){
	var initLayout = function() {
		$('#myGallery').spacegallery({loadingClass: 'loading'});
	};
	
	EYE.register(initLayout, 'init');
})(jQuery)