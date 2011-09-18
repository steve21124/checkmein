module CMI class App

  get("/") do
    mustache(:index, :layout => :layout)
  end
  
end end