# Put all your default configatron settings here.

# Example:
#   configatron.emails.welcome.subject = 'Welcome!'
#   configatron.emails.sales_reciept.subject = 'Thanks for your order'
#
#   configatron.file.storage = :s3

# Generates an identify for us to sign
# following https://github.com/RubyCrypto/rbnacl/wiki/Digital-Signatures

KEYFILE_NAME = "hidden_service/peacemaker_key#{ENV['INTEGRATION_SPECS'].present? ? "-#{ENV['INTEGRATION_SPECS']}" : ''}"

if File.exists?(KEYFILE_NAME)
  signing_key = RbNaCl::SigningKey.new File.read(KEYFILE_NAME).b
else
  signing_key = RbNaCl::SigningKey.generate
  File.open(KEYFILE_NAME, 'wb') do |f|
    f.write(signing_key.to_s.b)
  end
end

configatron.signing_key = signing_key