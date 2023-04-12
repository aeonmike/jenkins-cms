FROM ubuntu:20.04

# Install necessary dependencies
RUN apt-get update && apt-get install -y \
    nginx \
    curl \
    wget \
    php-fpm \
    php-mysql \
    php-curl \
    php-gd \
    php-intl \
    php-mbstring \
    php-soap \
    php-xml \
    php-xmlrpc \
    php-zip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Download and extract WordPress
ENV WORDPRESS_VERSION 5.8.1
RUN curl -o wordpress.tar.gz -SL https://wordpress.org/wordpress-${WORDPRESS_VERSION}.tar.gz \
    && tar -xzf wordpress.tar.gz -C /var/www/ \
    && rm wordpress.tar.gz \
    && chown -R www-data:www-data /var/www/wordpress

# Configure Nginx
COPY nginx.conf /etc/nginx/
RUN rm /etc/nginx/sites-enabled/default \
    && ln -s /etc/nginx/sites-available/wordpress.conf /etc/nginx/sites-enabled/ \
    && sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /etc/php/7.4/fpm/php.ini

# Copy the wp-config.php file
COPY wp-config.php /var/www/wordpress/

# Expose port 80 for HTTP access
EXPOSE 80

# Start Nginx and PHP-FPM
CMD ["sh", "-c", "service php7.4-fpm start && nginx -g 'daemon off;'"]
