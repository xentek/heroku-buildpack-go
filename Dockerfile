FROM heroku/cedar:14

USER root
RUN useradd -d /app -m app
WORKDIR /app

ENV HOME /app
ENV PORT 3000
ENV GOPATH /app/user
ENV PATH $GOPATH/bin:$GOROOT/bin:$PATH

COPY linux-amd64/bin/ /usr/local/bin/

RUN mkdir -p /app/user && \
    chown -R app /app

RUN mkdir -p /app/.buildpack/bin /app/.buildpack/vendor /app/.cache /app/.env
COPY bin/ /app/.buildpack/bin/
COPY vendor/ /app/.buildpack/vendor/

USER app
RUN mkdir -p /app/.profile.d && \
    echo 'export GOPATH=/app/user' >> /app/.profile.d/go.sh && \
    echo 'export PATH=$GOPATH/bin:$PATH' >> /app/.profile.d/go.sh

ONBUILD USER root
ONBUILD COPY . /app/user
ONBUILD RUN rm -rf /app/user/.git
ONBUILD RUN /app/.buildpack/bin/compile /app/user /app/.cache /app/.env
ONBUILD RUN chown -R app /app/user
ONBUILD USER app

ONBUILD EXPOSE 3000
