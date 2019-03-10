require 'uri'
require 'net/http'
require 'net/https'
require 'json'

module Jekyll
    class EventbriteEvent < Liquid::Tag

        def render(context)
            userId = "188789739786"
            ygl_eb_token = ENV['ygl_eb_token']
            uri = URI.parse("https://www.eventbriteapi.com/v3/organizations/188789739786/events/?token=#{ygl_eb_token}&order_by=start_desc&page_size=1")
            puts uri
            
            https = Net::HTTP.new(uri.host, uri.port)
            https.use_ssl = true
            @data = https.get(uri)
            @event_info = JSON.parse(@data.body)
            @event_date = @event_info["events"][0]["start"]["local"]
            @parsed_date = DateTime.parse(@event_date)

            venue_uri = URI.parse("https://www.eventbriteapi.com/v3/venues/30711856/?token=#{ygl_eb_token}")
            https = Net::HTTP.new(uri.host, uri.port)
            https.use_ssl = true

            @venue_data = https.get(venue_uri)
            @venue_info = JSON.parse(@venue_data.body)

        
            return "
            <div class='event'>
                <div class='event-item'>
                <h4>#{@parsed_date.strftime("%A %b %d at %I:%M %p")}</h4>
                <h3>#{@event_info["events"][0]["name"]["text"]}</h3>
                  <p>#{@event_info["events"][0]["description"]["text"]}.</p>
                  <p>#{@venue_info["address"]["localized_address_display"]}</p>
                 <p><a class='button' href='#{@event_info["events"][0]["url"]}'>RSVP</a>
                  <a href='#{@event_info["events"][0]["url"]}'>Details</a></p>
                </div>
                <div class='event-item'>
                  <img class='event-photo' src='#{@event_info["events"][0]["logo"]["url"]}'/>
                </div>
              </div>"
            
        end
    end
end

Liquid::Template.register_tag('eventbrite_event', Jekyll::EventbriteEvent)