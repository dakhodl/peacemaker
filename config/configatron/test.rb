# Override your default settings for the Test environment here.
#
# Example:
#   configatron.file.storage = :local

configatron.my_onion = ENV['INTEGRATION_SPECS'] ? "peer_#{ENV['INTEGRATION_SPECS']}:3000" : 'my_local_onion.onion'
