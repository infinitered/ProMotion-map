module ProMotion
  class MapScreenAnnotation
    attr_reader :params

    # Creates the new annotation object
    def initialize(params = {})
      @params = params
      set_defaults

      if @params[:coordinate]
        @params[:latitude] = @params[:coordinate].latitude
        @params[:longitude] = @params[:coordinate].longitude
        @coordinate = @params[:coordinate]
      elsif @params[:latitude] && @params[:longitude]
        @coordinate = CLLocationCoordinate2D.new(@params[:latitude], @params[:longitude])
      else
        PM.logger.error("You are required to specify :latitude and :longitude or :coordinate for annotations.")
        nil
      end
    end

    def set_defaults
      @params = {
        title: "Title",
        pin_color: MKPinAnnotationColorRed,
        identifier: "Annotation-#{@params[:pin_color]}-#{@params[:image]}",
        show_callout: true,
        animates_drop: false
      }.merge(@params)
    end

    def title
      @params[:title]
    end

    def subtitle
      @params[:subtitle] ||= nil
    end

    def coordinate
      @coordinate
    end

    def cllocation
      CLLocation.alloc.initWithLatitude(@params[:latitude], longitude:@params[:longitude])
    end

    def setCoordinate(new_coordinate);
      if new_coordinate.is_a? Hash
        @coordinate = CLLocationCoordinate2D.new(new_coordinate[:latitude], new_coordinate[:longitude])
      else
        @coordinate = new_coordinate
      end
    end

    def method_missing(meth, *args)
      if @params[meth.to_sym]
        @params[meth.to_sym]
      else
        PM.logger.warn "The annotation parameter \"#{meth}\" does not exist on this pin."
        nil
      end
    end

    # Deprecated
    def annotation_params
      PM.logger.warn("annotation.annotation_params is deprecated and will be removed soon. Please use annotation.params instead.")
      @params
    end

  end
end
