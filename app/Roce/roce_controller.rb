require 'rho/rhocontroller'
require 'helpers/browser_helper'
require 'helpers/application_helper'
require 'helpers/method_helper'

class RoceController < Rho::RhoController
  include BrowserHelper
  include ApplicationHelper
  include MethodsHelper

  def fetch 
    @url = "http://carl.metricarts.cl/MetricScoreCard/TableroControl/JsonData3?indicador=1"

    fetch_from_server(@url) #,'http://quiet-samurai-7743.herokuapp.com/assets/graf2.png', 'test2.png')
  end

  def fetch_callback
    # callback de fetch from server
    if @params["status"] == "ok"
      @financial = Financial.find(:first)
      response = Rho::JSON.parse(@params['body'])
      @roce = Roce.find(:first)
      @roce = Roce.new unless @roce
      @roce.value = @financial.roce
      @roce.flag = @financial.roce_flag.to_i
      @roce.tend = @financial.roce_tend.to_i
      @roce.nopat = response['NOPAT']['Valor']
      @roce.ce = response['Capital Empleado']['Valor']
      @roce.chart = response['Grafico']['Datos']
      @roce.min_date = get_minimum_date_for_chart(@roce.chart)
      @roce.save

      @flag_class, @tend_img = initialize_dictionaries
      render_transition :action => :index
      WebView.execute_js("drawChart(#{@roce.chart},'#{@roce.min_date}');")
    else
      # In this example, an error just navigates back to the index w/o transition.
      Alert.show_popup 'Error en la conexión'
      WebView.navigate '/app'
    end

  end

  # GET /Roce
  def index
    if Roce.find(:first)
      @roce = Roce.find(:first)
    else
      Alert.show_popup 'No hay datos, por favor conectese a internet'
      WebView.navigate '/app'
    end
    @flag_class, @tend_img = initialize_dictionaries
    # @flag_class = {-1 => 'red', 0 => 'yellow', 1 => 'green'}
    # @tend_img = {-1 => '/public/images/flechaAbajo.png', 0 => '/public/images/flechaCentro.png', 1 => '/public/images/flechaArriba.png'}

    render :back => url_for( :controller => :Financial, :action => :index )
  end

  def pre_index
    if Roce.find(:first)
      @roce = Roce.find(:first)
      @flag_class, @tend_img = initialize_dictionaries

      @response["headers"]["Wait-Page"] = "true" 
      redirect :controller => :Message, :action => :waiting

      render_transition :action => :index
      WebView.execute_js("drawChart(#{@roce.chart},'#{@roce.min_date}');")
    else
      Alert.show_popup 'No hay datos, por favor conectese a internet'
      WebView.navigate '/app'
    end   
  end

end
