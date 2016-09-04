FROM postgres:9.5

WORKDIR /app

COPY bootstrap.sh .
COPY wait-for-it.sh /usr/local/bin/wait-for-it

RUN chmod 555 bootstrap.sh /usr/local/bin/wait-for-it

CMD ["./bootstrap.sh"]
