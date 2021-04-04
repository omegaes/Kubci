FROM alpine
LABEL maintainer="abdul@babil.dev"

RUN apk --update add git less openssh py-pip bash && \
    rm -rf /var/lib/apt/lists/* && \
    rm /var/cache/apk/*

COPY script.sh /usr/local/bin/kubci
RUN  wget -O /usr/local/bin/yq "https://github.com/mikefarah/yq/releases/download/2.4.0/yq_linux_amd64"

RUN chmod +x /usr/local/bin/yq
RUN chmod +x /usr/local/bin/kubci

ENTRYPOINT ["kubci"]

