# frozen_string_literal: true

class Order < ApplicationRecord
  belongs_to :user
  has_many :order_items, dependent: :destroy
  has_many :notifications, as: :source, dependent: :destroy
  has_many :transactions, as: :source

  # @todo move to enumerate
  enum status: MODELS.dig(:order, :statuses)

  accepts_nested_attributes_for :order_items

  validate :valid_status_change

  after_save :notify_user
  after_save :transactions_controll

  def total_price_with_discounts
    return total_price - coupon_discount if coupon_discount

    total_price
  end

  def apply_coupon(code)
    coupon = Coupon.find_by(code: code)
    unless coupon
      errors.add(:coupon_code_to_apply, 'Invalid')
      return false
    end
    self.coupon_code_to_apply = code
    save
  end

  def coupon_discount
    return nil unless coupon_code_to_apply
    coupon = Coupon.find_by(code: coupon_code_to_apply)
    return nil unless coupon
    coupon.compute_discount(total_price)
  end

  def has_checkout_information?
    status != 'reviewing'
  end

  def can_checkout?
    status == 'reviewed'
  end

  def self.create_from_cart_items!(items:, user:)
    order_items = items.map do |item|
      OrderItem.new(
        supplier_url: item.supplier_url,
        quantity: item.quantity,
        title: item.title,
        description: item.description,
        instructions: item.instructions,
        image_url: item.image_url,
        unit_cost: nil,
        store_price: nil,
        international_shipping: nil,
        lynks_fees: nil,
        taxes_and_customs: nil
      )
    end

    Order.create!(user: user, order_items: order_items)
  end

  def number
    id
  end

  delegate :name, :phone, :email, prefix: :client, to: :user, allow_nil: true

  def valid_for_checkout?
    errors.add(:shipping_full_name, :blank) unless shipping_full_name.present?
    errors.add(:shipping_address_line1, :blank) unless shipping_address_line1.present?
    errors.add(:shipping_city, :blank) unless shipping_city.present?
    return false if errors.any?

    true
  end

  def possible_amount_from_wallet
    total_price_with_discounts > user.wallet_balance ? user.wallet_balance : total_price_with_discounts
  end

  def more_pay_with_wallet
    total_price_with_discounts - possible_amount_from_wallet
  end

  def total_pay_more
    total_price_with_discounts - already_paid
  end

  def already_paid
    -transactions.sum(&:amount)
  end

  def checkout!(params = {})
    assign_attributes(params)

    return false unless valid_for_checkout?

    update status: 'confirmed'
  end

  def shipping_address
    user.shipping_address_line1
  end

  def items_count
    order_items.count
  end

  def subtotal
    return nil unless prices_ready?
    order_items.sum(&:unit_cost)
  end

  def us_shipping_and_taxes
    return nil unless prices_ready?
    order_items.sum(&:us_shipping_and_taxes)
  end

  def total_weight
    return nil unless prices_ready?
    order_items.sum(&:item_weight)
  end

  def international_shipping
    return nil unless prices_ready?
    order_items.sum(&:international_shipping)
  end

  def local_customs_and_taxes
    return nil unless prices_ready?
    order_items.sum(&:taxes_and_customs)
  end

  def fees
    return nil unless prices_ready?
    order_items.sum(&:lynks_fees)
  end

  def prices_ready?
    order_items.all?(&:complete_information?)
  end

  def total_price
    return nil unless prices_ready?
    subtotal + us_shipping_and_taxes + international_shipping +
      local_customs_and_taxes + fees
  end

  private

  def transactions_controll
    return if saved_changes['status'].blank?

    if status == 'confirmed' && (am = possible_amount_from_wallet).positive?
      transactions.deduction.create user: user, amount: -am
    end

    if status == 'paid' && (am = total_pay_more).positive?
      transactions.paid_by_cash.create user: user, amount: -am
    end
  end

  def notify_user
    if saved_changes['status'].present?
      notifications.create(
        user: user,
        text: "Order changed status from
          #{I18n.t(saved_changes['status'].first, scope: %i[order statuses])} to
          #{I18n.t(saved_changes['status'].second, scope: %i[order statuses])}",
        route: 'order',
        params: { id: id }
      )
    end

    ### @todo move to Notification
    # send if reviewed
    OrderMailer.reviewed(self).deliver_now if saved_changes['status'].present? && status == 'reviewed'

    # send if just created
    OrderMailer.created(self).deliver_now if saved_changes['id'] && saved_changes['id'].first.nil?
    ###
  end

  def valid_status_change
    return true unless status == 'reviewed'
    return true if order_items.all?(&:ready_to_review?)
    errors.add(:status, 'Data of all items should be completed before review')
  end
end
