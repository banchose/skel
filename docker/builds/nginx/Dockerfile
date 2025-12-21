FROM alpine:latest

RUN apk update && \
  apk add --no-cache nginx

COPY nginx.conf /etc/nginx/nginx.conf
COPY index.html /var/www/html/index.html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
