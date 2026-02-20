# Custom Seqera Studio image for nf-core pipeline development
# Extends the VS Code Studio base with Docker CLI, Nextflow, nf-test, and nf-core tools
#
# Build:
#   docker build --platform linux/amd64 -t nfcore-studio .
#
# Use as "Prebuilt container image" in Seqera Studios on an EC2 compute environment.
# The EC2 host's Docker socket must be accessible for containerized Nextflow processes.

FROM public.cr.seqera.io/platform/data-studio-vscode:1.101.2-0.9

USER root

ENV DEBIAN_FRONTEND=noninteractive

# ---------------------------------------------------------------
# Install Docker CLI (for Docker-outside-of-Docker)
# Only the CLI is needed - the daemon runs on the EC2 host
# ---------------------------------------------------------------
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        gnupg && \
    install -m 0755 -d /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
    chmod a+r /etc/apt/keyrings/docker.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" > /etc/apt/sources.list.d/docker.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends docker-ce-cli && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# ---------------------------------------------------------------
# Install Java (required for Nextflow and nf-test)
# ---------------------------------------------------------------
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        openjdk-17-jre-headless && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# ---------------------------------------------------------------
# Install Nextflow
# ---------------------------------------------------------------
RUN curl -fsSL https://get.nextflow.io | bash && \
    mv nextflow /usr/local/bin/nextflow && \
    chmod +x /usr/local/bin/nextflow

# ---------------------------------------------------------------
# Install nf-test
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
# Install nf-core tools
# ---------------------------------------------------------------
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        python3 \
        python3-pip && \
    pip3 install --no-cache-dir --break-system-packages nf-core && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# ---------------------------------------------------------------
# Diagnostic script (run manually: bash /usr/local/bin/check-env.sh)
# ---------------------------------------------------------------
COPY check-env.sh /usr/local/bin/check-env.sh
RUN chmod +x /usr/local/bin/check-env.sh
