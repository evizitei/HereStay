$(document).ready(function() {
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