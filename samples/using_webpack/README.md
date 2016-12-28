This is an example of how to use the base image for deploying a simple Django
app that includes some javascript that has some dependencies installed via npm
and is to be bundled and minified using WebPack.

To build the image, just run:

`docker-compose build`

Then run:

`docker-compose up`

to start the container.  Then point your web browser to http://localhost.

This follows the guide from
http://owaislone.org/blog/webpack-plus-reactjs-and-django/
for integrating Django with webpack.
