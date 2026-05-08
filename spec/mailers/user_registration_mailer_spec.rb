require "rails_helper"

RSpec.describe UserRegistrationMailer, type: :mailer do
  describe "#welcome" do
    let(:user) { create(:user, email: "test@example.com") }

    subject(:mail) { described_class.welcome(user) }

    it "renders the subject" do
      expect(mail.subject).to eq("Welcome to My Career Intel")
    end

    it "send to the correct user" do
      expect(mail.to).to eq([ "test@example.com" ])
    end

    it "render the body" do
      expect(mail.body.encoded).to include(user.email)
    end
  end
end
