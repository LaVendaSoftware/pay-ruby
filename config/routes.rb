LavendaPay::Engine.routes.draw do
  post "/", to: "webhooks#create"
end
