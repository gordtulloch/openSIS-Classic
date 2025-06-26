# Dockerfile for openSIS-Classic with Apache 2.2, MySQL 5.x, and PHP 5.2
FROM ubuntu:14.04

# Avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive

# Update package list and install basic packages
RUN apt-get update && apt-get install -y \
    software-properties-common \
    wget \
    curl \
    vim \
    supervisor

# Install Apache 2.2 (available in Ubuntu 14.04)
RUN apt-get install -y apache2

# Install PHP 5.5 (closest available to 5.2 in Ubuntu 14.04)
RUN apt-get install -y \
    php5 \
    php5-mysql \
    php5-gd \
    php5-curl \
    php5-mcrypt \
    php5-xsl \
    php5-json \
    libapache2-mod-php5

# Enable Apache modules
RUN a2enmod rewrite
RUN a2enmod php5

# Configure PHP
RUN sed -i 's/;date.timezone =/date.timezone = UTC/' /etc/php5/apache2/php.ini
RUN sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 50M/' /etc/php5/apache2/php.ini
RUN sed -i 's/post_max_size = 8M/post_max_size = 50M/' /etc/php5/apache2/php.ini
RUN sed -i 's/max_execution_time = 30/max_execution_time = 300/' /etc/php5/apache2/php.ini
RUN sed -i 's/memory_limit = 128M/memory_limit = 512M/' /etc/php5/apache2/php.ini

# Create Apache virtual host configuration
COPY docker/apache-opensis.conf /etc/apache2/sites-available/opensis.conf

# Disable default site and enable openSIS site
RUN a2dissite 000-default
RUN a2ensite opensis

# Create directory for openSIS
RUN mkdir -p /var/www/opensis

# Copy openSIS files
COPY . /var/www/opensis/

# Set proper permissions
RUN chown -R www-data:www-data /var/www/opensis
RUN chmod -R 755 /var/www/opensis

# Create supervisor configuration
COPY docker/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Expose port 80
EXPOSE 80

# Start supervisor
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
