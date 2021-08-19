FROM registry.artifakt.io/vuejs:3

ARG CODE_ROOT=.

COPY --chown=www-data:www-data $CODE_ROOT/package* /var/www/html/

WORKDIR /var/www/html

# dependency management
RUN if [ -f package-lock.json ]; then npm install; fi

COPY --chown=www-data:www-data $CODE_ROOT /var/www/html/

# copy the artifakt folder on root
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
# trick to support non default CODE_ROOT values, makes .artifakt mandatory for now 
COPY --chown=www-data:www-data ./.artifakt/* /var/www/html/.artifakt/
RUN if [ -d .artifakt ]; then cp -rp /var/www/html/.artifakt /.artifakt/; fi

# run custom scripts build.sh
# hadolint ignore=SC1091
RUN --mount=source=artifakt-custom-build-args,target=/tmp/build-args \
  if [ -f /tmp/build-args ]; then source /tmp/build-args; fi && \
  if [ -f /.artifakt/build.sh ]; then /.artifakt/build.sh; fi
