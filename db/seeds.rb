# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

case ENV['INTEGRATION_SPECS']
  when '1'
    Peer.find_or_create_by!(name: 'Peer 2', onion_address: 'peer_2:3000')
  when '2'
    Peer.find_or_create_by!(name: 'Peer 1', onion_address: 'peer_1:3000')
    Peer.find_or_create_by!(name: 'Peer 3', onion_address: 'peer_3:3000')
  when '3'
    Peer.find_or_create_by!(name: 'Peer 2', onion_address: 'peer_2:3000')
    Peer.find_or_create_by!(name: 'Peer 4', onion_address: 'peer_4:3000')
  when '4'
    Peer.find_or_create_by!(name: 'Peer 3', onion_address: 'peer_3:3000')
  else
    # Dev seeds, tbd
end

if ENV['INTEGRATION_SPECS']
  Ad.destroy_all
  Webhook::Send.destroy_all
  Webhook::Receipt.destroy_all
end