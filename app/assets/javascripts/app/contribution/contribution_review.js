App.addChild('ReviewForm', _.extend({
  el: 'form#review_form',

  events: {
    'blur input' : 'checkInput',
    'change #contribution_address_state' : 'checkInput',
    'change #contribution_country_id' : 'onCountryChange',
    'change #contribution_anonymous' : 'toggleAnonymousConfirmation',
    'change #toggle-fee' : 'toggleFee',
    'change #toggle-creditcard' : 'toggleCreditCard',
    'click #next-step' : 'onNextStepClick'
  },

  onNextStepClick: function(){
    if(this.validate()){
      this.updateContribution();
      this.$errorMessage.hide();
      //this.$('#next-step').hide();
      //this.parent.payment.show();
      this.$('#next-step').hide();
      this.$('#loader').show();

        if (this.$("#toggle-creditcard").is(":checked"))
        {
            this.prepareBill_MOLPay();
        }
        else
        {
            this.prepareBill();
        }
    }
    else{
      this.$errorMessage.slideDown('slow');
    }
  },

    toggleCreditCardConfirmation: function(){
        this.$('#creditcard-confirmation').slideToggle('slow');
    },

    toggleCreditCard: function(){
        this.toggleCreditCardConfirmation();
        //if (this.$("#toggle-creditcard").is(":checked"))
        //{
        //    var fee = 0.15 * parseFloat($("#contribution_value").val());
        //    this.$("#contribution_payment_service_fee").val(fee);
        //    this.$("#bill-amount").text((parseFloat($("#contribution_value").val()) + parseFloat($("#contribution_payment_service_fee").val())).toFixed(2));
        //}
        //else{
        //    this.$("#contribution_payment_service_fee").val(0);
        //    this.$("#bill-amount").text(parseFloat($("#contribution_value").val()).toFixed(2));
        //}
    },

    toggleFeeConfirmation: function(){
        this.$('#fee-confirmation').slideToggle('slow');
    },

    toggleFee: function(){
        this.toggleFeeConfirmation();
        if (this.$("#toggle-fee").is(":checked"))
        {
            var fee = 0.15 * parseFloat($("#contribution_value").val());
            this.$("#contribution_payment_service_fee").val(fee);
            this.$("#bill-amount").text((parseFloat($("#contribution_value").val()) + parseFloat($("#contribution_payment_service_fee").val())).toFixed(2));
        }
        else{
            this.$("#contribution_payment_service_fee").val(0);
            this.$("#bill-amount").text(parseFloat($("#contribution_value").val()).toFixed(2));
        }
    },

  toggleAnonymousConfirmation: function(){
    this.$('#anonymous-confirmation').slideToggle('slow');
  },

  onCountryChange: function(){
    if(this.$country.val() == '145'){
      this.nationalAddress();
    }
    else{
      this.internationalAddress();
    }
  },

  internationalAddress: function(){
    this.$state.data('old_value', this.$state.val());
    this.$state.val('other');
    this.makeFieldsOptional();
  },

  makeFieldsRequired: function(){
    this.$('[data-required-in-brazil]').prop('required', 'required');
    this.$('[data-required-in-brazil]').parent().removeClass('optional').addClass('required');
  },

  makeFieldsOptional: function(){
    this.$('[data-required-in-brazil]').prop('required', false);
    this.$('[data-required-in-brazil]').parent().removeClass('required').addClass('optional');
  },

  nationalAddress: function(){
    if(this.$state.data('old_value')){
      this.$state.val(this.$state.data('old_value'));
    }
    this.makeFieldsRequired();
  },

  activate: function(){
    this.$country = this.$('#contribution_country_id');
    if(this.$country.val() === ''){
      this.$country.val('36');
    }
    this.$state = this.$('#contribution_address_state');
    this.$errorMessage = this.$('#error-message');
    this.setupForm();
    this.onCountryChange();
  },

  updateContribution: function(){
    var contribution_data = {
      anonymous: this.$('#contribution_anonymous').is(':checked'),
      country_id: this.$('#contribution_country_id').val(),
      payer_name: this.$('#contribution_payer_name').val(),
      payer_email: this.$('#contribution_payer_email').val(),
      payer_document: this.$('#contribution_payer_document').val(),
      address_street: this.$('#contribution_address_street').val(),
      address_number: this.$('#contribution_address_number').val(),
      address_complement: this.$('#contribution_address_complement').val(),
      address_neighbourhood: this.$('#contribution_address_neighbourhood').val(),
      address_zip_code: this.$('#contribution_address_zip_code').val(),
      address_city: this.$('#contribution_address_city').val(),
      address_state: this.$('#contribution_address_state').val(),
      address_phone_number: this.$('#contribution_address_phone_number').val()
    };
    $.post(this.$el.data('update-info-path'), {
      _method: 'put',
      contribution: contribution_data
    });
  },

    prepareBill: function(){
        var contribution_data = {
            //anonymous: this.$('#contribution_anonymous').is(':checked'),
            //country_id: this.$('#contribution_country_id').val(),
            payer_name: this.$('#contribution_payer_name').val(),
            payer_email: this.$('#contribution_payer_email').val(),
            payment_service_fee: this.$('#contribution_payment_service_fee').val()
            //payer_document: this.$('#contribution_payer_document').val(),
            //address_street: this.$('#contribution_address_street').val(),
            //address_number: this.$('#contribution_address_number').val(),
            //address_complement: this.$('#contribution_address_complement').val(),
            //address_neighbourhood: this.$('#contribution_address_neighbourhood').val(),
            //address_zip_code: this.$('#contribution_address_zip_code').val(),
            //address_city: this.$('#contribution_address_city').val(),
            //address_state: this.$('#contribution_address_state').val(),
            //address_phone_number: this.$('#contribution_address_phone_number').val()
        };
        $.post(this.$el.data('prepare-bill-path'), {
            contribution: contribution_data
        },
            function(response) {
                if (response.error) {

                }
                else {
                    location.href = response.url;
                }
        });
    },

    prepareBill_MOLPay: function() {
        var contribution_data = {
            //anonymous: this.$('#contribution_anonymous').is(':checked'),
            //country_id: this.$('#contribution_country_id').val(),
            payer_name: this.$('#contribution_payer_name').val(),
            payer_email: this.$('#contribution_payer_email').val(),
            payment_service_fee: this.$('#contribution_payment_service_fee').val()
            //payer_document: this.$('#contribution_payer_document').val(),
            //address_street: this.$('#contribution_address_street').val(),
            //address_number: this.$('#contribution_address_number').val(),
            //address_complement: this.$('#contribution_address_complement').val(),
            //address_neighbourhood: this.$('#contribution_address_neighbourhood').val(),
            //address_zip_code: this.$('#contribution_address_zip_code').val(),
            //address_city: this.$('#contribution_address_city').val(),
            //address_state: this.$('#contribution_address_state').val(),
            //address_phone_number: this.$('#contribution_address_phone_number').val()
        };
        $.post(this.$el.data('prepare-bill-MOLPay-path'), {
                contribution: contribution_data
            },
            function(response) {
                if (response.error) {

                }
                else {
                    location.href = response.url;
                }
            });
    }

}, Skull.Form));

