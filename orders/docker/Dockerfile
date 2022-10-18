# Auto Generated Dockerfile
FROM ballerina/jre11:v1

LABEL maintainer="dev@ballerina.io"

RUN addgroup troupe \
    && adduser -S -s /bin/bash -g 'ballerina' -G troupe -D ballerina \
    && apk add --update --no-cache bash \
    && chown -R ballerina:troupe /usr/bin/java \
    && rm -rf /var/cache/apk/*

WORKDIR /home/ballerina

# COPY main.jar /home/ballerina
COPY orders.jar /home/ballerina

EXPOSE  9091
USER ballerina

# CMD java -jar main.jar
CMD java -jar orders.jar
