require 'rails_helper'

RSpec.describe SendWelcomeEmailJob, type: :job do
  let(:user) { create(:user) }

  it "queues the job" do
    expect {
      described_class.perform_later(user)
  }.to have_enqueued_job.with(user)
  end
end
