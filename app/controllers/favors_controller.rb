class FavorsController < ApplicationController
  
  def index
    fetch_favors
  end
  
  def show
    session[:previous_page] = request.request_uri
    @title = params[:id]
    @favors = Favor.find(:all, :conditions => "title = '" + params[:id].capitalize + "'")
    fetch_favors
    render :action => :index
  end
  
  def search
    save_navi_state(['favors', 'search_favors'])
    @title = :search_favors_title
  end
  
  def create
    @favor = Favor.new(params[:favor])
    if @favor.save
      flash[:notice] = :favor_added  
      respond_to do |format|
        format.html { redirect_to @current_user }
        format.js  
      end
    else 
      flash[:error] = :favor_could_not_be_added 
      redirect_to @current_user
    end
  end
  
  def edit
    @editable_favor = Favor.find(params[:id])
    @person = Person.find(params[:person_id])
    show_profile
    render :template => "people/show" 
  end
  
  def update
    @person = Person.find(params[:person_id])
    if params[:favor][:cancel]
      redirect_to person_path(@person) and return
    end  
    @favor = Favor.find(params[:id])
    if @favor.update_attribute(:title, params[:favor][:title])
      flash[:notice] = :favor_updated
    else 
      flash[:error] = :favor_could_not_be_updated
    end    
    redirect_to person_path(@person)
  end
  
  def destroy
    Favor.find(params[:id]).destroy
    flash[:notice] = :favor_removed
    redirect_to @current_user
  end
  
  def ask_for
    @person = Person.find(params[:person_id])
    @favor = Favor.find(params[:id])
  end
  
  private
  
  def fetch_favors
    save_navi_state(['favors','browse_favors','',''])
    @letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZÅÄÖ".split("")
    @favor_titles = Favor.find(:all, :select => "DISTINCT title", :order => 'title ASC').collect(&:title)
  end
  
end
