# Set up for the application and database. DO NOT CHANGE. #############################
require "sinatra"                                                                     #
require "sinatra/reloader" if development?                                            #
require "sequel"                                                                      #
require "logger"                                                                      #
connection_string = ENV['DATABASE_URL'] || "sqlite://#{Dir.pwd}/development.sqlite3"  #
DB ||= Sequel.connect(connection_string)                                              #
DB.loggers << Logger.new($stdout) unless DB.loggers.size > 0                          #
def view(template); erb template.to_sym; end                                          #
use Rack::Session::Cookie, key: 'rack.session', path: '/', secret: 'secret'           #
before { puts "Parameters: #{params}" }                                               #
after { puts; }                                                                       #
#######################################################################################

events_table = DB.from(:events)
rsvps_table = DB.from(:rsvps)

get "/" do
  @events = events_table.all
  puts @events.inspect
  view "events"
end

get "/events/:id" do
    # SELECT * FROM events WHERE id=:id, have [0] at end because there should be one and only one result
    @event = events_table.where(:id => params["id"]).to_a[0]
    # SELECT * FROM rsvps WHERE event_id=:id, no [0] at end because there can be multiple results
    @rsvps = rsvps_table.where(:event_id => params["id"]).to_a
    # SELECT COUNT(*) FROM rsvps WHERE event_id=:id AND going=1
    #rsvp_table.where(:event_id => params["id"], going =>).count
    puts @event.inspect
    puts @rsvps.inspect
    view 'event'
end

get "/events/:id/rsvps/new" do
    @event = events_table.where(:id => params["id"]).to_a[0]
    view "new_rsvp"
end

get "/events/:id/rsvps/create" do
    #Where code needs to go to insert new record into DB
    rsvps_table.insert(
        :event_id => params["id"],
        :going => params["going"],
        :email => params["email"],
        :comments => params["comments"])
    view "create_rsvp"
end