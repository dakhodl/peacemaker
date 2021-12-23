[![Pacemaker](https://circleci.com/gh/dakhodl/peacemaker.svg?style=svg)](https://circleci.com/gh/dakhodl/peacemaker)
# Getting started

We aim to make this as simple as possible with Docker. So you have to have Docker and docker-compose installed on your system.

```
git clone https://github.com/dakhodl/peacemaker.git
cd peacemaker
docker-compose up --build -d
docker-compose exec web bundle exec rake print_onion:address
```

Copy/paste your shiny new `.onion` address from the last command above into your Tor browser and start adding peers & ads from there.

Visit 127.0.0.1:3000 in a normal browser on the machine running this for a snappier UI since it won't route through Tor network for page loads.

On subsequent app boots, just call `up` with no build.
```
docker-compose up -d
```

#### Backing up your identity

The .onion hostname and its public and private keys _are your Peacemaker identity_. Guard them well.

Your tor keys are persisted to hidden_service/ folder in the app directly. Back up as you see prudent.

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
* ~~tor service container extracted out of web~~
* ~~keys auto-generated on first boot~~
* ~~webpack install/manifest.json not part of every boot (upgraded to rails 7)~~

Moving to github issues/projects for roadmap.
