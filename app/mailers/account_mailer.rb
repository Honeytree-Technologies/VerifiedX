class AccountMailer < ApplicationMailer


  def confirmation_instructions(account)
    @account = account
    mail(to: account.email, subject: 'Confirmation instructions')
  end

end
