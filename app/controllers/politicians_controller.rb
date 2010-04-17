class PoliticiansController < ApplicationController
  def index
    @politicians = Politician.find(:all)
  end

  def show
  end
end
