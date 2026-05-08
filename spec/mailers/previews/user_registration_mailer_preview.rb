# Preview all emails at http://localhost:3000/rails/mailers/user_registration_mailer_mailer
class UserRegistrationMailerPreview < ActionMailer::Preview
    def welcome
        user = User.first || User.new(
            first_name: "Demo",
            email: "demo@example.com"
        )

        UserRegistrationMailer.welcome(user)
    end
end
