# Minimal working example from docs with python http server
ARG CONNECT_CLIENT_VERSION="0.9"
FROM public.cr.seqera.io/platform/connect-client:${CONNECT_CLIENT_VERSION} AS connect

FROM ubuntu:20.04
RUN apt-get update --yes && apt-get install --yes --no-install-recommends python3

ARG CONNECT_CLIENT_VERSION
LABEL io.seqera.connect.version="${CONNECT_CLIENT_VERSION}"
COPY --from=connect /usr/bin/connect-client /usr/bin/connect-client
RUN /usr/bin/connect-client --install
ENTRYPOINT ["/usr/bin/connect-client", "--entrypoint"]

CMD ["/usr/bin/bash", "-c", "python3 -m http.server $CONNECT_TOOL_PORT"]
