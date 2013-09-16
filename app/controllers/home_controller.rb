require 'net/http'

class HomeController < ApplicationController

  # Here we pull the content under a tab header
  def get_detail
    	location = params[:location]
      page = params[:page]
    	location = location.gsub(" ","_")

    	url = "/wiki/en/api.php?action=query&prop=revisions&rvprop=content&rvsection=#{page}&titles=#{location}&format=xml&rvparse"
      response = Net::HTTP.get_response("wikitravel.org", url)
    	data = Hash.from_xml(response.body)

      main_html = data["api"]["query"]["pages"]["page"]["revisions"]["rev"]
      if main_html.include?("</h3>\n")
          main_html = main_html.split("</h3>\n")[1]
      elsif main_html.include?("</h2>\n")
          main_html = main_html.split("</h2>\n")[1]
      elsif main_html.include?("</h1>\n")    
          main_html = main_html.split("</h1>\n")[1]
      end

      main_html = main_html.gsub("\"/", "\"http://wikitravel.org/")
      main_html = main_html.gsub("href=\"h", "target='_blank' href=\"h")

      render :json => {:content => main_html}
  end

  # Here we pull all tab headers of a page/location
  def result
      @lines = []
      unless params[:location].nil? || params[:location] == ""
          location = params[:location]
          location = location.gsub(" ","_")
          url = "/wiki/en/api.php?format=xml&action=parse&prop=sections&page=#{location}"
          response = Net::HTTP.get_response("wikitravel.org", url)
          data = Hash.from_xml(response.body) unless response.nil? || response.body.nil?
          
          unless data.nil? || data["api"].nil? || data["api"]["parse"].nil?              
              unless data["api"]["parse"]["sections"].nil?
                  params[:location] = data["api"]["parse"]["title"]
                  @lines = data["api"]["parse"]["sections"]["s"] unless data["api"]["parse"]["sections"]["s"].nil?   
              end
          end
      end   
  end

end
