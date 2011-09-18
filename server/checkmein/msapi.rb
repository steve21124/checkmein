module CMI module MsApi

  class Ep
    include HTTParty
    base_uri("http://api.moodstocks.com")
    digest_auth(CFG[:msapi][:key],CFG[:msapi][:secret])
  end

  class << self
    
    def echo(params={})
      Ep::get("/v2/echo", {query:params})
    end
    
    def addnx(image_url,id)
      Ep::post("/v2/ref/#{id}/addnx",{body:"",query:{image_url:image_url}})
    end
    
    def delete(id)
      Ep::delete("/v2/ref/#{id}")
    end

  end # class << self

end end
