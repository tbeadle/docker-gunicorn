#!/usr/bin/env python

from __future__ import print_function

import jinja2
import os

NGINX_VARS = {
    'CA_CERT': os.environ.get('CA_CERT', ''),
    'CLIENT_MAX_BODY_SIZE': os.environ.get('CLIENT_MAX_BODY_SIZE', '10m'),
    'KEEPALIVE_TIMEOUT': os.environ.get('KEEPALIVE_TIMEOUT', '0'),
    'INCLUDE_SERVER_CONF': os.environ.get('INCLUDE_SERVER_CONF', None),
    'SERVER_NAME': os.environ.get('SERVER_NAME', ''),
    'SSL_BUNDLE': os.environ.get('SSL_BUNDLE', ''),
    'STATIC_URL': os.environ.get('STATIC_URL', '/static/'),
    'STATIC_ROOT': os.environ.get('STATIC_ROOT', '/static/'),
    'USE_HSTS': bool(os.environ.get('USE_HSTS', '1')),
}

SUPERVISOR_VARS = {
    'APP_MODULE': os.environ.get('APP_MODULE', 'proj.wsgi'),
    'GUNICORN_ARGS': os.environ.get('GUNICORN_ARGS', ''),
    'WWW_USER': os.environ.get('WWW_USER', 'www-data'),
}

GUNICORN_VARS = {
}

ENV = jinja2.Environment(
    autoescape=False,
    loader=jinja2.FileSystemLoader([
        '{}/docker/templates'.format(os.environ['APP_ROOT']),
         os.environ['TEMPLATE_DIR'],
    ]),
    undefined=jinja2.StrictUndefined,
)

def render_template(name, tpl_vars, outfile):
    template = ENV.get_template(name)
    with open(outfile, 'w') as fil:
        print(template.render(**tpl_vars), file=fil)

def main():
    render_template(
        'nginx.conf.jinja',
        NGINX_VARS,
        '/etc/nginx.conf'
    )
    render_template(
        'supervisord.conf.jinja',
        SUPERVISOR_VARS,
        '/etc/supervisord.conf'
    )
    render_template(
        'gunicorn.conf.jinja',
        GUNICORN_VARS,
        '/etc/gunicorn.conf'
    )

if __name__ == '__main__':
    main()
