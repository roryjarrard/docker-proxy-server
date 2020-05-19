FROM jwilder/nginx-proxy

RUN apt-get update \
    && apt-get install -y vim less

COPY ./nginx.conf /etc/nginx/nginx.conf
COPY ./certs /etc/nginx/certs