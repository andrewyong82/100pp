var App = window.App = Skull.View.extend({
  el: 'html',

  events: {
    "click #close-global-alert" : "closeAlert",
    "click a#user-menu" : "toggleMenu",
    "click a.mobile-menu-link" : "mobileMenu",
    "click .zendesk_widget" : "showWidget",
    "click #pg_search_submit" : "searchProject",
  },

    openAlert: function(){
        if($('#global-alert').length === 0 || this.$('body').data('mobile')){
            return;
        }
        if($('#fixed-alert').length > 0 && !this.$('body').data('mobile')){
            $('#fixed-alert').addClass('fixed-alert-visible');
            $('.main-header, .hero-search').addClass('with-fixed-alert');
            this.fixedAlert = true;
        }
        if(!window.store.get('globalClosedCookies2')){
            $('#global-alert').slideDown(400);
            $('.main-header').addClass('with-global-alert');
            if(this.fixedAlert){
                $('.main-header, #global-alert').addClass('with-two-alerts');
            }
        }

    },

    closeAlert: function(event){
        $('#global-alert').slideUp(400);
        $('.main-header').removeClass('with-global-alert').removeClass('with-two-alerts');
        window.store.set('globalClosedCookies2', true);
        this.globalAlert = false;
    },

  searchProject: function(){
    this.$('.discover-form:visible').submit();
    return false;
  },

  beforeActivate: function(){
    this.$search = this.$('#pg_search');
    this.router = new Backbone.Router();
  },

  activate: function(){
      this.openAlert();
      if (this.$(".best_in_place").best_in_place)
        this.$(".best_in_place").best_in_place();
      this.$dropdown = this.$('.dropdown-list.user-menu');
      this.flash();
      this.notices();
      Backbone.history.start({pushState: false});
      this.maskAllElements();
      this.applyErrors();
      this.countdown();
  },

    countdown: function() {
        var e = jQuery(".countdown");
        if (e.length > 0) {
            e.each(function () {
                var e = jQuery(this),
                    t = e.attr("data-from"),
                    a = e.attr("data-labels");
                if (a && (a = a.split(",")), t) {
                    var r = new Date(t);
                    jQuery(this).countdown({
                        until: new Date(r),
                        labels: a || ["Years", "Months", "Weeks", "Days", "Hours", "Minutes", "Seconds"]
                    })
                }
            });
        }
    },

  flash: function() {
    var that = this;
    this.$flash = this.$('.flash');

    setTimeout( function(){ that.$flash.slideDown('slow'); }, 100);
    if( ! this.$('.flash a').length) setTimeout( function(){ that.$flash.fadeOut('slow'); }, 5000);
    $(window).click(function(){ that.$('.flash a').slideUp(); });
  },

  notices: function() {
    var that = this;
    setTimeout( function(){ this.$('.notice-box').fadeIn('slow'); }, 100);
    if(this.$('.notice-box').length) setTimeout( function(){ that.$('.notice-box').fadeOut('slow'); }, 16000);
    $('.icon-close').on('click', function(){ that.$('.card-notification').fadeOut('slow'); });

  },

  maskAllElements: function(){
    this.$('input[data-fixed-mask]').each(function(){
      $(this).fixedMask();
    });
  },

  showWidget: function(){
    Zenbox.show();
    return false;
  },

  toggleMenu: function(){
    this.$dropdown.toggleClass('w--open');
    return false;
  },

  applyErrors: function(){
    $.each($('[data-applyerror=true]'), function(i, item){
      $(item).addClass('error');
    });
  },

  isMobile: function(){
    var isMobile = /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent);
    return isMobile;
  }

});

$(function(){
  var app = window.app = new App();
  window.toggleMenu = app.toggleMenu;
});
