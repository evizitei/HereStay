class Subscription
  include ActiveModel::Validations
  include ActiveModel::Dirty
  include ActiveModel::Conversion
  include ActiveModel::AttributeMethods
  include ActiveModel::Callbacks
  extend ActiveModel::Naming
  
  Plans = ['free', 'advanced']
  
  attr_accessor :first_name, :last_name, :address1, :address2, :city,
    :state, :zip, :country, :phone, :ip_address,
    :card_number, :card_verification_value, :card_month, :card_year,
    :change_billing_info,
    :user_id,
    :plan
  
  define_attribute_methods [:plan]
  
  validates_presence_of :plan
  validates_inclusion_of :plan, :in => Plans, :allow_blank => true
  validates_presence_of :user_id

  validates_presence_of :first_name, :last_name,
    :address1, :zip, :card_number, :city,
    :card_verification_value, :card_month, :card_year,
    :if => :require_billing_info_validation

  validate :validate_card_date, :if => :require_billing_info_validation
  
  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end
  
  def user
    @user ||= User.find_by_id(user_id)
  end
  
  def user=(u)
    @user_id = u.try(:id)
    @user = u
  end
  
  def persisted?
    false
  end
  
  def change_billing_info?
    self.change_billing_info === "1" || self.change_billing_info === "true" || self.change_billing_info === true
  end
  
  # require validate billing info if user is not subscribed or change_billing_info? is true
  def require_billing_info_validation
    change_billing_info? || !@user.subscribed?
  end
  
  private
  # get recurly account
  def recurly_account
    @recurly_account ||= Recurly::Account.find(user.id)
    rescue ActiveResource::ResourceNotFound
      @recurly_account = Recurly::Account.create(:account_code => user.id, :email => user.email)
  end
  
  # update billing info
  def update_billing_info!
    billing_info = Recurly::BillingInfo.create(
      :account_code => recurly_account.account_code,
      :first_name => self.first_name,
      :last_name => self.last_name,
      :address1 => self.address1,
      :address2 => self.address2,
      :city => self.city,
      :state => self.state,
      :country => self.country,
      :zip => self.zip,
      :credit_card => {
        :number => self.card_number,
        :year => self.card_year,
        :month => self.card_month,
        :verification_value => self.card_verification_value
      }
    )
    if billing_info.valid?
      true
    else
      self.errors[:base] << billing_info.errors[:base]
      false
    end
  end
  
  # create new or update exisitin subscription
  def create_or_update
    begin
      subscription = Recurly::Subscription.find(recurly_account.account_code)
      subscription.change(self.plan == 'free' ? 'renewal' : 'now', :plan_code => self.plan)
    rescue ActiveResource::ResourceNotFound
      subscription = Recurly::Subscription.create(
        :account_code => recurly_account.account_code,
        :plan_code => self.plan,
        :account => recurly_account,
        :trial_ends_at => 30.days.since
      )
    end
    if subscription.valid?
      user.update_attribute(:subscription_plan, plan)
      true
    else
      self.errors[:base] << subscription.errors[:base]
      return false
    end
  end
  
  def validate_card_date
    card_date = Time.zone.local(self.card_year.to_i, self.card_month.to_i) rescue nil
    if card_date.nil? 
      errors[:card_year] = 'should be valid date'
      errors[:card_month] = 'should be valid date'
    elsif card_date < Time.zone.now
      errors[:card_year] = 'must be in the future'
      errors[:card_month] = 'must be in the future'
    end
  end
  
  public
  
  def save
    update_billing_info! if change_billing_info?
    create_or_update
  end
  
  # cancel subscription and remove payment info
  def destroy
    subscription = Recurly::Subscription.find(recurly_account.account_code)
    Recurly::Subscription.delete(recurly_account.account_code)

    billing_info = Recurly::BillingInfo.find(recurly_account.account_code)
    billing_info.destroy
    user.update_attribute(:subscription_plan, nil)
  end
end