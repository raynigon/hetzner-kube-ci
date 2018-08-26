FROM buildpack-deps:stable-curl

ENV HETZNER_KUBE_REPOSITORY xetys/hetzner-kube
ENV PATH /app/:$PATH
WORKDIR /app

RUN echo ">>> Installing Tools..." && \
    apt-get update -qq && \
    apt-get install -qq -y --no-install-recommends jq > /dev/null && \
    apt-get clean -qq && \
    echo ">>> Using Repository: $HETZNER_KUBE_REPOSITORY" && \
    HETZNER_KUBE_VERSION=$(curl --silent "https://api.github.com/repos/$HETZNER_KUBE_REPOSITORY/releases/latest" | jq -r '.tag_name') && \
    echo ">>> Using Hetzner Kube Version: $HETZNER_KUBE_VERSION" && \
    curl --silent -L "https://github.com/$HETZNER_KUBE_REPOSITORY/releases/download/$HETZNER_KUBE_VERSION/hetzner-kube-linux-amd64" --output hetzner-kube-linux-amd64 && \
    chmod +x hetzner-kube-linux-amd64 && \
    ln -s /app/hetzner-kube-linux-amd64 /app/hetzner-kube && \
    printf ">>> Running Hetzner Kube Version: " && \
    /app/hetzner-kube version && \
    /app/hetzner-kube completion > /etc/bash_completion.d/hetzner-kube

CMD ["/app/hetzner-kube"]
