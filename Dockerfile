FROM devopsedu/webapp

MAINTAINER abhijit D

COPY website /var/www/html

CMD apachectl -D FOREGROUND
