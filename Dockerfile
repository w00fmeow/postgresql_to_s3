# Dockerfile

FROM alpine:3.7
RUN apk update && \
    apk add --no-cache python3 && \
    python3 -m ensurepip && \
    pip3 install --no-cache --upgrade pip setuptools && \
    pip3 install awscli && \
    aws --version && \
    apk add postgresql && \
    apk add --no-cache gnupg && \
    apk add curl &&\
    apk add bc &&\
    apk add --no-cache --upgrade bash

# Set work directory
RUN mkdir /src;
WORKDIR /home

# Copy scripts
COPY ./src /src

RUN chmod +x /src/db_backups.sh
RUN chmod +x /src/startup.sh

# run backup every day at 3:00 AM
RUN echo '0 3 * * *    /src/db_backups.sh' > /etc/crontabs/root

CMD crond -l 2 -f
