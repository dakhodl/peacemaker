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

Currently these are run from the `web` container.

```
docker-compose exec web bundle exec rspec
```

We have two types of tests.

* spec/requests - these test api endpoints from routing layer to database changes.
* spec/integrations - these end to end test the UI on a peer network within several containers

Only request specs run through docker. You'll need to stand up your own rails env locally to run Integration specs with chromedriver.

To run peer to peer end to end integration specs, first boot up the peer network and selenium container. (Apple m1 not supported yet.)

```
bin/integration_testnet
```

Then run the spec_runner:

```
bin/integration_specs
```

That script ensures the DB is reset before booting capybara to drive UI tests.

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
https://github.com/users/dakhodl/projects/1
