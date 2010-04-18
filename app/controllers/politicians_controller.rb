class PoliticiansController < ApplicationController
  caches_page :index, :show
  
  def index
    @politicians = Politician.find(:all, :order => "name asc")
  end

  def show
    @politician = Politician.find(params[:id])
  end
end
