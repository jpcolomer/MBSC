require 'rho/rhocontroller'
require 'helpers/browser_helper'
require 'helpers/application_helper'
require 'helpers/method_helper'
# require 'date'


class ExposicionRiesgoController < Rho::RhoController
  include BrowserHelper
  include ApplicationHelper
  include MethodsHelper

  def fetch 
    @url = "http://carl.metricarts.cl/MetricScoreCard/TableroControl/JsonData3?indicador=3"

    fetch_from_server(@url)#,'http://quiet-samurai-7743.herokuapp.com/assets/graf2.png', 'test2.png')
  end

  def fetch_callback
    # callback de fetch from server
    if @params["status"] == "ok"
      @client = Client.find(:first)
      response = Rho::JSON.parse(@params['body'])
      @exposicion_riesgo = ExposicionRiesgo.find(:first)
      @exposicion_riesgo = ExposicionRiesgo.new unless @exposicion_riesgo
      @exposicion_riesgo.value = @client.exposicion_riesgo
      @exposicion_riesgo.flag = @client.exposicion_riesgo_flag.to_i
      @exposicion_riesgo.tend = @client.exposicion_riesgo_tend.to_i
      @exposicion_riesgo.cumplimiento_iniciativas = response['Cumplimiento Iniciativas']['Valor']
      @exposicion_riesgo.incid_operacionales = response['Incidentes Operacionales']['Valor']
      @exposicion_riesgo.chart = response['Grafico']['Datos']
      @exposicion_riesgo.min_date = get_minimum_date_for_chart(@exposicion_riesgo.chart)
      @exposicion_riesgo.save

      @flag_class, @tend_img = initialize_dictionaries
      render_transition :action => :index
      WebView.execute_js("drawChart(#{@exposicion_riesgo.chart},'#{@exposicion_riesgo.min_date}');")
    else
      # In this example, an error just navigates back to the index w/o transition.
      Alert.show_popup 'Error en la conexión'
      WebView.navigate '/app'
    end
  end

  # GET /exposicion_riesgo
  def index
    if ExposicionRiesgo.find(:first)
      @exposicion_riesgo = ExposicionRiesgo.find(:first)
      @flag_class, @tend_img = initialize_dictionaries
      WebView.execute_js("drawChart(#{@exposicion_riesgo.chart},'#{@exposicion_riesgo.min_date}');")
    else
      Alert.show_popup 'No hay datos, por favor conectese a internet'
      WebView.navigate '/app'
    end
    render :back => url_for( :controller => :Client, :action => :index )
  end

  def pre_index
    if ExposicionRiesgo.find(:first)
      @exposicion_riesgo = ExposicionRiesgo.find(:first)
      @flag_class, @tend_img = initialize_dictionaries

      @response["headers"]["Wait-Page"] = "true" 
      redirect :controller => :Message, :action => :waiting

      render_transition :action => :index
      WebView.execute_js("drawChart(#{@exposicion_riesgo.chart},'#{@exposicion_riesgo.min_date}');")
    else
      Alert.show_popup 'No hay datos, por favor conectese a internet'
      WebView.navigate '/app'
    end   
  end
end