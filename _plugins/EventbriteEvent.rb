require 'uri'
require 'net/http'
require 'net/https'
require 'json'

module Jekyll
    class EventbriteEvent < Liquid::Tag

        def render(context)
            userId = "188789739786"
            ygl_eb_token = ENV['ygl_eb_token']
            uri = URI.parse("https://www.eventbriteapi.com/v3/organizations/188789739786/events/?token=#{ygl_eb_token}&order_by=start_asc&page_size=1&status=live")
            
            https = Net::HTTP.new(uri.host, uri.port)
            https.use_ssl = true
            @data = https.get(uri)
            @event_info = JSON.parse(@data.body)    

            if @event_info["events"].size > 0

              @event_date = @event_info["events"][0]["start"]["local"]
              @parsed_date = DateTime.parse(@event_date)

              venue_uri = URI.parse("https://www.eventbriteapi.com/v3/venues/#{@event_info["events"][0]["venue_id"]}/?token=#{ygl_eb_token}")
              https = Net::HTTP.new(uri.host, uri.port)
              https.use_ssl = true

              @venue_data = https.get(venue_uri)
              @venue_info = JSON.parse(@venue_data.body)

              if !@event_info["events"][0]["logo"].nil?
                eventImage = @event_info["events"][0]["logo"]["url"]
              else
                eventImage = '/assets/img/chicago-ygl-logo.png'
              end

              if !@event_info["events"][0]["description"].nil?
                eventDescription = "<p> #{@event_info["events"][0]["description"]["text"]} </p>"
              else
                eventDescription = ""
              end

              return "
              <div class='event'>
                  <div class='event-item'>
                  <h4>#{@parsed_date.strftime("%A %b %d at %I:%M %p")}</h4>
                  <h3>#{@event_info["events"][0]["name"]["text"]}</h3>
                    #{eventDescription}
                    <h4>#{@venue_info["name"]}</h4>
                    <p>#{@venue_info["address"]["localized_address_display"]}</p>
                  <p><a class='button' href='#{@event_info["events"][0]["url"]}'>RSVP</a>
                    <a href='#{@event_info["events"][0]["url"]}'>Details</a></p>
                  </div>
                  <div class='event-item'>
                    <img class='event-photo' src='#{eventImage}'/>
                  </div>
                </div>"

            else
              return "<div class='event'><h2> No events scheduled currently. Check back soon! </h2></div>"
            end
            
        end
    end
end

Liquid::Template.register_tag('eventbrite_event', Jekyll::EventbriteEvent)