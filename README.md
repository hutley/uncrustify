Contains routes for api.fanhattan.com's router.

Prerequisite: you have router-api started and running on 3010. `rackup -p 3010`

To load all routes: `RACK_ENV=development ruby load-routes.rb`
To commit all routes: `RACK_ENV=development ruby commit.rb`

You should only have to modify the `development` section of backends.yml for your local environment if you are running fhapi on a port other than 4568.

