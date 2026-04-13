require "rails_helper"

RSpec.describe Company, type: :model do
  let(:user) { create(:user) }

  describe "validations" do
    it "validates name presence" do
      company = Company.new(name: nil, company_type: "Product", user: user)

      expect(company).not_to be_valid
      expect(company.errors[:name]).to include("can't be blank")
    end

    it "validates name uniqueness case-insensitively" do
      unique_name = "Acme Corp #{SecureRandom.hex(4)}"
      Company.create!(name: unique_name, company_type: "Product", user: user)
      duplicate = Company.new(name: unique_name.downcase, company_type: "Product", user: user)

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:name]).to include("has already been taken")
    end

    it "normalizes whitespace in name before validation" do
      company = Company.new(name: "  New   Co  ", company_type: "Product", user: user)

      company.validate

      expect(company.name).to eq("New Co")
    end
  end
end
