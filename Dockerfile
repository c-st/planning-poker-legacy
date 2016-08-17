FROM hseeberger/scala-sbt
MAINTAINER Christian Stangier <mail@christian-stangier.com>
EXPOSE 8080

# setup node

RUN \
 curl -sL https://deb.nodesource.com/setup_6.x | bash - && \
 apt-get install -y nodejs

# build frontend

WORKDIR /usr/src/app/frontend
ADD frontend/package.json /usr/src/app/frontend
RUN npm --quiet install

ADD ./frontend /usr/src/app/frontend
RUN npm run build
COPY /usr/src/app/frontend/dist/* dist/

# run server

WORKDIR /usr/src/app
ADD ./backend /usr/src/app
ENTRYPOINT ["sbt" "run"]
# serve: /usr/src/app/dist/*
