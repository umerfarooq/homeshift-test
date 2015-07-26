class HomeController < ApplicationController

	def index
	end

  # Procedure, specifically crafted to find a Postal Code in Thames Water supply area
	def find_supplier
        require "net/http"
        require "uri"

        post_code = params[:post_code]
        notice = "Sorry we can't find this Postcode in the supply areas of Thames Water"

        # Thames Water's URL pattern to initiate search request with Postal Code input by the searcher
        search_request_uri = "https://secure.thameswater.co.uk/dynamic/cps/rde/xchg/corp/hs.xsl/Thames_Water_Supply.xml"
        uri = URI(search_request_uri)
        params = { :postcode1 => post_code }
        uri.query = URI.encode_www_form(params)

        # Enable secure request mode
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE

        # Initial search request with Postal Code
        request = Net::HTTP::Get.new(uri.request_uri)

        # Response from the search engine
        response = http.request(request)
        
        # Thames Water redirects to the search result page after the search completes, Hence another call
        location = response['location']
        uri = URI(location)
        http = Net::HTTP.new(uri.host, uri.port)
        request = Net::HTTP::Get.new(uri.request_uri)
        response = http.request(request)

        # Nokogiri to help us crawl through the ugly and raw http response 
        doc = Nokogiri::HTML(response.body)

        # Thames Water search result page uses H1 to render the search result notice
        doc.xpath('//h1').each do |h1|
          puts h1.text

          if h1.text.downcase.include? 'your property is in our supply area'
            notice = "Your property is in the supply area of Thames Water"
          end
        end

        redirect_to root_url, notice: notice
	end

end
