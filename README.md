# Docker Proxy Server

This is intended to proxy requests for local microservices. 

## Creation

Steps to create the local proxy service

1. Create a certs directory
    * mkdir -p certs
    * touch certs/.gitignore

        ```
        *
        !.gitignore
        ```
        We will be ignoring our certifications as they are local only. This file says to ignore everything in this folder except for the `.gitignore` file itself

2. Create Dockerfile and docker-compose.yml

    ## Dockerfile 
    Copy all our certs into the expected directory on the running container. Also, install a couple of useful helpers. I add these to almost every container because you'll want them eventually!

    ```
    FROM jwilder/nginx-proxy

    RUN apt-get update \
        && apt-get install -y vim less

    COPY ./certs /etc/nginx/certs
    ```

    ## docker-compose.yml
    This will orchestrate your container creation. You can name your container anything you would like. You don't need the last environment variable if you aren't hosting on Windows.

    ```
    version: '3'
    networks:
    web:
        external: true

    services:
        nginx-proxy:
        build:
            context: .
            dockerfile: ./Dockerfile
        container_name: local-proxy
        networks:
            - web
        ports:
            - 80:80
            - 443:443
        volumes:
            - /var/run/docker.sock:/tmp/docker.sock:ro
            - ./certs/:/etc/nginx/certs
        environment:
            - COMPOSE_CONVERT_WINDOWS_PATHS=1
    ```

3. If it doesn't exist, create the `web` network from the compose file. This is bridge network intended on running on your local Docker instance. 

    `docker network create -d bridge web`

4. Fire up your container

    `docker-compose up -d --build`

5. Once running, copy the nginx config file out of the running container. Here I'm using my container name of `local-proxy` as per the compose file

    `docker cp local-proxy:/etc/nginx/nginx.conf nginx.conf`

6. Now kill the running container

    `docker-compose down`

7. Make any modifications to your conf file if desired. I like longer wait times on requests because I'm often debugging and don't want the gateway timeouts

    ```
    keepalive_timeout  65;
    proxy_connect_timeout 600;
    proxy_send_timeout 600;
    proxy_read_timeout 600;
    send_timeout 600;
    ```

8. Now modify your Docker file to use this modified copy when creating your container.

    ```
    FROM jwilder/nginx-proxy

    COPY nginx.conf:/etc/nginx/nginx.conf   <-- add this line

    RUN apt-get update \
        && apt-get install -y vim less

    COPY ./certs /etc/nginx/certs
    ```