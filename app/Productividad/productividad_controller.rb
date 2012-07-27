require 'rho/rhocontroller'
require 'helpers/browser_helper'
require 'helpers/application_helper'
require 'helpers/method_helper'


class ProductividadController < Rho::RhoController
  include BrowserHelper
  include ApplicationHelper
  include MethodsHelper

  def fetch 
    @url = "http://carl.metricarts.cl/MetricScoreCard/TableroControl/JsonData3?indicador=4"

    fetch_from_server(@url)#,'http://quiet-samurai-7743.herokuapp.com/assets/graf2.png', 'test2.png')
  end

  def fetch_callback
    # callback de fetch from server
    if @params["status"] == "ok"
      @operational = Operational.find(:first)
      response = Rho::JSON.parse(@params['body']) 
      @productividad = Productividad.find(:first)
      @productividad = Productividad.new unless @productividad
      @productividad.value = @operational.productividad
      @productividad.flag = @operational.productividad_flag.to_i
      @productividad.tend = @operational.productividad_tend.to_i
      @productividad.cuf_pagable_filtrado = response['Cuf Pagable Filtrado']['Valor']
      @productividad.horas_hombre = response['HH']['Valor']
      @productividad.chart = response['Grafico']['Datos']
      @productividad.min_date = get_minimum_date_for_chart(@productividad.chart)
      @productividad.save

      @flag_class, @tend_img = initialize_dictionaries
      render_transition :action => :index
      WebView.execute_js("drawChart(#{@productividad.chart},'#{@productividad.min_date}');")
    else
      # In this example, an error just navigates back to the index w/o transition.
      Alert.show_popup 'Error en la conexión'
      WebView.navigate '/app'
    end
  end

  # GET /productividad
  def index
    if Productividad.find(:first)
      @productividad = Productividad.find(:first)
      @flag_class, @tend_img = initialize_dictionaries
      WebView.execute_js("drawChart(#{@productividad.chart},'#{@productividad.min_date}');")      
    else
      Alert.show_popup 'No hay datos, por favor conectese a internet'
      WebView.navigate '/app'
    end
    
    render :back => url_for( :controller => :Operational, :action => :index )
  end

  def pre_index
    if Productividad.find(:first)
      @productividad = Productividad.find(:first)
      @flag_class, @tend_img = initialize_dictionaries

      @response["headers"]["Wait-Page"] = "true" 
      redirect :controller => :Message, :action => :waiting

      render_transition :action => :index
      WebView.execute_js("drawChart(#{@productividad.chart},'#{@productividad.min_date}');")
    else
      Alert.show_popup 'No hay datos, por favor conectese a internet'
      WebView.navigate '/app'
    end   
  end
end
