class UserRegistrationMailer < ApplicationMailer
    def welcome(user)
        @user = user

        mail(
            to: @user.email,
            subject: "Welcome to My Career Intel"
        )
    end
end
