require "rails_helper"

RSpec.describe Industry, type: :model do
  describe "validations" do
    it "requires a name" do
      industry = build(:industry, name: nil)

      expect(industry).not_to be_valid
      expect(industry.errors[:name]).to include("can't be blank")
    end

    it "enforces case-insensitive name uniqueness among top-level industries" do
      create(:industry, name: "EdTech")

      expect(build(:industry, name: "edtech")).not_to be_valid
    end

    it "allows the same name under different parents" do
      create(:segment, name: "Other", parent: create(:industry, name: "EdTech"))

      expect(build(:segment, name: "Other", parent: create(:industry, name: "FinTech"))).to be_valid
    end

    it "rejects an unknown domain_match" do
      expect(build(:industry, domain_match: "sideways")).not_to be_valid
    end

    it "does not allow a segment of a segment" do
      segment = create(:segment)

      expect(build(:industry, parent: segment)).not_to be_valid
    end

    it "does not allow an industry with segments to become a segment" do
      parent = create(:industry)
      create(:segment, parent: parent)

      parent.parent = create(:industry)

      expect(parent).not_to be_valid
    end
  end

  describe "#destroy" do
    it "is blocked while it has segments" do
      parent = create(:industry)
      create(:segment, parent: parent)

      expect(parent.destroy).to be(false)
      expect(Industry.exists?(parent.id)).to be(true)
    end

    it "is blocked while companies use it" do
      industry = create(:industry)
      Company.create!(name: "Used Co", company_type: "Product", user: create(:user), industry: industry)

      expect(industry.destroy).to be(false)
    end
  end

  describe "#full_name" do
    it "joins the parent and segment names" do
      segment = create(:segment, name: "Family Engagement", parent: create(:industry, name: "EdTech"))

      expect(segment.full_name).to eq("EdTech: Family Engagement")
    end

    it "is just the name for a top-level industry" do
      expect(build(:industry, name: "EdTech").full_name).to eq("EdTech")
    end
  end

  describe ".for_select" do
    it "lists each top-level industry directly before its segments" do
      edtech = create(:industry, name: "EdTech")
      create(:segment, name: "K-12", parent: edtech)
      create(:industry, name: "FinTech")

      expect(described_class.for_select.map(&:full_name)).to eq([ "EdTech", "EdTech: K-12", "FinTech" ])
    end
  end

  describe "#self_and_child_ids" do
    it "returns the industry and its segments" do
      parent = create(:industry)
      child = create(:segment, parent: parent)

      expect(parent.self_and_child_ids).to contain_exactly(parent.id, child.id)
      expect(child.self_and_child_ids).to eq([ child.id ])
    end
  end
end
