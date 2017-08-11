# docker-gunicorn
This repo contains files that can be used to build docker images that can make
deployment of WSGI applications a breeze.  There are Dockerfiles to build images
that can be used when the appication is written for Python 2.7 or 3.5.  You
*are* using Python 3.5+, right?

The image uses NGINX as the web server and proxies appropriate requests to
gunicorn.  They are managed by supervisord.

See the `examples` directory for some example projects using this.

## Building the image

To build these images, simply run:

```bash
docker build -t <image_name:version-rev> -f Dockerfile.<version> .
docker build -t <image_name:version-rev>-onbuild -f Dockerfile.<version>-onbuild .
```

For instance:

```bash
docker build -t tbeadle/gunicorn-nginx:3.5 -f Dockerfile.3.5 .
docker build -t tbeadle/gunicorn-nginx:3.5-onbuild -f Dockerfile.3.5-onbuild .
```

You can also just use the supplied `build_images.sh` script.

**Better yet**, just pull down the image from docker hub:

```bash
docker pull tbeadle/gunicorn-nginx:3.6-r1-onbuild
```

## Building the image for your app

To use the image for for your application, simply create a Dockerfile in the
root of your application's repo that at least contains:

```
FROM tbeadle/gunicorn-nginx:3.6-r1-onbuild
```

Obviously, replace `3.6` with the appropriate version if using something other
than Python 3.6 for your application.

The `-r#` in the tag represents the version of the image for that particular
python version.

That is all that is **required** to be in your Dockerfile.

### Installing additional python dependencies

Next, create a `docker` directory at the root of your application's repo.  In
that directory, create a `requirements.txt` file that will be given to `pip
install -r` when your application's image is built.

### Installing javascript dependencies

To have javascript depenedencies installed in your image, you may create a
`package.json` file in the `docker` directory that was just created.  This file
will be used by `npm install --production` to install all production
dependencies (i.e. those not in the `devDependencies` key) into the image).
These packages will be installed in `/node_modules` so that you can use lines
like `require('lodash')` in your javascript code and not have to provide
explicit paths or have the dependencies inside of your project's codebase.

### Running webpack

If there is a `docker/webpack.config.js` file (or whatever the `WEBPACK_CONFIG`
variable is set to) and webpack was installed as a dependency (see previous
section), then webpack will be run to bundle your static assets in to the
location(s) defined in that config.  You can pass additional args to webpack by
defining them in a `WEBPACK_ARGS` environment variable.  See the `using_webpack`
project in the `samples` directory of this repo for an example of how that can
be used.

## Starting your container

