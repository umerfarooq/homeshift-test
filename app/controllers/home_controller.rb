class HomeController < ApplicationController
	Capybara.run_server = false
	Capybara.current_driver = :webkit

	include Capybara::DSL

	def index
	end

	def find_supplier
		post_code = params[:post_code]
		notice = "Sorry we can't find this Postcode in the supply areas of either Thames Water or Affinity Water"

		# Case 1: Check for the Water Supplier in Thames Water Database
		visit("http://www.thameswater.co.uk/your-account/605.htm")
    fill_in "postcode1", :with => post_code 
    click_button "submit"

    all("#middlesidewide h1").each do |h1| 
      if h1.text.downcase.include? 'your property is in our supply area'
      	notice = "Your property is in the supply area of Thames Water"
      	return redirect_to root_url, notice: notice
      end
    end

    # Case 2: Check for the Water Supplier in Affinity Water Database
		visit("http://www.affinitywater.co.uk/im-moving.aspx")
    fill_in "template_txtPostcodePanelSearch", :with => post_code 
    click_button "Search"
    result = find('#template_pnl_area_results').find('h3').text
    
    if result.downcase.include? 'affinity water supplies your area.'
    	notice = "Your property is in the supply area of Affinity Water"
    	return redirect_to root_url, notice: notice
    end

    redirect_to root_url, notice: notice
	end

end
