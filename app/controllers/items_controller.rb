class ItemsController < ApplicationController
  
  before_filter :logged_in, :only => [ :edit, :update, :create, :destroy, :borrow ]
  
  def index
    fetch_items
  end
  
  def show
    session[:previous_page] = request.request_uri
    @title = params[:id]
    @items = Item.find(:all, :conditions => "title = '" + params[:id].capitalize + "'")
    fetch_items
    render :action => :index
  end
  
  def edit
    @editable_item = Item.find(params[:id])
    @person = Person.find(params[:person_id])
    show_profile
    render :template => "people/show" 
  end
  
  def update
    @person = Person.find(params[:person_id])
    if params[:item][:cancel]
      redirect_to person_path(@person) and return
    end  
    @item = Item.find(params[:id])
    if @item.update_attribute(:title, params[:item][:title])
      flash[:notice] = :item_updated
    else 
      flash[:error] = :item_could_not_be_updated
    end    
    redirect_to person_path(@person)
  end
  
  def create
    @item = Item.new(params[:item])
    if @item.save
      flash[:notice] = :item_added  
      respond_to do |format|
        format.html { redirect_to @current_user }
        format.js  
      end
    else 
      flash[:error] = :item_could_not_be_added 
      redirect_to @current_user
    end
  end  
  
  def destroy
    Item.find(params[:id]).destroy
    flash[:notice] = :item_removed
    redirect_to @current_user
  end
  
  def search
    save_navi_state(['items', 'search_items'])
  end
  
  def borrow
    @person = Person.find(params[:person_id])
    @item = Item.find(params[:id])
  end
  
  private
  
  def fetch_items
    save_navi_state(['items','browse_items','',''])
    @letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZÅÄÖ".split("")
    @item_titles = Item.find(:all, :select => "DISTINCT title", :order => 'title ASC').collect(&:title)
  end
  
end