To start a container using this image, I suggest using
[docker-compose](https://docs.docker.com/compose/).  In that file, you can
define environment variables that will be used in templates to generate config
files for nginx, gunicorn, and supervisord.

The following environment variables are supported:

### NGINX variables

Variable name | Meaning
--------------|------------
CA_CERT | The path to a .pem formatted file used for OCSP stapling.  (Defaults to not using OCSP stapling)
CLIENT_BODY_BUFFER_SIZE | The buffer size for reading the body of a client request.  (Defaults to 128k)
CLIENT_MAX_BODY_SIZE | The maximum size for the body of a request.  (Defaults to 10 MB)
KEEPALIVE_TIMEOUT | The timeout during which a keep-alive client connection will stay open on the server side.  (Defaults to disabling keep-alive client connections)
INCLUDE_HTTP_CONF | The path to an additional Jinja2 template that will get *included* in the **http** context of the nginx config file.  (Defaults to no additional config)
INCLUDE_SERVER_CONF | The path to an additional Jinja2 template that will get *included* in the **server** context of the nginx config file.  (Defaults to no additional config)
PROXY_READ_TIMEOUT | If the gunicorn worker does not transmit anything within this number of seconds, the connection is closed. (Defaults to '60s')
SERVER_NAME | A space-separated list of server names used to match the **Host** header of client requests. (Defaults to using no `server_name` statement)
SSL_BUNDLE | The patch to a .pem formatted SSL cert.  If specified, then all HTTP requests will be redirected to HTTPS.  (Defaults to not using SSL.  Please HTTPS all the things!)
STATIC_EXPIRES | Indicates for how long static files show be allowed to be cached.  See http://nginx.org/en/docs/syntax.html for the expected format.  (Defaults to `7d`)
STATIC_URL | The URL path to where static files are to be stored.  These will be served by nginx and not proxied to gunicorn.  (Defaults to `/static/`)
STATIC_ROOT | The file system path where static files will be stored.  (Defaults to `/static/`)
USE_HSTS | If set to an empty string, HSTS will not be enabled.  Otherwise, it will be enabled.  (Defaults to being enabled and should **not** be disabled in production!)

### SUPERVISOR variables

Variable name | Meaning
--------------|------------
APP_MODULE | The python module containing the application's entry point.  (Defaults to `proj.wsgi`)
GUNICORN_ARGS | Additional command-line arguments that will get passed to gunicorn.  (Defaults to the empty string)
WEBPACK_ARGS | Additional arguments to pass to webpack, such as "-p" to minify the output bundles.  Defaults to "".
WEBPACK_CONFIG | An alternative location of the webpack config file.  (Defaults to /app/docker/webpack.config.js).
WWW_USER | The user to run gunicorn as.  (Defaults to `www-data`)

The templates are [Jinja2](http://jinja.pocoo.org/)-based templates stored in
`/etc/deploy/templates/base/`, but can be overridden by creating any of
`nginx.conf.jinja`, `supervisord.conf.jinja`, or `gunicorn.conf.jinja` in a
`docker/templates/` directory at the root of your application's repo.

The base supervisord template has an `[include]` section that will cause all
files ending in `.conf` in an `/etc/supervisord.d/` directory to be included.
This allows you to copy files to this location in your container or just mount
a volume for that directory.

If you do define your own templates, all environment variables starting with
`USER_` will also be available within any of those templates.  Also, if you want
to *extend* the base templates, just use `{% extends 'base/<templatename>' %}`.

Note that, when setting variables to paths located within your application's
directory, your application will be rooted at `/app` within the image.

If the container is started and there is no `PROD` environment variable set (or
it's set to an empty string), this indicates that it is being run in
"development" mode.  In this mode, there are 2 additional things that happen
during container startup:

 - If there is a `package.json` file in the `docker` directory, `npm install` is
   run again, this time in "development" mode, to install **devDependencies**.
   It keeps track of the last time this was run so that, if you stop and start
   the container, it won't do this again unless the package.json has been
   modified since that time.
 - If using webpack, the `supervisord.conf` file will have a section added to
   it so that webpack will be run in the background with the `--watch` flag.
   This will cause it to detect when changes are made to your source javascript
   files and automatically generate new bundles at that time.

A sample `docker-compose.yml` could look like this:

```yaml
version: "2"

services:
  ui:
    image: tbeadle/sample:0.1
    build:
      context: .
    environment:
      GUNICORN_ARGS: --reload
      PROD: 1
      SSL_BUNDLE: /private/sample.pem
      WEBPACK_ARGS: -p
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./private:/private:ro
```

## Customizing how the image is built

In the `docker` directory located at the root of your application, there may be
2 other directories that can be created to customize the build process.  In both
cases, any executable file in the directory will get run and it will happen in
lexicographical order.

A `pre-build.d` directory may contain scripts that will get run **before** the
dependencies defined in `requirements.txt` are installed.  This can be used,
for instance, to install dev packages containing header files necessary to
build some of the python libraries.  Here's an example that could be used to
install the Postgres headers needed to build psycopg2 and the `psql` client:

`docker/pre-build.d/01_install_dev_packages.sh`

```bash
#!/bin/bash

set -eo pipefail

apt-get update
apt-get install -y --no-install-recommends libpq-dev postgresql-client-9.4
rm -r /var/lib/apt/lists/*
```

A `post-build.d` directory may contain scripts that will get run **after**
`pip install` is run.

## Customizing how the container is started

When the container is started, the templates used for building the configuration
files will be processed and the resulting config files installed in the
appropriate location.  If you need to do anything **before** that happens, you
can create a directory called `docker/pre-deploy.d/` and put executable scripts
in there.  These will get run in lexicographical order before the templates are
processed.  Scripts in a `docker/post-deploy.d/` directory will get run
**after** the templates are processed.

## Logs

Logs for nginx are stored in /var/log/supervisor/nginx.  Logs for gunicorn are stored in
/var/log/supervisor/gunicorn.  Output from supervisor is sent to stdout when
`docker-compose up` is run.

## Cron

A cron process is managed by supervisord to make it easy for you to add cron
jobs.  If you need access to environment variables that are defined for the
container, you can source the file /etc/cron.env to have those variables
available to your script, since cron normally runs jobs with a mostly empty
environment.

## Using with Django apps

When a container using this image is started, it will attempt to detect if it is
a Django project by looking for Django's `manage.py` script in the root of the
app directory.  If it detects that it is a Django project, it will:

 - Add a daily cron job to run `manage.py clearsessions` (see
   https://docs.djangoproject.com/en/1.10/ref/django-admin/#django-contrib-sessions).
 - If a database is defined in the project's `settings.py` file, it will wait
   for the database to accept connections and then run `manage.py migrate` to
   run database migrations.
 - Run `manage.py collectstatic -l --noinput` to collect static files in
   `STATIC_ROOT`.

## Contributing

**Please please please** help me make this better by submitting pull requests,
reporting bugs, submitting feature requests, etc.
