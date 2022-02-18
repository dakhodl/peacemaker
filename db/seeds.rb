# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
require 'sidekiq/api'


case ENV['INTEGRATION_SPECS']
  when '1'
    Peer.find_or_create_by!(name: 'Peer 2', onion_address: 'peer_2:3000', trust_level: :high_trust)
  when '2'
    Peer.find_or_create_by!(name: 'Peer 1', onion_address: 'peer_1:3000', trust_level: :high_trust)
    Peer.find_or_create_by!(name: 'Peer 3', onion_address: 'peer_3:3000', trust_level: :high_trust)
  when '3'
    Peer.find_or_create_by!(name: 'Peer 2', onion_address: 'peer_2:3000', trust_level: :high_trust)
    Peer.find_or_create_by!(name: 'Peer 4', onion_address: 'peer_4:3000', trust_level: :high_trust)
  when '4'
    Peer.find_or_create_by!(name: 'Peer 3', onion_address: 'peer_3:3000', trust_level: :high_trust)
  when '5'
    Peer.destroy_all
  else
end

if ENV['INTEGRATION_SPECS']
  Ad.destroy_all
  MessageThread.destroy_all
  Webhook::Send.destroy_all
  Webhook::Receipt.destroy_all
  Sidekiq::Queue.all.each(&:clear)
  Sidekiq::RetrySet.new.clear
  Sidekiq::ScheduledSet.new.clear
  Sidekiq::DeadSet.new.clear

  PeerStatusCheckJob.set(wait: 15.seconds).perform_later
end


IPSUM = [%q{
  Lorem ipsum dolor sit amet, consectetur adipiscing elit. Morbi maximus felis ut interdum venenatis. Morbi gravida pretium odio ut condimentum. 
},
%q{
  Phasellus dictum lorem id nisi semper, nec cursus sapien porta. Suspendisse tristique lacus quam, et ultrices ligula sodales et. Aenean urna risus, pellentesque sed placerat a, fermentum vitae ligula. Aliquam quam turpis, efficitur lacinia libero sed, mollis ullamcorper erat. Fusce lacinia tristique ex. Proin mattis elit tortor, nec ultrices magna aliquet a.
},
%q{
  Mauris lacinia sagittis ipsum sit amet molestie. Morbi sed diam venenatis, blandit risus et, porttitor leo. Donec nec nulla vitae lorem egestas euismod. 
},
%q{
  Quisque eu ante non mauris volutpat sodales. Ut ullamcorper tortor vitae ante fringilla tristique. Quisque imperdiet pulvinar lectus accumsan blandit. Nulla commodo nisl quis nunc pharetra semper. Pellentesque diam ex, interdum quis pharetra quis, semper in arcu. Nullam id mauris mauris. Duis odio sem, aliquet id sollicitudin sed, tincidunt vitae felis. Suspendisse sed nisi egestas, molestie odio in, posuere nisl. Quisque egestas vel urna non efficitur.
},
%q{
  Morbi tristique augue eu leo mollis, porttitor viverra odio lobortis. Fusce ac porta tortor. Nulla tempus augue ut sem dictum tincidunt sed at ligula. 
},
%q{
  Sed tincidunt felis quis turpis gravida fermentum. Aliquam fermentum, justo porta luctus consequat, lectus lectus aliquet elit, id laoreet arcu nibh sed magna. Suspendisse nec finibus metus. Nunc sit amet iaculis velit. Nulla facilisi. Fusce ac augue sed eros commodo accumsan et a mi. Curabitur et interdum felis. Aliquam ante orci, sodales eu nunc in, facilisis semper nisl. Aenean in quam finibus libero elementum porttitor. Aenean mattis mi quis massa facilisis suscipit.
},
%q{
  Nullam laoreet vitae urna non varius. Cras at ullamcorper magna. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Pellentesque congue erat sit amet tortor laoreet, a porta nisl sagittis. 
},
%q{
  Suspendisse mattis varius sem, quis ullamcorper justo elementum ut. Pellentesque in eros vulputate, elementum orci at, tristique ante. Fusce vitae erat eros. Duis efficitur tellus in mauris commodo, id elementum nulla dictum. In rutrum vitae lacus et accumsan. Maecenas vitae accumsan elit. Nullam efficitur rutrum ligula, quis mollis libero finibus ac.
},
%q{
  Maecenas scelerisque at erat vel aliquet. Nam hendrerit, elit id rutrum porta, tellus urna congue libero, sit amet placerat leo nisi non nisl. Vestibulum mauris diam, dignissim sed eros dapibus, eleifend fermentum enim. 
},
%q{
  Maecenas sollicitudin auctor dui, ut blandit dui posuere sit amet. Fusce ornare, leo et luctus sagittis, lorem enim vestibulum nulla, a rutrum risus augue at ante. Aenean accumsan lacus sed elit sagittis, eget tincidunt nibh pellentesque. Nulla fermentum non arcu eu cursus. Donec pharetra venenatis scelerisque. Proin semper porta faucibus. Fusce a nunc purus. Etiam a nisl euismod enim auctor faucibus. Nulla tincidunt massa quis justo fermentum, ut aliquet nibh efficitur. Quisque nulla arcu, placerat vel lacus quis, ultricies vestibulum leo. Quisque non feugiat sem, ut aliquam magna. Aenean sed mi ipsum.
}
]

if Rails.env.development?
  peer_1 = Peer.find_or_create_by!(name: 'Bobby McGee', onion_address: 'abc123.onion', trust_level: :high_trust)
  ad_1 = peer_1.ads.find_or_create_by!(title: "Fresh eggs", message: "Delivery by fee", hops: 0, onion_address: peer_1.onion_address)
  ad_2 = peer_1.ads.find_or_create_by!(title: "73 ford 150", message: "250k miles, fresh rubber in feb, runs like new", hops: 1, onion_address: '2nddegree.onion')
  ad_3 = peer_1.ads.find_or_create_by!(title: "40s-50s model tractor parts", message: "You name it we'll pull it from the junkyard and ship it.", hops: 2, onion_address: '3rddegree.onion')

  peer_2 = Peer.find_or_create_by!(name: "3˚ peer via Bobby McGee", onion_address: "3rddegree.onion", trust_level: :low_trust)
  peer_3 = Peer.find_or_create_by!(name: "2˚ peer via Bobby McGee", onion_address: "2nddegree.onion", trust_level: :low_trust)

  MessageThread.destroy_all
  5.times do |n|
    Message.create!(ad: ad_3, peer: peer_2, body: IPSUM.sample, author: n % 2, created_at: n.days.ago)
    Message.create!(ad: ad_2, peer: peer_3, body: IPSUM.sample, author: n % 2, created_at: n.days.ago)
  end
end