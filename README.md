# README

This README would normally document whatever steps are necessary to get the
application up and running.

But instead we use Docker.

```
git clone https://github.com/dakhodl/peacekeeper.git
cd peacekeeper
brew install tor // or apt-get install tor - whatever you use
chmod 0700 hidden_service/ // tor will complain in next line if you don't do this
tor -f config/torrc-dev // generate some onion keys for yourself, into hidden_service/
<< Kill Ctrl+C >> // kill tor service
cat hidden_service/hostname // here's your new .onion
docker-compose build
// grab a coffee - first bundle could take a while
docker-compose up web // starts the server in development
// browse to the .onion you saw in hidden_service/hostname
// first load will compile JS assets, grab another coffee
```

### Running tests

```
docker-compose up test
```

This will boot a test environment and run the rspec suite.


### Roadmap

* ~~I can add other .onion peers~~
* ~~I can post an Ad~~ that gets propagated to my peers
* I can propagate Ads from my peers to my other peers
* I can fine tune an Ad to say how far I want it to hop to other peers.

### Technical roadmap

* Sidekiq/worker container - ads propagated in a background worker so Ad create does not timeout
* tor service container extracted out of web
  *  still learning Docker
* webpack install/manifest.json not part of every boot
* tor onboarding automated with https://github.com/RubyCrypto/ed25519 ?