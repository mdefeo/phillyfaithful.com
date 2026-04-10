FROM wordpress:6.5-php8.2-fpm

# Install WP-CLI and additional tools needed for WooCommerce
RUN apt-get update && apt-get install -y \
    curl \
    libzip-dev \
    zip \
    unzip \
    less \
    default-mysql-client \
    && docker-php-ext-install zip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install WP-CLI
RUN curl -sS -o /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x /usr/local/bin/wp

# Copy setup scripts into the image
COPY scripts/ /scripts/
RUN chmod +x /scripts/*.sh
