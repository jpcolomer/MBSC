require 'rho/rhocontroller'
require 'helpers/browser_helper'
require 'helpers/application_helper'
require 'helpers/method_helper'

class OperationalController < Rho::RhoController
  include BrowserHelper
  include ApplicationHelper
  include MethodsHelper


  def fetch 
    @url = "http://carl.metricarts.cl/MetricScoreCard/TableroControl/JsonData?categoria=3"
    fetch_from_server(@url)
  end


  def fetch_callback

    if @params["status"] == "ok"
      @operational = Operational.find(:first)
      @operational = Operational.new unless @operational
      response = Rho::JSON.parse(@params['body'])
      # @operational.productividad = @params['body']['productividad']['value']
      # @operational.productividad_flag = @params['body']['productividad']['flag']
      # @operational.productividad_tend = @params['body']['productividad']['tend']
      @operational.productividad = response['Productividad']['value']
      @operational.productividad_flag = value_fixer_from_server(response['Productividad']['flag'])
      @operational.productividad_tend = value_fixer_from_server(response['Productividad']['tend'])
      @operational.save

      @flag_img, @tend_img = initialize_dictionaries_categories

      render_transition :action => :index
    else
      # In this example, an error just navigates back to the index w/o transition.
      WebView.navigate '/app'
    end

  end

  # GET /Operational
  def index
    if Operational.find(:first)
      @operational = Operational.find(:first)
      @flag_img, @tend_img = initialize_dictionaries_categories
    else
      Alert.show_popup 'No hay datos, por favor conectese a internet'
      redirect '/app'
    end

    render :back => '/app'
  end

  # GET /operational/{1}
  def show
    @operational = Operational.find(@params['id'])
    if @operational
      render :action => :show, :back => url_for(:action => :index)
    else
      redirect :action => :index
    end
  end

  # GET /Operational/new
  def new
    @operational = Operational.new
    render :action => :new, :back => url_for(:action => :index)
  end

  # GET /Operational/{1}/edit
  def edit
    @operational = Operational.find(@params['id'])
    if @operational
      render :action => :edit, :back => url_for(:action => :index)
    else
      redirect :action => :index
    end
  end

  # POST /Operational/create
  def create
    @operational = Operational.create(@params['operational'])
    redirect :action => :index
  end

  # POST /Operational/{1}/update
  def update
    @operational = Operational.find(@params['id'])
    @operational.update_attributes(@params['operational']) if @operational
    redirect :action => :index
  end

  # POST /Operational/{1}/delete
  def delete
    @operational = Operational.find(@params['id'])
    @operational.destroy if @operational
    redirect :action => :index  
  end
end
