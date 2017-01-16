FROM anapsix/alpine-java:jdk8

ENV SCALA_VERSION 2.11.8
ENV SCALA_HOME /usr/share/scala

ENV SBT_VERSION 0.13.13
ENV SBT_HOME /usr/local/sbt-launcher-packaging-${SBT_VERSION}
ENV PATH ${PATH}:${SBT_HOME}/bin
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
  
RUN sbt sbtVersion

# Install activator
RUN apk add --update bash curl openssl ca-certificates && \
  curl -L -o /tmp/activator.zip \
    https://downloads.typesafe.com/typesafe-activator/$ACTIVATOR_VERSION/typesafe-activator-$ACTIVATOR_VERSION.zip && \
  mkdir -p /opt/activator && \
  unzip /tmp/activator.zip -d /opt/activator && \
  rm /tmp/activator.zip && \
  chmod +x /opt/activator/activator-dist-$ACTIVATOR_VERSION/bin/activator && \
  ln -s /opt/activator/activator-dist-$ACTIVATOR_VERSION/bin/activator /usr/bin/activator && \
  rm -rf /tmp/* /var/cache/apk/*
  
# Define working directory
WORKDIR /root

EXPOSE 9000 9999
