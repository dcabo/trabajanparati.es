class Item < ActiveRecord::Base
  belongs_to :statement
  
  PROPERTY = 'P'
  FUND = 'F'
  INSURANCE = 'I'
  VEHICLE = 'V'
  CASH = 'C'
  LIABILITY = 'L'
end
