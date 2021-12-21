# README

This README would normally document whatever steps are necessary to get the
application up and running.

But instead we use Docker.

(Otherwise it's a pretty vanilla rails 7 app still using sqlite)

```
git clone https://github.com/dakhodl/peacemaker.git
cd peacemaker
brew install tor // or apt-get install tor - whatever you use
chmod 0700 hidden_service/ // tor will complain in next line if you don't do this
tor -f config/torrc-dev // generate some onion keys for yourself, into hidden_service/
<< Kill with Ctrl+C >> // kill tor service
cat hidden_service/hostname // here's your new .onion
docker-compose build
// grab a coffee - first bundle could take a while
docker-compose up web // starts the server in development
// browse to the .onion you saw in hidden_service/hostname
// first load will compile JS assets, grab another coffee
```

### Running tests

Right now this is run outside of docker. So you'll have to set up a vanilla rails environment the old fashioned way.

`rspec spec`

We have two types of tests.

* request specs - these test api endpoints from routing layer to database.
* feature specs - these end to end test the UI as best as possible, not fully p2p e2e tests since the p2p calls are stubbed out.

If I could, I'd only have feature specs. It wasn't clear how to orchestrate N peers in an automated test environment and selenium through them all.

Probably unit tests will come around at some point as complexity mandates.

### Roadmap

* ~~I can add other .onion peers~~
* ~~I can post an Ad that gets propagated to my peers~~
* I can designate a Peer at various trust levels: High, Medium, and Low
* I can propagate Ads from my peers to my other peers. Ads stay in trust level they come from, or something. :thinking_face:
* I can fine tune an Ad to say how far I want it to hop to other peers. Or maybe this is a function of trust. :thinking_face:

### Technical roadmap

* ~~Sidekiq/worker container - ads propagated in a background worker so Ad create does not timeout~~
* tor service container extracted out of web
  *  still learning Docker
* ~~webpack install/manifest.json not part of every boot (upgraded to rails 7)~~
* tor onboarding automated with https://github.com/RubyCrypto/ed25519 (and requests signed with tor keys)?