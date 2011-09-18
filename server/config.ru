require File.join(File.dirname(__FILE__),"checkmein")
require File.join(File.dirname(__FILE__),"checkmein","sinatra")

app = Rack::URLMap.new({
  "/" => CMI::App.new,
})

run app
