module CMI class App; module Views
  class Layout < Mustache
    def title
      @title || "Check Me In"
    end
  end  
end end end
