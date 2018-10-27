FROM redis:3.2.12-alpine

MAINTAINER Vitaly Aminev <v@makeomatic.ca>

RUN \
  apk --no-cache add \
    ruby \
    supervisor \
    tcl \
  	gettext \
    git

RUN gem install --no-rdoc --no-ri redis \
  && mkdir /redis-conf \
  && mkdir /redis-data \
  && wget -O /redis-trib.rb https://raw.githubusercontent.com/antirez/redis/3.2.12/src/redis-trib.rb

COPY ./docker-data/redis-cluster.tmpl /redis-conf/redis-cluster.tmpl
COPY ./docker-data/redis.tmpl /redis-conf/redis.tmpl

# Add supervisord configuration
COPY ./docker-data/supervisord.conf /etc/supervisor/supervisord.conf

# Add startup script
COPY ./docker-data/docker-entrypoint.sh /docker-entrypoint.sh

EXPOSE 7000 7001 7002 7003 7004 7005

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["redis-cluster"]
