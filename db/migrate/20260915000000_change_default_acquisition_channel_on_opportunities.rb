class ChangeDefaultAcquisitionChannelOnOpportunities < ActiveRecord::Migration[8.0]
  def change
    change_column_default :opportunities, :acquisition_channel, from: "unknown", to: "cold_application"
  end
end
