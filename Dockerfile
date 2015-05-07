FROM heroku/cedar:14

RUN useradd -d /app -m app
WORKDIR /app

ENV HOME /app
ENV PORT 3000

ENV GOVER="1.4.2"
ENV GOROOT=/usr/local/go
ENV GOPATH=/app

ENV PATH=$GOPATH/bin:$GOROOT/bin:$PATH

RUN mkdir -p /app/heroku
RUN mkdir -p /usr/local
RUN wget https://storage.googleapis.com/golang/go$GOVER.linux-amd64.tar.gz -q -O - | tar -zxf - -C /usr/local
RUN go get github.com/tools/godep/... && rm -rf /app/src/github.com/tools && rm -rf /app/src/golang.org

COPY linux-amd64/bin/jq /usr/local/bin/jq
COPY docker/build /app/heroku/go/.build

USER root
RUN chown -R app /app
RUN chown -R root /app/heroku

USER app

ONBUILD COPY . /app/.gt
ONBUILD USER root
ONBUILD RUN chown -R app /app/.gt
ONBUILD USER app
ONBUILD RUN /app/heroku/go/.build

ONBUILD EXPOSE 3000
