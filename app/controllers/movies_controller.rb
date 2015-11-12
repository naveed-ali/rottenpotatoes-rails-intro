class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @all_ratings = Movie.ratings
    @sort_by = params[:sort_by]
    @selected_ratings = params[:ratings].keys unless params[:ratings].nil?
    redirecting = false
    
    debugger
    
    if @sort_by.nil? and session.has_key? :sort_by
      @sort_by = session[:sort_by]
      session.delete(:sort_by)
      redirecting = true
    end
    
    if @selected_ratings.nil? and session.has_key? :ratings
      @selected_ratings = session[:ratings]
      session.delete(:ratings)
      redirecting = true
    end
    
    if redirecting
      redirect_to movies_path(sort_by: @sort_by, selected_ratings: @selected_ratings)
      return
    end
    
    @selected_ratings ||= @all_ratings
    
    session[:sort_by] = @sort_by unless @sort_by.nil?
    session[:ratings] = params[:ratings] unless @selected_ratings == @all_ratings
    
    @movies = Movie.where(rating: @selected_ratings).order(@sort_by)
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end
