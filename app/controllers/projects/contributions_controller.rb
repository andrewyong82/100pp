class Projects::ContributionsController < ApplicationController
  inherit_resources
  actions :index, :show, :new, :update, :review, :create
  skip_before_filter :verify_authenticity_token, only: [:moip, :bill_paid]
  after_filter :verify_authorized, except: [:index, :bill_paid]
  belongs_to :project
  before_filter :detect_old_browsers, only: [:new, :create]

  helper_method :engine

  def edit
    authorize resource
    if resource.reward.try(:sold_out?)
      flash[:alert] = t('.reward_sold_out')
      return redirect_to new_project_contribution_path(@project)
    end
    return render :existing_payment if resource.payments.exists?
  end

  def update
    authorize resource
    resource.update_attributes(permitted_params)
    resource.update_user_billing_info
    render json: {message: 'updated'}
  end

  def show
    authorize resource
    @title = t('projects.contributions.show.title')
  end

  def new
    @contribution = Contribution.new(project: parent, value: 10)
    authorize @contribution

    @title = t('projects.contributions.new.title', name: @project.name)
    load_rewards

    if params[:reward_id] && (@selected_reward = @project.rewards.find params[:reward_id]) && !@selected_reward.sold_out?
      @contribution.reward = @selected_reward
      @contribution.value = "%0.0f" % @selected_reward.minimum_value
    end
  end

  def create
    @title = t('projects.contributions.create.title')
    @contribution = parent.contributions.new.localized
    @contribution.user = current_user
    @contribution.value = permitted_params[:value]
    @contribution.referral_link = referral_link
    @contribution.reward_id = (params[:contribution][:reward_id].to_i == 0 ? nil : params[:contribution][:reward_id])
    @contribution.payment_service_fee = @contribution.value.gsub(',','').to_d * 0.15
    authorize @contribution
    @contribution.update_current_billing_info
    create! do |success,failure|
      failure.html do
        flash[:alert] = resource.errors.full_messages.to_sentence
        load_rewards
        render :new
      end
      success.html do
        flash[:notice] = nil
        session[:thank_you_contribution_id] = @contribution.id
        return redirect_to edit_project_contribution_path(project_id: @project.id, id: @contribution.id)
      end
    end
    @thank_you_id = @project.id
  end

  def prepare_bill
    authorize resource
    resource.update_attributes(permitted_params)

    url = "https://www.billplz.com/api/v2/bills"
    data = {
        :collection_id => CatarseSettings[:billplz_collection_id],
        :email => @contribution.payer_email,
        :name => @contribution.payer_name,
        :amount => (@contribution.value + @contribution.payment_service_fee) * 100,
        :callback_url => CatarseSettings[:base_url] + bill_paid_path,
        :metadata => { :project => @project.name },
        :redirect_url => CatarseSettings[:base_url] + project_contribution_path(project_id: @project.id, id: @contribution.id)
    }
    response = HTTParty.post(url,
                             :body => data,
                             :basic_auth => { :username => CatarseSettings[:billplz_key] }
    )

    # create transaction
    response_data = JSON.parse(response.body)
    attributes = {
        contribution: @contribution,
        value: @contribution.value,
        payment_method: "Bill",
        gateway_id: response_data['id'],
        gateway: 'Billplz',
        gateway_data: response_data,
        gateway_fee: @contribution.payment_service_fee,
        installments: 1
    }
    payment = PaymentEngines.new_payment(attributes)
    payment.save!
    payment.payment_notifications.create(contribution_id: payment.contribution_id, extra_data: data)

    render json: response
  end

  def bill_paid
    payment = PaymentEngines.find_payment({ gateway_id: params[:id] })
    if (payment && params[:state] == "paid" && params[:paid])
      payment.pay;
      payment.save!
    end

    render json: payment.to_json
  end

  def prepare_bill_MOLPay
    authorize resource
    resource.update_attributes(permitted_params)

    amount = (@contribution.value + @contribution.payment_service_fee) * 100
    merchantID = 'edspace'
    orderid = @contribution.id
    verifykey = CatarseSettings[:molpay_key]

    vcode = Digest::MD5.hexdigest(amount.to_s + merchantID + orderid.to_s + verifykey)

    url = "https://www.onlinepayment.com.my/MOLPay/pay/​edspace​"
    data = {
        :orderid => orderid,
        :bill_email => @contribution.payer_email,
        :bill_name => @contribution.payer_name,
        :bill_dec => @contribution.project.name,
        :amount => amount,
        :vcode => vcode
    }

    uri = URI(url)
    uri.query = URI.encode_www_form(data)

    # create transaction
    attributes = {
        contribution: @contribution,
        value: @contribution.value,
        payment_method: "CreditCard",
        gateway_id: vcode,
        gateway: 'MOLPay',
        gateway_data: data,
        gateway_fee: @contribution.payment_service_fee,
        installments: 1
    }
    payment = PaymentEngines.new_payment(attributes)
    payment.save!
    payment.payment_notifications.create(contribution_id: payment.contribution_id, extra_data: data)

    render json: { :url => uri.to_s }
  end

  def bill_paid_MOLPay

    vkey = CatarseSettings[:molpay_key]

    tranid = params[:tranID]
    orderid = params[:orderid]
    status = params[:status]
    domain = params[:domain]
    amount = params[:amount]
    currency = params[:currency]
    appcode = params[:appcode]
    paydate = params[:paydate]
    skey = params[:skey]

    key0 = Digest::MD5.hexdigest( tranid + orderid + status + domain + amount + currency )
    key1 = Digest::MD5.hexdigest( paydate + domain + key0 + appcode + vkey )

    if( skey != key1 )
      status = -1
    end

    if ( status == "00" ) #success
      vcode = Digest::MD5.hexdigest(amount.to_s + 'edspace' + orderid.to_s + verifykey)
      payment = PaymentEngines.find_payment({ gateway_id: params[:vcode] })
      if (payment)
        payment.pay;
        payment.save!
      end
    else

    end

    contribution = PaymentEngines.find_contribution(orderid)
    redirect_to project_contribution_path(project_id: contribution.project_id, id: contribution.id)
  end

  # def second_slip
  #   authorize resource
  #   redirect_to resource.details.ordered.first.second_slip_path
  # end

  def toggle_anonymous
    authorize resource
    resource.toggle!(:anonymous)
    return render nothing: true
  end

  protected
  def load_rewards
    empty_reward = Reward.new(minimum_value: 0, description: t('projects.contributions.new.no_reward'))
    @rewards = [empty_reward] + @project.rewards.remaining.order(:minimum_value)
  end

  def permitted_params
    params.require(:contribution).permit(policy(resource).permitted_attributes)
  end

  def engine
    PaymentEngines.find_engine('Pagarme')
  end

end
