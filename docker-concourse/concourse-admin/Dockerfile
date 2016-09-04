FROM concourse-base

EXPOSE 8080
EXPOSE 2222

ENV CONCOURSE_DB concourse
ENV CONCOURSE_DB_USER concourse_admin
ENV CONCOURSE_PEER_URL 0.0.0.0
ENV CONCOURSE_URL http://dev.ci

ADD concourse-admin.sh .

RUN chmod 555 concourse-admin.sh

ENTRYPOINT ["./concourse-admin.sh"]
