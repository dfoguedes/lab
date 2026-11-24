FROM ubuntu:24.04

RUN apt-get update && apt-get install -y apache2

RUN sed -i 's/Listen 80/Listen 8088/' /etc/apache2/ports.conf

EXPOSE  8088

CMD ["apachectl","-D","FOREGROUND"] # Keep the Apache server running in the foreground
# Without a CMD the container shuts down immediately after starting