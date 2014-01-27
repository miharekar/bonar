class Updates < ActionMailer::Base
  default from: 'Boni<info@mr.si>'

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.updates.restaurant.subject
  #
  def restaurant(report)
    @faulty = report[:faulty]

    @new = report[:new] || []
    @new = @new.map{ |spid| Restaurant.find_by(spid: spid) }

    @disabled = report[:disabled] || []
    @disabled = @disabled.map{ |spid| Restaurant.find_by(spid: spid) }

    @new_features = report[:new_features] || []
    @new_features = @new_features.map{ |spid| Feature.find_by(spid: spid) }

    mail to: 'Miha Rekar<info@mr.si>', subject: 'Bonar restaurants update report'
  end
end
