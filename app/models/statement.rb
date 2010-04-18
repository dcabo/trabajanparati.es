class Statement < ActiveRecord::Base
  belongs_to :politician
  has_many :items
  has_many :activities
  
  def total_assets
    total_cash + total_property + total_funds + total_vehicles
  end
  
  def net_worth
    total_assets - total_liabilities
  end
end
