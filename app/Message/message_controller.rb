require 'rho/rhocontroller'
require 'helpers/browser_helper'

class MessageController < Rho::RhoController
  include BrowserHelper

  # GET /Message
  def index
    @messages = Message.find(:all)
    render :back => '/app'
  end

  # GET /Message/{1}
  def show
    @message = Message.find(@params['id'])
    if @message
      render :action => :show, :back => url_for(:action => :index)
    else
      redirect :action => :index
    end
  end

  def search
    @kpi_and_indicator_url = {
      'Roce' => url_for(:controller => :Roce, :action => :pre_index),
      'Ebitda' => url_for(:controller => :Ebitda, :action => :pre_index),
      'Exposicion al riesgo' => url_for(:controller => :ExposicionRiesgo, :action => :pre_index),
      'Productividad' => url_for(:controller => :Productividad, :action => :pre_index),
      'Desarrollo organizacional' => url_for(:controller => :DesarrolloOrganizacional, :action => :pre_index)
    }
    @kpi_and_indicator_url.merge!({
      'NOPAT' => @kpi_and_indicator_url['Roce'],
      'Capital empleado' => @kpi_and_indicator_url['Roce'],
      'Ingresos' => @kpi_and_indicator_url['Ebitda'],
      'Costo on site' => @kpi_and_indicator_url['Ebitda'],
      'Costo de comercialización' => @kpi_and_indicator_url['Ebitda'],
      'Otros costos' => @kpi_and_indicator_url['Ebitda'],
      'Cumplimiento iniciativas' => @kpi_and_indicator_url['Exposicion al riesgo'],
      'Incidentes operacionales' => @kpi_and_indicator_url['Exposicion al riesgo'],
      'Cuf pagable filtrado' => @kpi_and_indicator_url['Productividad'],
      'Horas hombre' => @kpi_and_indicator_url['Productividad'],
      'Capacitación' => @kpi_and_indicator_url['Desarrollo organizacional'],
      'Cuadros de reemplazo' => @kpi_and_indicator_url['Desarrollo organizacional'],
      'Reemplazos internos' => @kpi_and_indicator_url['Desarrollo organizacional']
      })
  end

  # GET /Message/new
  def new
    @message = Message.new
    render :action => :new, :back => url_for(:action => :index)
  end

  # GET /Message/{1}/edit
  def edit
    @message = Message.find(@params['id'])
    if @message
      render :action => :edit, :back => url_for(:action => :index)
    else
      redirect :action => :index
    end
  end

  # POST /Message/create
  def create
    @message = Message.create(@params['message'])
    redirect :action => :index
  end

  # POST /Message/{1}/update
  def update
    @message = Message.find(@params['id'])
    @message.update_attributes(@params['message']) if @message
    redirect :action => :index
  end

  # POST /Message/{1}/delete
  def delete
    @message = Message.find(@params['id'])
    @message.destroy if @message
    redirect :action => :index  
  end

end
