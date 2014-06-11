# Example of Authentication and Authorization Using AngularJS and Sinatra

This codebase exemplifies authentication and authorization using AngularJS for
the frontend and Sinatra as the API/backend.

* Authentication: Confirming that a user is who (s)he claims to be.
* Authorization: Specifying the access and visibility of resources to users.

See this code in action at: http://asae.pist0s.ca/

**Important Note**: It is crucial to understand that, with the way this code
is designed, no true authorization is being enforced at the frontend level
(AngularJS, browser side)!  Do *not* rely on the frontend alone to protect
sensitive data in your application.  Anything that must be protected or hidden
must be fully controlled and dispensed by the backend (API).  Observe that
access levels are set both in the frontend and the backend.

Each user has a numeric access level.  The higher the number, the more access
they have.  Assign access levels to pages and to API endpoints to restrict
access.

## Installation

    % cd sinatra
    % gem install bundler
    % bundle install

Create and migrate the database.  For PostgreSQL:

    % createuser -U postgres angular_sinatra
    % createdb -U postgres -O angular_sinatra angular_sinatra
    % bundle exec sequel -m migrations postgres://angular_sinatra@localhost/angular_sinatra
    % cp database.yaml.example database.yaml
    % ${EDITOR} database.yaml  # modify as desired

Then start the Sinatra server with:

    % PORT=3000 ./start-server.rb

Refer to the nginx or Apache example configurations for suggestions on how to
map the /api route to the Sinatra application, and how to serve the Angular
index file.
