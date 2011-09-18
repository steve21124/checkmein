module CMI class App
  
  # OAuth 2 authentication workflow adapted from
  # https://github.com/matthunter/foursquare-ruby-example
  def client
    OAuth2::Client.new(CFG[:fsq][:key], CFG[:fsq][:secret], 
      :site => ' http://foursquare.com/v2/',
      :request_token_path => "/oauth2/request_token",
      :access_token_path  => "/oauth2/access_token",
      :authorize_path     => "/oauth2/authenticate?response_type=code",
      :parse_json => true
    )
  end
  
  def redirect_uri
    uri = URI.parse(request.url)
    uri.path = CFG[:fsq][:callback]
    uri.query = nil
    uri.to_s
  end
  
  get("/hello/?") do
    content_type(:json)
    {hello: "world"}.to_json
  end
  
  get '/auth/foursquare/callback' do
    # access_token = client.web_server.get_access_token(params[:code], :redirect_uri => redirect_uri)
    # It would be better to use the line above but it returns a 301 error, so I use the hack below instead.
    # start hack
    uri = URI.parse("https://foursquare.com/oauth2/access_token?client_id=#{CFG[:fsq][:key]}&client_secret=#{CFG[:fsq][:secret]}&grant_type=authorization_code&redirect_uri=#{redirect_uri}&code=" + (params[:code]||''))
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Get.new(uri.request_uri)
    response = JSON.parse(http.request(request).body)
    access_token = OAuth2::AccessToken.new(client, response["access_token"])
    # end hack
    # some user data as an example
    user = access_token.get('https://api.foursquare.com/v2/users/self')
    user.inspect
    # TODO:
    # * create or update the user
    # * index or update avator on Moodstocks API
    mustache(:auth, :layout => :layout)
  end
  
end end
