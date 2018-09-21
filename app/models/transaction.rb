class Transaction < ApplicationRecord
  belongs_to :user

  # for ex.: User(admin that added balance from admin page), 
  # Order(in case money charged from user's wallet to some order)
  belongs_to :source, polymorphic: true, optional: true

  enumerate :transaction_type

  monetize :amount_cents

  after_create_commit :charge_user

  protected

  def charge_user
    return unless deduction?

    user.update wallet_balance: user.wallet_balance + amount
  end
end
