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
  
  get("/") do
    mustache(:index,
             :layout => :layout,
             :locals => {:redirect_url => "https://foursquare.com/oauth2/authenticate?client_id=#{CFG[:fsq][:key]}&response_type=code&redirect_uri=#{CGI.escape(redirect_uri)}"})
  end
  
  get '/auth/foursquare/callback' do
    uri = URI.parse("https://foursquare.com/oauth2/access_token?client_id=#{CFG[:fsq][:key]}&client_secret=#{CFG[:fsq][:secret]}&grant_type=authorization_code&redirect_uri=#{redirect_uri}&code=" + (params[:code]||''))
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Get.new(uri.request_uri)
    response = JSON.parse(http.request(request).body)
    token = response["access_token"]
    resp = HTTParty.get("https://api.foursquare.com/v2/users/self?oauth_token=#{token}")
    err = false
    if resp.response.code.to_i == 200
      pic_url = resp.parsed_response["response"]["user"]["photo"].gsub("_thumbs", "")
      if pic_url =~ /(blank_boy|blank_girl)/
        # Prevent users without custom profile picture
        err = true
        ASE::log("Blank profile picture",:info)
      else
        uid = resp.parsed_response["response"]["user"]["id"]
        u = User.get(uid)
        if u.nil?
          u = User.create(uid: uid, token: token)
        else
          r = MsApi.delete(u.token)
          err = true unless r.response.code.to_i == 200
        end
        r = MsApi.addnx(pic_url, token)
        if r.response.code.to_i == 200
          # Avatars must be unique per user
          if r.parsed_response["found"] == true
            err = true 
            ASE::log("Picture already exists",:info)
          end
        else
          err = true
        end
      end
    else
      err = true
    end
    mustache(:auth,
             :layout => :layout,
             :locals => {:pic_url => pic_url, :status => (err ? 'KO' : 'OK')})
  end
  
end end
