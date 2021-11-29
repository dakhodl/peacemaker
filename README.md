# README

This README would normally document whatever steps are necessary to get the
application up and running.

But instead we use Docker.

```
git clone https://github.com/dakhodl/peacekeeper.git
cd peacekeeper
brew install tor // or apt-get install tor - whatever you use
mkdir hidden_service/
chmod 0700 hidden_service/
tor -f config/torrc-dev // generate some onion keys for yourself, into hidden_service/
<< Kill Ctrl+C >>
cat hidden_service/hostname
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