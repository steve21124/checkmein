module CMI class App

  get("/about/?") do
    mustache(:about, :layout => :layout)
  end
  
end end
