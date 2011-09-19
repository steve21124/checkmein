module CMI class App

  get("/about/?") do
    mustache(:about, :layout => :layout)
  end
  
  get("/toolbox/?") do
    mustache(:toolbox, :layout => :layout)
  end
  
  get("/next/?") do
    mustache(:next, :layout => :layout)
  end
  
end end
