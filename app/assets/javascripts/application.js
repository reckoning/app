//= require jquery
//= require jquery.turbolinks
//= require jquery_ujs
//= require spin.js/spin
//= require ladda/js/ladda
//= require noty/js/noty/packaged/jquery.noty.packaged.min
//= require sifter/sifter
//= require microplugin/src/microplugin
//= require selectize/dist/js/selectize
//= require bootstrap
//= require dynamic_fields_for
//= require i18n
//= require i18n/translations
//= require moment/moment
//= require moment_init
//= require twix/bin/twix
//= require d3/d3
//= require nvd3/nv.d3
//= require accounting/accounting
//= require nprogress/nprogress
//= require pdf.js/build/pdf
//= require pdf_viewer
//= require helper
//= require_tree ./helpers
//= require tabs
//= require app
//= require_tree ./app
//= require timesheet
//
//= require turbolinks

$(document).on('page:fetch',   function() { NProgress.start(); });
$(document).on('page:change',  function() { NProgress.done(); });
$(document).on('page:restore', function() { NProgress.remove(); });

$(document).on('show.bs.collapse', '.navbar-collapse', function() {
  $('.navbar-collapse.in').not(this).collapse('hide');
});

$(function() {
  $('.btn.btn-loading').click(function() {
    $(this).button('loading');
  });

  $('#blueimp-gallery').data('useBootstrapModal', false);
});

