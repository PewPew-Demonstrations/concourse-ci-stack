FROM ubuntu:16.04

COPY wait-for-it.sh /usr/local/bin/wait-for-it
COPY dumb-init_1.1.1_amd64 /usr/local/bin/dumb-init

ADD https://github.com/concourse/concourse/releases/download/v1.6.0/concourse_linux_amd64 /usr/local/bin/concourse

WORKDIR /app

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y iptables iproute2 ca-certificates openssh-client && \
    apt-get clean && apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    ssh-keygen -t rsa -f host_key -N ''  && \
    ssh-keygen -t rsa -f worker_key -N '' && \
    ssh-keygen -t rsa -f session_signing_key -N '' && \
    cp worker_key.pub authorized_worker_keys && \
    chmod 555 /usr/local/bin/concourse /usr/local/bin/wait-for-it /usr/local/bin/dumb-init

VOLUME ["/opt/concourse/"]

CMD ["concourse"]
