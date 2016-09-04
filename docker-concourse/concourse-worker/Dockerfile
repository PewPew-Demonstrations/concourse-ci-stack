FROM concourse-base

ENV CONCOURSE_TSA_PORT 2222

ADD concourse-worker.sh .
RUN chmod 555 concourse-worker.sh

CMD ["./concourse-worker.sh"]
