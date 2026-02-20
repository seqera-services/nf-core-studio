# Bisect test 4: minimal documented pattern
ARG CONNECT_CLIENT_VERSION=0.9
FROM public.cr.seqera.io/platform/connect-client:${CONNECT_CLIENT_VERSION} AS connect

FROM ubuntu:22.04

ARG CONNECT_CLIENT_VERSION
LABEL io.seqera.connect.version="${CONNECT_CLIENT_VERSION}"

COPY --from=connect /usr/bin/connect-client /usr/bin/connect-client
RUN /usr/bin/connect-client --install

ENTRYPOINT ["/usr/bin/connect-client", "--entrypoint"]
CMD ["/usr/bin/bash", "-c", "echo hello && sleep infinity"]
