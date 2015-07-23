FROM heroku/cedar:14

USER root
RUN useradd -d /app -m app
WORKDIR /app

ENV HOME /app
ENV PORT 3000
ENV GOPATH /app/user
ENV PATH $GOPATH/bin:$PATH

COPY linux-amd64/bin/ /usr/local/bin/

RUN mkdir -p /app/.buildpack/bin /app/.buildpack/vendor /app/.cache /app/.env /app/user/.docker /app/.profile.d && \
    chown -R app /app

RUN echo 'for f in $(ls $HOME/.profile.d); do' >> $HOME/.bashrc && \
    echo '  . "$HOME/.profile.d/$f"' >> $HOME/.bashrc && \
    echo 'done' >> $HOME/.bashrc

COPY bin/ /app/.buildpack/bin/
COPY vendor/ /app/.buildpack/vendor/

ONBUILD USER root
ONBUILD COPY . /app/user/.docker
ONBUILD RUN /app/.buildpack/bin/compile /app/user /app/.cache /app/.env
ONBUILD RUN chown -R app /app/user /app/.profile.d
ONBUILD USER app
