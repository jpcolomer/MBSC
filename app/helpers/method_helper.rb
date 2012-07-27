require 'date'
module MethodsHelper

  def initialize_dictionaries_categories
      @flag_img = ['/public/images/SemaforoRojo.gif', '/public/images/SemaforoAmarillo.gif', '/public/images/SemaforoVerde.gif']
      @tend_img = ['/public/images/Abajo.gif','/public/images/Centro.gif','/public/images/Arriba.gif']
      [@flag_img, @tend_img]
  end

  def initialize_dictionaries
    # initialize dictionaries for classes and src for images
    @flag_class = {-1 => 'red', 0 => 'yellow', 1 => 'green'}
    @tend_img = {-1 => '/public/images/flechaAbajo.png', 0 => '/public/images/flechaCentro.png', 1 => '/public/images/flechaArriba.png'}
    [@flag_class, @tend_img]
  end

  def download_image_from_server(url,url_img, image_name)

    @file_name = File.join(Rho::RhoApplication::get_base_app_path, image_name)
    Rho::AsyncHttp.download_file(
      :url => url_img,
      :filename => @file_name,
      :headers => {},
      :callback => url_for(:action => :fetch_indicator_property_values_from_server),
      :callback_param => "url=#{url}"
    )
  end

  def fetch_indicator_property_values_from_server(url = nil, callback_hash = {:action => :fetch_callback})

      @url = url || @params["url"]
      Rho::AsyncHttp.get(
        :url => @url,
        :callback => url_for(callback_hash)
      )
  end

  def fetch_from_server(url, url_img = nil, image_name = nil)
    # Metodo que se comunica con el servidor, usa la variable url luego envia la respuesta a 
    # un callback.

    if System.get_property('has_network')

      if url_img && image_name
        download_image_from_server(url, url_img, image_name)
      else
        fetch_indicator_property_values_from_server(url)
      end

      @response["headers"]["Wait-Page"] = "true" 
      redirect :controller => :Message, :action => :waiting
    else
      Alert.show_popup 'No hay acceso a internet'
      redirect :action => :index
    end
  end

  def value_fixer_from_server(value)
    if value > 0
      real_value = 1
    elsif value == 0
      real_value = 0
    else
      real_value = -1
    end
    return real_value
  end

  def get_minimum_date_for_chart(dates)
    first_date = dates.min { |x,y| x[0] <=> y[0]}[0]
    (DateTime.strptime(first_date,'%Y-%m-%d') << 1).strftime('%Y-%m-%d')
  end
end