# Configuramos Nginx para que escuche en el 8080 en lugar del 80
RUN sed -i 's/listen       80;/listen       8080;/g' /etc/nginx/conf.d/default.conf

COPY index.html /usr/share/nginx/html/index.html

# Exponemos el 8080 que es el que busca Cloud Run
EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]
