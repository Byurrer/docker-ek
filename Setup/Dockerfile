ARG ELASTIC_VERSION

FROM elasticsearch:${ELASTIC_VERSION}

COPY setup.sh /setup.sh
COPY helpers.sh /helpers.sh

CMD /bin/bash -c "/setup.sh"
