namespace :print_onion do
  task :address do
    puts File.read('hidden_service/hostname').to_s.strip
  end

  task :secret_key do
    puts File.read('hidden_service/hs_ed25519_secret_key')
  end

  task :public_key do
    puts File.read('hidden_service/hs_ed25519_public_key')
  end
end
