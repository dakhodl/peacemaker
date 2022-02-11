# Put all your default configatron settings here.

# Example:
#   configatron.emails.welcome.subject = 'Welcome!'
#   configatron.emails.sales_reciept.subject = 'Thanks for your order'
#
#   configatron.file.storage = :s3

if File.exists?("hidden_service/peacemaker_key")
  secret_key = RbNaCl::PrivateKey.new File.read('hidden_service/peacemaker_key').b
else
  secret_key = RbNaCl::PrivateKey.generate
  File.open('hidden_service/peacemaker_key', 'wb') do |f|
    f.write(secret_key.to_s.b)
  end
end

configatron.public_key = secret_key.public_key
configatron.secret_key = secret_key