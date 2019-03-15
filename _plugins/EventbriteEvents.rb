require 'uri'
require 'net/http'
require 'net/https'
require 'json'

module Jekyll
    class EventbriteEvents < Liquid::Tag

        def render(context)
            userId = "188789739786"
            ygl_eb_token = ENV['ygl_eb_token']
            uri = URI.parse("https://www.eventbriteapi.com/v3/organizations/188789739786/events/?token=#{ygl_eb_token}&order_by=start_desc&page_size=3")
            
            https = Net::HTTP.new(uri.host, uri.port)
            https.use_ssl = true
            @data = https.get(uri)
            @event_info = JSON.parse(@data.body)
            @event_date = @event_info["events"][0]["start"]["local"]
            @parsed_date = DateTime.parse(@event_date)

            eventsHtml = ""

            for event in @event_info["events"] do
              parsed_date = DateTime.parse(event["start"]["local"])
              venueId = event["venue_id"]

              venue_uri = URI.parse("https://www.eventbriteapi.com/v3/venues/#{venueId}/?token=#{ygl_eb_token}")
              https = Net::HTTP.new(uri.host, uri.port)
              https.use_ssl = true
              @venue_data = https.get(venue_uri)
              @venue_info = JSON.parse(@venue_data.body)

              if event["logo"]
                eventImage = event["logo"]["url"]
              else
                eventImage = '/assets/img/chicago-ygl-logo.png'
              end

              eventsHtml = eventsHtml + "
                <div class='event'>
                  <div class='event-item'>
                  <h4>#{parsed_date.strftime("%A %b %d at %I:%M %p")}</h4>
                  <h3>#{event["name"]["text"]}</h3>
                    <p>#{event["description"]["text"]}.</p>
                    <h4>#{@venue_info["name"]}</h4>
                    <p>#{@venue_info["address"]["localized_address_display"]}</p>
                  <p><a class='button' href='#{event["url"]}'>RSVP</a>
                    <a href='#{@event_info["events"][0]["url"]}'>Details</a></p>
                  </div>
                <div class='event-item'>
                  <img class='event-photo' src='#{eventImage}'/>
                </div>
              </div>
            "
            end
            return eventsHtml
        end
    end
end

Liquid::Template.register_tag('eventbrite_events', Jekyll::EventbriteEvents)
