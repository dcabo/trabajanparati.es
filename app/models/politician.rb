class Politician < ActiveRecord::Base
  has_many :statements, :order => 'event_date DESC'
end
