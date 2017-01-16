FROM hseeberger/scala-sbt

# Install activator
RUN apk add --update bash curl openssl ca-certificates && \
  curl -L -o /tmp/activator.zip \
    https://downloads.typesafe.com/typesafe-activator/1.3.12/typesafe-activator-1.3.12-minimal.zip && \
  mkdir -p /opt/activator && \
  unzip /tmp/activator.zip -d /opt/activator && \
  rm /tmp/activator.zip && \
  chmod +x /opt/activator/activator-1.3.12-minimal/activator && \
  ln -s /opt/activator/activator-1.3.12-minimal/activator /usr/bin/activator && \
  rm -rf /tmp/* /var/cache/apk/*

# Prebuild with activator
COPY . /tmp/build/

# activator sometimes failed because of network. retry 3 times.
RUN cd /tmp/build && \
  (activator compile || activator compile || activator compile) && \
  (activator test:compile || activator test:compile || activator test:compile) && \
  rm -rf /tmp/build
