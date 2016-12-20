This is an example of how to use the base image for deploying a simple Django
app that uses PostgreSQL for a database backend.

To build the image, just run:

`docker-compose build`

Then run:

`docker-compose up`

to start the db and ui containers.  Add an entry to your /etc/hosts file:

```
127.0.0.1	djtest
```

and point your web browser to `https://djtest`.  You'll get a certificate
warning because it just uses a self-signed cert.  In production, you would
obviously want to use a real cert and remove the `USE_HSTS: ""` line from the
docker-compose.yml file so that HSTS is enabled.
