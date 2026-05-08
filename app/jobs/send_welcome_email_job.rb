class SendWelcomeEmailJob < ApplicationJob
  queue_as :default

  def perform(user)
    UserRegistrationMailer.welcome(user).deliver_now
  end
end
