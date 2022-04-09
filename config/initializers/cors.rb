Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins Settings.frontend.url
    resource "*",
             headers: :any,
             expose: ["access-token", "expiry", "token-type", "uid", "client"],
             methods: [:get, :post, :put, :patch, :delete, :options]
  end
end
