require 'rho/rhocontroller'
require 'helpers/browser_helper'
require 'helpers/application_helper'
require 'helpers/method_helper'

class LearningAndGrowthController < Rho::RhoController
  include BrowserHelper
  include ApplicationHelper
  include MethodsHelper


  def fetch 
    @url = "http://carl.metricarts.cl/MetricScoreCard/TableroControl/JsonData?categoria=4"
    fetch_from_server(@url)
  end


  def fetch_callback

    if @params["status"] == "ok"
      @learning_and_growth = LearningAndGrowth.find(:first)
      @learning_and_growth = LearningAndGrowth.new unless @learning_and_growth
      response = Rho::JSON.parse(@params['body'])
      # @learning_and_growth.desarrollo_organizacional = @params['body']['desarrollo_organizacional']['value']
      # @learning_and_growth.desarrollo_organizacional_flag = @params['body']['desarrollo_organizacional']['flag']
      # @learning_and_growth.desarrollo_organizacional_tend = @params['body']['desarrollo_organizacional']['tend']      
      @learning_and_growth.desarrollo_organizacional = response['Desarrollo organizacional']['value']
      @learning_and_growth.desarrollo_organizacional_flag = response['Desarrollo organizacional']['flag']
      @learning_and_growth.desarrollo_organizacional_tend = response['Desarrollo organizacional']['tend']      
      @learning_and_growth.save

      @flag_img, @tend_img = initialize_dictionaries_categories

      render_transition :action => :index
    else
      # In this example, an error just navigates back to the index w/o transition.
      WebView.navigate '/app'
    end

  end

  # GET /LearningAndGrowth
  def index
    if LearningAndGrowth.find(:first)
      @learning_and_growth = LearningAndGrowth.find(:first)
      @flag_img, @tend_img = initialize_dictionaries_categories
    else
      Alert.show_popup 'No hay datos, por favor conectese a internet'
      redirect '/app'
    end

    render :back => '/app'
  end

  # GET /learning_and_growth/{1}
  def show
    @learning_and_growth = LearningAndGrowth.find(@params['id'])
    if @learning_and_growth
      render :action => :show, :back => url_for(:action => :index)
    else
      redirect :action => :index
    end
  end

  # GET /LearningAndGrowth/new
  def new
    @learning_and_growth = LearningAndGrowth.new
    render :action => :new, :back => url_for(:action => :index)
  end

  # GET /LearningAndGrowth/{1}/edit
  def edit
    @learning_and_growth = LearningAndGrowth.find(@params['id'])
    if @learning_and_growth
      render :action => :edit, :back => url_for(:action => :index)
    else
      redirect :action => :index
    end
  end

  # POST /LearningAndGrowth/create
  def create
    @learning_and_growth = LearningAndGrowth.create(@params['learning_and_growth'])
    redirect :action => :index
  end

  # POST /LearningAndGrowth/{1}/update
  def update
    @learning_and_growth = LearningAndGrowth.find(@params['id'])
    @learning_and_growth.update_attributes(@params['learning_and_growth']) if @learning_and_growth
    redirect :action => :index
  end

  # POST /LearningAndGrowth/{1}/delete
  def delete
    @learning_and_growth = LearningAndGrowth.find(@params['id'])
    @learning_and_growth.destroy if @learning_and_growth
    redirect :action => :index  
  end
end
