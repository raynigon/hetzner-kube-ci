FROM alpine:latest

ENV HETZNER_KUBE_REPOSITORY xetys/hetzner-kube

WORKDIR /app

RUN echo "Installing Curl" && \
    apk --no-cache add curl > /dev/null && \
    echo "Using Repository: $HETZNER_KUBE_REPOSITORY" && \
    HETZNER_KUBE_VERSION=$(curl --silent "https://api.github.com/repos/$HETZNER_KUBE_REPOSITORY/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/') && \
    echo "Using Hetzner Kube Version: $HETZNER_KUBE_VERSION" && \
    curl --silent -L "https://github.com/$HETZNER_KUBE_REPOSITORY/releases/download/$HETZNER_KUBE_VERSION/hetzner-kube-amd64" --output hetzner-kube-linux-amd64 && \
    chmod +x hetzner-kube-amd64 && \
    export PATH=$PATH:/app/ && \
    hetzner-kube-amd64 --version

CMD ["/app/hetzner-kube-amd64"]
