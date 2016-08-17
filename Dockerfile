FROM hseeberger/scala-sbt
MAINTAINER Christian Stangier <mail@christian-stangier.com>
EXPOSE 8080

# setup node

RUN \
 curl -sL https://deb.nodesource.com/setup_6.x | bash - && \
 apt-get install -y nodejs

# build frontend

WORKDIR /usr/src/app/frontend

COPY frontend/package.json /usr/src/app/frontend
RUN npm --quiet install

COPY ./frontend /usr/src/app/frontend
RUN npm run build

# run server

WORKDIR /usr/src/app
COPY ./backend /usr/src/app
COPY frontend/dist/ src/main/resources/dist/
RUN sbt compile

ENTRYPOINT ["sbt"]
CMD ["--version"]

# serve: /usr/src/app/frontend/dist/*
