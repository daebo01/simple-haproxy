FROM haproxy:3.1.3-alpine

USER root

RUN apk add --no-cache bash

WORKDIR /app

COPY base.cfg .
COPY start.sh .

CMD [ "/bin/bash", "/app/start.sh"]