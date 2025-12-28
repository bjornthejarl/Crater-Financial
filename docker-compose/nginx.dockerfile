# Nginx Dockerfile - copies static assets from the app
FROM nginx:1.17-alpine

# Copy nginx configuration
COPY docker-compose/nginx/nginx.conf /etc/nginx/conf.d/default.conf

# Copy entire application for serving static files
COPY . /var/www

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
