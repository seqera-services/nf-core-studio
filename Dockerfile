# Custom Seqera Studio image for nf-core pipeline development
# Bisect test 2: Without USER root
FROM public.cr.seqera.io/platform/data-studio-vscode:1.101.2-0.9
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
