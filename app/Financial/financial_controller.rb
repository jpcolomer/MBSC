require 'rho/rhocontroller'
require 'helpers/browser_helper'
require 'helpers/application_helper'
require 'helpers/method_helper'

class FinancialController < Rho::RhoController
  include BrowserHelper
  include ApplicationHelper
  include MethodsHelper

  def fetch 
    @url = "http://carl.metricarts.cl/MetricScoreCard/TableroControl/JsonData?categoria=1"
    fetch_from_server(@url)
  end


  def fetch_callback

    if @params["status"] == "ok"
      @financial = Financial.find(:first)
      @financial = Financial.new unless @financial
      response = Rho::JSON.parse(@params['body'])
      # @financial.roce = @params['body']['ROCE']['value']
      # @financial.ebitda = @params['body']['EBITDA']['value']
      # @financial.roce_flag = value_fixer_from_server(@params['body']['ROCE']['flag'])
      # @financial.roce_tend = value_fixer_from_server(@params['body']['ROCE']['tend'])
      # @financial.ebitda_flag = value_fixer_from_server(@params['body']['EBITDA']['flag'])
      # @financial.ebitda_tend = value_fixer_from_server(@params['body']['EBITDA']['tend'])
      @financial.roce = response['ROCE']['value']
      @financial.ebitda = response['EBITDA']['value']
      @financial.roce_flag = value_fixer_from_server(response['ROCE']['flag'])
      @financial.roce_tend = value_fixer_from_server(response['ROCE']['tend'])
      @financial.ebitda_flag = value_fixer_from_server(response['EBITDA']['flag'])
      @financial.ebitda_tend = value_fixer_from_server(response['EBITDA']['tend'])
      @financial.save
      @flag_img, @tend_img = initialize_dictionaries_categories

      render_transition :action => :index
    else
      # In this example, an error just navigates back to the index w/o transition.
      WebView.navigate '/app'
    end

  end

  # GET /Financial
  def index
    if Financial.find(:first)
      @financial = Financial.find(:first)
      @flag_img, @tend_img = initialize_dictionaries_categories
    else
      Alert.show_popup 'No hay datos, por favor conectese a internet'
      redirect '/app'
    end

    render :back => '/app'
  end

  # GET /Financial/{1}
  def show
    @financial = Financial.find(@params['id'])
    if @financial
      render :action => :show, :back => url_for(:action => :index)
    else
      redirect :action => :index
    end
  end

  # GET /Financial/new
  def new
    @financial = Financial.new
    render :action => :new, :back => url_for(:action => :index)
  end

  # GET /Financial/{1}/edit
  def edit
    @financial = Financial.find(@params['id'])
    if @financial
      render :action => :edit, :back => url_for(:action => :index)
    else
      redirect :action => :index
    end
  end

  # POST /Financial/create
  def create
    @financial = Financial.create(@params['financial'])
    redirect :action => :index
  end

  # POST /Financial/{1}/update
  def update
    @financial = Financial.find(@params['id'])
    @financial.update_attributes(@params['financial']) if @financial
    redirect :action => :index
  end

  # POST /Financial/{1}/delete
  def delete
    @financial = Financial.find(@params['id'])
    @financial.destroy if @financial
    redirect :action => :index  
  end
end
