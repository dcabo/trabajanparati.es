class StatementsController < ApplicationController
  caches_page :show
  
  def show
    # TODO: Don't look, don't look, it's so ugly...
    if (params[:item_type]!='N')
      @items = Item.find_all_by_statement_id_and_item_type(params[:id], params[:item_type])
      @total_amount = @items.inject(0) {|sum, i| sum += i.value }
    else
      s = Statement.find(params[:id])
      @items = s.items
      @total_amount = s.net_worth
    end
    
    render :partial => "statement.erb"
  end
end
