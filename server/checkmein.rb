module CMI

  require "as-extensions"
  ASE::need %w{ohm ohm/contrib httparty oauth2 json}

  root = File.expand_path(File.dirname(__FILE__))

  CFG = {
    debug: true,
    msapi: {
      key: ENV["MS_API_KEY"],
      secret: ENV["MS_API_SECRET"],
    },
    fsq: {
      key: ENV["FSQ_CLIENT_ID"],
      secret: ENV["FSQ_CLIENT_SECRET"],
      callback: "/auth/foursquare/callback"
    },
    path: {
      public: File.join(root,"public"),
      root: root,
    },
    redis: {
      db: 11,
      path: "/tmp/redis.sock",
      thread_safe: false,
    },
  }
  
  CFG[:sinatra_settings] = {
    bind: "127.0.0.1",
    dump_errors: true,
    environment: :production,
    logging: true,
    public: CFG[:path][:public],
    sessions: true,
    mustache: {
      views: File.join(root,'views/'),
      templates: File.join(root,'templates/')
    }
  }

  ASE::require_part %w{ohm msapi}
  Ohm::connect(CFG[:redis])

end