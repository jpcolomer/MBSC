require 'rho/rhocontroller'
require 'helpers/browser_helper'
require 'helpers/application_helper'
require 'helpers/method_helper'

class ClientController < Rho::RhoController
  include BrowserHelper
  include ApplicationHelper
  include MethodsHelper


  def fetch 
    @url = "http://carl.metricarts.cl/MetricScoreCard/TableroControl/JsonData?categoria=2"
    fetch_from_server(@url)
  end


  def fetch_callback

    if @params["status"] == "ok"
      @client = Client.find(:first)
      @client = Client.new unless @client
      response = Rho::JSON.parse(@params['body'])
      # @client.exposicion_riesgo = @params['body']['exposicion_riesgo']['value']
      # @client.exposicion_riesgo_flag = @params['body']['exposicion_riesgo']['flag']
      # @client.exposicion_riesgo_tend = @params['body']['exposicion_riesgo']['tend']
      @client.exposicion_riesgo = response['Exposición al riesgo']['value']
      @client.exposicion_riesgo_flag = value_fixer_from_server(response['Exposición al riesgo']['flag'])
      @client.exposicion_riesgo_tend = value_fixer_from_server(response['Exposición al riesgo']['tend'])
      @client.save

      @flag_img, @tend_img = initialize_dictionaries_categories

      render_transition :action => :index
    else
      # In this example, an error just navigates back to the index w/o transition.
      WebView.navigate '/app'
    end

  end

  # GET /Client
  def index
    if Client.find(:first)
      @client = Client.find(:first)
      @flag_img, @tend_img = initialize_dictionaries_categories
    else
      Alert.show_popup 'No hay datos, por favor conectese a internet'
      redirect '/app'
    end

    render :back => '/app'
  end

  # GET /client/{1}
  def show
    @client = Client.find(@params['id'])
    if @client
      render :action => :show, :back => url_for(:action => :index)
    else
      redirect :action => :index
    end
  end

  # GET /Client/new
  def new
    @client = Client.new
    render :action => :new, :back => url_for(:action => :index)
  end

  # GET /Client/{1}/edit
  def edit
    @client = Client.find(@params['id'])
    if @client
      render :action => :edit, :back => url_for(:action => :index)
    else
      redirect :action => :index
    end
  end

  # POST /Client/create
  def create
    @client = Client.create(@params['client'])
    redirect :action => :index
  end

  # POST /Client/{1}/update
  def update
    @client = Client.find(@params['id'])
    @client.update_attributes(@params['client']) if @client
    redirect :action => :index
  end

  # POST /Client/{1}/delete
  def delete
    @client = Client.find(@params['id'])
    @client.destroy if @client
    redirect :action => :index  
  end  



end
