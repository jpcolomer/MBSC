require 'rho/rhocontroller'
require 'helpers/browser_helper'
require 'helpers/application_helper'
require 'helpers/method_helper'

class DesarrolloOrganizacionalController < Rho::RhoController
  include BrowserHelper
  include ApplicationHelper
  include MethodsHelper

  def fetch 
    @url = "http://carl.metricarts.cl/MetricScoreCard/TableroControl/JsonData3?indicador=5"

    fetch_from_server(@url)#,'http://quiet-samurai-7743.herokuapp.com/assets/graf2.png', 'test2.png')
  end

  def fetch_callback
    # callback de fetch from server
    if @params["status"] == "ok"
      @learning_and_growth = LearningAndGrowth.find(:first)
      response = Rho::JSON.parse(@params['body'])  
      @desarrollo_organizacional = DesarrolloOrganizacional.find(:first)
      @desarrollo_organizacional = DesarrolloOrganizacional.new unless @desarrollo_organizacional
      @desarrollo_organizacional.value = @learning_and_growth.desarrollo_organizacional
      @desarrollo_organizacional.flag = @learning_and_growth.desarrollo_organizacional_flag.to_i
      @desarrollo_organizacional.tend = @learning_and_growth.desarrollo_organizacional_tend.to_i
      @desarrollo_organizacional.capacitacion = response['Programas Capacitación']['Valor']
      @desarrollo_organizacional.cuadros_reemplazo = response['Cuadros Reemplazos']['Valor']
      @desarrollo_organizacional.reemplazos_internos = response['Reemplazos Internos']['Valor']
      @desarrollo_organizacional.chart = response['Grafico']['Datos']
      @desarrollo_organizacional.min_date = get_minimum_date_for_chart(@desarrollo_organizacional.chart)
      @desarrollo_organizacional.save

      @flag_class, @tend_img = initialize_dictionaries
      render_transition :action => :index
      WebView.execute_js("drawChart(#{@desarrollo_organizacional.chart},'#{@desarrollo_organizacional.min_date}');")
    else
      # In this example, an error just navigates back to the index w/o transition.
      Alert.show_popup 'Error en la conexión'
      WebView.navigate '/app'
    end
  end

  # GET /desarrollo_organizacional
  def index
    if DesarrolloOrganizacional.find(:first)
      @desarrollo_organizacional = DesarrolloOrganizacional.find(:first)
      @flag_class, @tend_img = initialize_dictionaries
      WebView.execute_js("drawChart(#{@desarrollo_organizacional.chart},'#{@desarrollo_organizacional.min_date}');")
    else
      Alert.show_popup 'No hay datos, por favor conectese a internet'
      WebView.navigate '/app'
    end
    render :back => url_for( :controller => :LearningAndGrowth, :action => :index )
  end

  def pre_index
    if DesarrolloOrganizacional.find(:first)
      @desarrollo_organizacional = DesarrolloOrganizacional.find(:first)
      @flag_class, @tend_img = initialize_dictionaries

      @response["headers"]["Wait-Page"] = "true" 
      redirect :controller => :Message, :action => :waiting

      render_transition :action => :index
      WebView.execute_js("drawChart(#{@desarrollo_organizacional.chart},'#{@desarrollo_organizacional.min_date}');")
    else
      Alert.show_popup 'No hay datos, por favor conectese a internet'
      WebView.navigate '/app'
    end   
  end

  
end