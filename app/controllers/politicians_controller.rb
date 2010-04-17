class PoliticiansController < ApplicationController
  def index
    @politicians = Politician.find(:all, :order => "name asc")
  end

  def show
    @politician = Politician.find(params[:id])
    
  end
end
