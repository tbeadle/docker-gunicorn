#!/usr/bin/env python

from __future__ import print_function

import jinja2
import os
import subprocess
import time

__metaclass__ = type

class InvalidProjectError(Exception):
    pass


CRON_ENV = '/etc/cron.env'

NGINX_VARS = os.environ.copy()
NGINX_VARS.setdefault('CA_CERT', '')
NGINX_VARS.setdefault('CLIENT_MAX_BODY_SIZE', '10m')
NGINX_VARS.setdefault('CLIENT_BODY_BUFFER_SIZE', '128k')
NGINX_VARS.setdefault('KEEPALIVE_TIMEOUT', '0')
NGINX_VARS.setdefault('INCLUDE_HTTP_CONF', None)
NGINX_VARS.setdefault('INCLUDE_SERVER_CONF', None)
NGINX_VARS.setdefault('PROXY_READ_TIMEOUT', '60s')
NGINX_VARS.setdefault('SERVER_NAME', '')
NGINX_VARS.setdefault('SSL_BUNDLE', '')
NGINX_VARS.setdefault('STATIC_EXPIRES', '7d')
NGINX_VARS.setdefault('STATIC_URL', '/static/')
NGINX_VARS.setdefault('STATIC_ROOT', '/static/')
NGINX_VARS.setdefault('USE_HSTS', '1')

SUPERVISOR_VARS = os.environ.copy()
SUPERVISOR_VARS.setdefault('APP_MODULE', 'proj.wsgi')
SUPERVISOR_VARS.setdefault('APP_ROOT', '')
SUPERVISOR_VARS.setdefault('GUNICORN_ARGS', '')
SUPERVISOR_VARS['WEBPACK_CONFIG'] = (
    os.environ['WEBPACK_CONFIG']
    if (
        not os.environ.get('PROD', '') and
        os.path.exists(os.environ['WEBPACK_CONFIG']) and
        os.path.exists(os.path.join('/node_modules', '.bin', 'webpack'))
    ) else ''
)
SUPERVISOR_VARS.setdefault('WEBPACK_ARGS', '')
SUPERVISOR_VARS.setdefault('WWW_USER', 'www-data')

GUNICORN_VARS = os.environ.copy()

ENV = jinja2.Environment(
    autoescape=False,
    loader=jinja2.FileSystemLoader([
        '{}/docker/templates'.format(os.environ['APP_ROOT']),
        os.environ['TEMPLATE_DIR'],
    ]),
)

def render_template(name, tpl_vars, outfile):
    template = ENV.select_template((name, 'base/{}'.format(name)))
    with open(outfile, 'w') as fil:
        print(template.render(**tpl_vars), file=fil)

def render_templates():
    render_template(
        'nginx.conf.jinja',
        NGINX_VARS,
        '/etc/nginx/nginx.conf'
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

def save_cron_env():
    print(
        'Saving environment to be available for cron jobs in {}.'
        .format(CRON_ENV)
    )
    if os.path.exists(CRON_ENV):
        os.unlink(CRON_ENV)
    with open(CRON_ENV, 'w') as fil:
        pass
    os.chown(CRON_ENV, 0, 0)
    os.chmod(CRON_ENV, 0o400)
    with open(CRON_ENV, 'a') as fil:
        for key in sorted(os.environ):
            val = os.environ[key]

            # Escape single quote characters in the values because we'll be
            # surrounding the value in single-quotes.
            val = val.replace(r"'", r"\'")

            # Escape backslashes so the shell doesn't try to interpret the
            # following character as special.
            val = val.replace("\\", "\\\\")

            print("export {}='{}'".format(key, val), file=fil)

    return


class DjangoHook:
    def __init__(self):
        try:
            import django  # NOQA
        except ImportError:
            raise InvalidProjectError
        self.manage_path = os.path.join(os.environ['APP_ROOT'], 'manage.py')
        if not os.path.exists(self.manage_path):
            raise InvalidProjectError
        try:
            if 'django' not in subprocess.check_output(
                    self.manage_path).decode('utf-8', errors='ignore'):
                raise InvalidProjectError
        except subprocess.CalledProcessError:
            raise InvalidProjectError
        print('Detected a django project...')

    def add_clearsessions_cron_job(self):
        print('Adding clearsessions daily cron job.')
        path = '/etc/cron.daily/clearsessions'
        with open(path, 'w') as fil:
            print(
                "#!/bin/bash\n"
                "[[ -f {0} ]] && . {0}\n"
                "{1} clearsessions >/dev/null 2>&1\n"
                .format(CRON_ENV, self.manage_path),
                file=fil
            )
        os.chmod(path, 0o755)

    def collectstatic(self):
        print('Collecting static files.')
        subprocess.check_call([
            self.manage_path,
            'collectstatic',
            '-l',
            '--noinput'
        ])

    def migrate_db(self):
        def make_shell():
            return subprocess.Popen(
                [self.manage_path, 'shell'],
                stdin=subprocess.PIPE,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE
            )
        out, outerr = make_shell().communicate(
            ('from django.conf import settings; '
            'print(settings.DATABASES or "")').encode('ascii')
        )
        if 'ENGINE' not in out.decode('ascii'):
            return

        print('Waiting for database to be ready.')
        for _ in range(20):
            out, outerr = make_shell().communicate(
                ('from django.db.utils import OperationalError\n'
                'from django.db import connection\n'
                'connection.cursor()').encode('ascii')
            )
            if 'Traceback' not in out.decode('ascii'):
                break
            else:
                time.sleep(1)
        else:
            raise RuntimeError('Database is not ready to accept connections.')

        print('Running migrations on database.')
        subprocess.check_call([self.manage_path, 'migrate'])

    def process(self):
        self.add_clearsessions_cron_job()
        self.migrate_db()
        self.collectstatic()

def main():
    render_templates()
    save_cron_env()
    try:
        proj = DjangoHook()
    except InvalidProjectError:
        pass
    else:
        proj.process()

if __name__ == '__main__':
    main()
