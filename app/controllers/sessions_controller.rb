class SessionsController < ApplicationController

  def sessionindex
    @readings = Reading.all(:sid => params[:session], :did => params[:device], :order => 't')
    
    @sensors = {}
    @data = {}
    for r in @readings
      if @sensors.has_key?(r.s)
        logger.debug("Pushing to existing sensor "+r.s)
        @data[r.s].push(r.v)
      else
        logger.debug("Adding new sensor to hash "+r.s)
        sensor = Sensor.find_by_code(r.s)
        if sensor
          logger.debug(sensor.to_s())
          logger.debug("Looked up "+r.s+" as "+sensor.description)
        else
          logger.debug("Sensor for "+r.s+" was unknown")
       	  sensor = Sensor.new(:code => r.s, :description => "Unknown sensor ("+r.s+")", :min => '0', :max => '100', :unit => '?')
        end
        @sensors[r.s] = sensor
        @data[r.s] = []
        logger.debug("Created new element for data, pushing value "+r.v.to_s())
        @data[r.s].push(r.v)        
      end       
    end
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @readings }
    end
  end

  def deviceindex
  end

  def sensor    
    @readings = Reading.all(:sid => params[:session], :did => params[:device], :s => params[:sensor], :order => 't')
    @sensor = Sensor.find_by_code(params[:sensor])
    if not @sensor
      @sensor = Sensor.new(:code => params[:sensor], :description => "Unknown sensor ("+params[:sensor]+")", :min => '0', :max => '100', :unit => '?')
    end
    logger.debug("Length is: "+@readings.length.to_s())
    if not @readings
      render(:text => "No readings")
      return
    end

    @data = []
    for r in @readings
      @data.push(r.v)
    end

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @readings }
    end
  end
end
