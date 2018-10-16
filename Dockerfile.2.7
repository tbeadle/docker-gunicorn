FROM debian:stretch

ENV \
	PYTHON_VERSION=2.7.15 \
	NGINX_VERSION=1.14.0 \
	GUNICORN_VERSION=19.9.0 \
	SUPERVISOR_VERSION=3.3.4 \
	NODE_VERSION=8.12.0 \
	NPM_VERSION=6.1.0 \
	YARN_VERSION=1.10.1 \
	LANG=en_US.UTF-8 \
	WWW_USER=www-data \
	WWW_GROUP=www-data \
	APP_ROOT=/app \
	PROJ_ROOT=/app \
	INSTALL_ROOT=/usr/local \
	BUILD_ROOT=/tmp/build \
	READY_FILE=/run/ready \
	TEMPLATE_DIR=/etc/deploy/templates \
	WEBPACK_CONFIG=/app/docker/webpack.config.js \
	PACKAGE_JSON=/app/docker/package.json

COPY install_base_deps.sh ${BUILD_ROOT}/install_base_deps.sh
RUN ${BUILD_ROOT}/install_base_deps.sh

COPY base/ ${BUILD_ROOT}/base/
RUN ${BUILD_ROOT}/base/run.sh && \
	rm -Rf ${BUILD_ROOT}/

COPY deploy/ /etc/deploy/
COPY entrypoint.sh /
ENTRYPOINT [ "/entrypoint.sh" ]
EXPOSE 80
VOLUME [ "/var/log" ]
