require 'net/http'
require 'uri'

module EventbriteEvents
    class Generator < Jekyll::Generator
        safe true
        priority :highest
        def get_eventbrite_events()
            uri = URI("https://www.eventbriteapi.com/v3/organizations/188789739786/events?order_by=start_desc&page_size=2")
            req = Net::HTTP::Get.new(uri.request_uri)
            req["Authorization"] = "Bearer NHTMW2IHNX2F5LYDGM2K"
            req["Content-Type"] = "application/json"

            response = Net::HTTP.start(uri) {
                http.request(req)
            }
            puts response.body

    end
end


Liquid::Template.register_filter(Jekyll::Events)