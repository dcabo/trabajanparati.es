class Statement < ActiveRecord::Base
  belongs_to :politician
  has_many :items
end
