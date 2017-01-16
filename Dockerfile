FROM anapsix/alpine-java:jdk8

MAINTAINER cignoir <cignoir@gmail.com>

ENV SCALA_VERSION 2.11.8
ENV SCALA_HOME /usr/share/scala

ENV SBT_VERSION 0.13.13
ENV SBT_HOME /usr/local/sbt
ENV PATH ${PATH}:${SBT_HOME}/bin

ENV PLAY_VERSION 2.5.10
ENV ACTIVATOR_VERSION 1.3.12

RUN apk add --no-cache --virtual=.build-dependencies wget ca-certificates && \
  apk add --no-cache bash curl unzip

# Install Scala
RUN cd "/tmp" && wget "https://downloads.typesafe.com/scala/${SCALA_VERSION}/scala-${SCALA_VERSION}.tgz" && \
  tar xzf "scala-${SCALA_VERSION}.tgz" && \
  mkdir "${SCALA_HOME}" && \
  rm "/tmp/scala-${SCALA_VERSION}/bin/"*.bat && \
  mv "/tmp/scala-${SCALA_VERSION}/bin" "/tmp/scala-${SCALA_VERSION}/lib" "${SCALA_HOME}" && \
  ln -s "${SCALA_HOME}/bin/"* "/usr/bin/" && \
  rm -rf "/tmp/"*

# Install sbt
RUN apk add --no-cache curl bash && \
  curl -sL "http://dl.bintray.com/sbt/native-packages/sbt/$SBT_VERSION/sbt-$SBT_VERSION.tgz" | gunzip | tar -x -C /usr/local && \
  rm -rf /var/cache/apk/* && \
  echo -ne "- with sbt $SBT_VERSION\n" >> /root/.built

# Install activator
RUN apk add --update bash curl openssl ca-certificates && \
  curl -L -o /tmp/activator.zip \
    https://downloads.typesafe.com/typesafe-activator/$ACTIVATOR_VERSION/typesafe-activator-$ACTIVATOR_VERSION-minimal.zip && \
  mkdir -p /opt/activator && \
  unzip /tmp/activator.zip -d /opt/activator && \
  rm /tmp/activator.zip && \
  chmod +x /opt/activator/activator-$ACTIVATOR_VERSION-minimal/bin/activator && \
  ln -s /opt/activator/activator-$ACTIVATOR_VERSION-minimal/bin/activator /usr/bin/activator && \
  rm -rf /tmp/* /var/cache/apk/*

# Prebuild with activator
COPY . /tmp/build/

# activator sometimes failed because of network. retry 3 times.
RUN cd /tmp/build && \
  (activator compile || activator compile || activator compile) && \
  (activator test:compile || activator test:compile || activator test:compile) && \
  rm -rf /tmp/build



# Install Play Framework
#RUN wget "http://downloads.typesafe.com/play/$PLAY_VERSION/play-$PLAY_VERSION.zip" && \
#  unzip play-$PLAY_VERSION.zip -d /usr/local && \
#  ln -s /usr/local/play-$PLAY_VERSION/play /usr/local/bin/play && \
#  rm -f *.zip

# Clean up
#RUN apk del .build-dependencies curl unzip

EXPOSE 9000 9999
