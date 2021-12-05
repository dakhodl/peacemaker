Tor.configure do |config|
  config.ip = "web" # docker-compose container name
  config.port = 9050
  config.add_header('Content-Type', 'application/json')
  config.add_header('X-Peacemaker-From', File.read("hidden_service/hostname").to_s.strip)
end