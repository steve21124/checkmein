module CMI
  ASE::need %w{sinatra/base mustache/sinatra json oauth2 net/https}
  class App < Sinatra::Base
    register Mustache::Sinatra
    require File.join(CFG[:path][:root], "views", "layout")
    before do
      puts "PARAMS: #{params}" if CFG[:debug] && !request.get?
    end
  end
  ASE::require_part %w{settings auth about}
end