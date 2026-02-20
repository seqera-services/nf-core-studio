# Custom Seqera Studio image for nf-core pipeline development
# Following the documented custom container pattern:
# https://docs.seqera.io/platform-cloud/studios/custom-envs#minimal-dockerfile
#
# Build:
#   docker build --platform linux/amd64 -t ghcr.io/seqera-services/nf-core-studio:latest .

# ---------------------------------------------------------------
# Stage 1: Get connect-client binary
# ---------------------------------------------------------------
ARG CONNECT_CLIENT_VERSION=0.9
FROM public.cr.seqera.io/platform/connect-client:${CONNECT_CLIENT_VERSION} AS connect

# ---------------------------------------------------------------
# Stage 2: Build the actual image
# ---------------------------------------------------------------
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TERM=xterm

# ---------------------------------------------------------------
# Connect-client setup (required for Studios)
# ---------------------------------------------------------------
ARG CONNECT_CLIENT_VERSION
LABEL io.seqera.connect.version="${CONNECT_CLIENT_VERSION}"
COPY --from=connect /usr/bin/connect-client /usr/bin/connect-client
RUN /usr/bin/connect-client --install

# ---------------------------------------------------------------
# Base dependencies
# ---------------------------------------------------------------
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        bash \
        ca-certificates \
        curl \
        git \
        gnupg \
        jq \
        wget && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# ---------------------------------------------------------------
# Docker CLI (for Docker-outside-of-Docker)
# ---------------------------------------------------------------
RUN install -m 0755 -d /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
    chmod a+r /etc/apt/keyrings/docker.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" > /etc/apt/sources.list.d/docker.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends docker-ce-cli && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# ---------------------------------------------------------------
# Java 17 (required for Nextflow and nf-test)
# ---------------------------------------------------------------
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        openjdk-17-jre-headless && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# ---------------------------------------------------------------
# Nextflow
# ---------------------------------------------------------------
RUN curl -fsSL https://get.nextflow.io | bash && \
    mv nextflow /usr/local/bin/nextflow && \
    chmod +x /usr/local/bin/nextflow

# ---------------------------------------------------------------
# nf-test
# ---------------------------------------------------------------
ARG NFTEST_VERSION=0.9.3
RUN curl -fsSL -o /tmp/nf-test.tar.gz \
        https://github.com/askimed/nf-test/releases/download/v${NFTEST_VERSION}/nf-test-${NFTEST_VERSION}.tar.gz && \
    tar -xzf /tmp/nf-test.tar.gz -C /tmp && \
    mv /tmp/nf-test /usr/local/bin/nf-test && \
    mv /tmp/nf-test.jar /usr/local/bin/nf-test.jar && \
    chmod +x /usr/local/bin/nf-test && \
    rm -f /tmp/nf-test.tar.gz

# ---------------------------------------------------------------
# nf-core tools
# ---------------------------------------------------------------
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        python3 \
        python3-pip && \
    pip3 install --no-cache-dir --break-system-packages nf-core && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# ---------------------------------------------------------------
# VS Code Server (code-server)
# ---------------------------------------------------------------
RUN curl -fsSL https://code-server.dev/install.sh | sh

# ---------------------------------------------------------------
# Diagnostic script
# ---------------------------------------------------------------
COPY check-env.sh /usr/local/bin/check-env.sh
RUN chmod +x /usr/local/bin/check-env.sh

# ---------------------------------------------------------------
# Studios entrypoint
# ---------------------------------------------------------------
ENTRYPOINT ["/usr/bin/connect-client", "--entrypoint"]
CMD ["/usr/bin/bash", "-c", "code-server --bind-addr 0.0.0.0:${CONNECT_TOOL_PORT} --auth none"]
