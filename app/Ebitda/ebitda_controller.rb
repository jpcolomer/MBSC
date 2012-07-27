require 'rho/rhocontroller'
require 'helpers/browser_helper'
require 'helpers/application_helper'
require 'helpers/method_helper'

class EbitdaController < Rho::RhoController
  include BrowserHelper
  include ApplicationHelper
  include MethodsHelper

  def fetch 
    @url = "http://carl.metricarts.cl/MetricScoreCard/TableroControl/JsonData3?indicador=2"

    fetch_from_server(@url)#,'http://quiet-samurai-7743.herokuapp.com/assets/graf2.png', 'test2.png')
  end

  def fetch_callback
    # callback de fetch from server
    if @params["status"] == "ok"
      @financial = Financial.find(:first)
      response = Rho::JSON.parse(@params['body'])
      @ebitda = Ebitda.find(:first)
      @ebitda = Ebitda.new unless @ebitda
      @ebitda.value = @financial.ebitda
      @ebitda.flag = @financial.ebitda_flag.to_i
      @ebitda.tend = @financial.ebitda_tend.to_i
      @ebitda.ingresos = response['Ventas']['Valor']
      @ebitda.costo_on_site = response['Costo on site']['Valor']
      @ebitda.costo_comercializacion = response['Costo comercialización']['Valor']
      @ebitda.otros_costos = response['Otros costos']['Valor']
      @ebitda.chart = response['Grafico']['Datos']
      @ebitda.min_date = get_minimum_date_for_chart(@ebitda.chart)
      @ebitda.save
      
      @flag_class, @tend_img = initialize_dictionaries
      render_transition :action => :index
      WebView.execute_js("drawChart(#{@ebitda.chart},'#{@ebitda.min_date}');")
      
    else
      # In this example, an error just navigates back to the index w/o transition.
      Alert.show_popup 'Error en la conexión'
      WebView.navigate '/app'
    end
  end

  # GET /ebitda
  def index
    if Ebitda.find(:first)
      @ebitda = Ebitda.find(:first)
      @flag_class, @tend_img = initialize_dictionaries
      WebView.execute_js("drawChart(#{@ebitda.chart},'#{@ebitda.min_date}');")
    else
      Alert.show_popup 'No hay datos, por favor conectese a internet'
      WebView.navigate '/app'
    end
    render :back => url_for( :controller => :Financial, :action => :index )
  end
  
  def pre_index
    if Ebitda.find(:first)
      @ebitda = Ebitda.find(:first)
      @flag_class, @tend_img = initialize_dictionaries

      @response["headers"]["Wait-Page"] = "true" 
      redirect :controller => :Message, :action => :waiting

      render_transition :action => :index
      WebView.execute_js("drawChart(#{@ebitda.chart},'#{@ebitda.min_date}');")
    else
      Alert.show_popup 'No hay datos, por favor conectese a internet'
      WebView.navigate '/app'
    end   
  end

end
