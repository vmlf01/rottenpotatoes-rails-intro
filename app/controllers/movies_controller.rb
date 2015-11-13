class MoviesController < ApplicationController

  def initialize
    super()
    @all_ratings = Movie.ratings
    @ratings_to_show = @all_ratings
  end

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    if !redirect_because_of_params
      initCssClasses
      
      movie_query = appendSortParams(Movie, @css)
      movie_query = appendFilterParams(movie_query)
  
      puts "ratings: #{@ratings_to_show}"
  
      @movies = movie_query.all
    end
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

  private
  def initCssClasses
    @css = {
      "title" => "",
      "release_date" => ""
    }
  end
  
  def appendSortParams(movie_query, css)
    sort_column = params[:sort] ||= session[:sort];

    if sort_column =~ /^(title|release_date)$/i
      sort_column.downcase!
      css[sort_column] = 'hilite'
      movie_query = movie_query.order(sort_column)
      session[:sort] = params[:sort]
    else
      session.delete :sort
    end
    
    movie_query
  end
  
  def appendFilterParams(movie_query)
    @ratings_to_show = params[:ratings] ||= session[:ratings]

    #@ratings_to_show = [] unless params[:commit].nil?
    #@ratings_to_show = params[:ratings].keys unless params[:ratings].nil?
    if (@ratings_to_show.nil?)
      session.delete :ratings
      @ratings_to_show = @all_ratings
    else
      @ratings_to_show = @ratings_to_show.keys
      movie_query = movie_query.where({ "rating" => @ratings_to_show })
      session[:ratings] = params[:ratings]
    end
    
    movie_query
  end

  def redirect_because_of_params
    needs_redirect = should_use_session_value?(:sort) || should_use_session_value?(:ratings)
    if (needs_redirect)
      params[:sort] = params[:sort] ||= session[:sort]
      params[:ratings] = params[:ratings] ||= session[:ratings]
  
      flash.keep
      redirect_to movies_path(params)
    end
  end

  def should_use_session_value?(param)
    params[param].nil? && !session[param].nil?
  end

end
