FROM heroku/cedar:14

RUN useradd -d /app -m app
WORKDIR /app

ENV HOME /app
ENV PORT 3000
ENV GOROOT /usr/local/go
ENV GOPATH /app/go
ENV PATH $GOPATH/bin:$GOROOT/bin:$PATH

COPY linux-amd64/bin/jq /usr/local/bin/jq
COPY docker/build /tmp/gobuild
COPY docker/version /tmp/goversion

USER root
RUN mkdir -p /app/go/src && \
    chown -R app /app

USER app
RUN mkdir -p /app/.profile.d && \
    echo 'export GOPATH=/app/go' >> /app/.profile.d/go.sh && \
    echo 'export PATH=$GOPATH/bin:$PATH' >> /app/.profile.d/go.sh

ONBUILD USER root
ONBUILD COPY . /app/src
ONBUILD RUN chown -R app /app/src
ONBUILD RUN /tmp/goversion
ONBUILD RUN /tmp/gobuild
ONBUILD RUN chown -R app /app
ONBUILD USER app

ONBUILD EXPOSE 3000
