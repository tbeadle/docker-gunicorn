FROM tbeadle/gunicorn-nginx:3.6

COPY build_app.sh /usr/local/bin/
WORKDIR ${PROJ_ROOT}
ONBUILD COPY docker/ ${PROJ_ROOT}/docker/
ONBUILD RUN build_app.sh
# Copy the whole app at the end so that rebuilding the image when changes are
# only made in the app code (as opposed to its dependencies) doesn't cause all
# the dependencies to be reinstalled.
ONBUILD COPY . ${PROJ_ROOT}/
COPY run_webpack.sh /usr/local/bin/
ONBUILD RUN run_webpack.sh
