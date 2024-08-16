From ubuntu
RUN apt update
RUN apt-get install apache2 -y
ENTRYPOINT apachectl -D FOREGROUND
ADD . /var/www/html
