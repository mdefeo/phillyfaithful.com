#!/bin/bash
# Install WordPress core and WooCommerce via WP-CLI.
# Run this once after the containers are started:
#   docker compose exec wordpress bash /scripts/install-wordpress.sh
set -e

WP="wp --allow-root --path=/var/www/html"

echo "==> Waiting for database connection..."
until $WP db check &>/dev/null; do
    echo "    Database not ready, retrying in 5 seconds..."
    sleep 5
done

echo "==> Checking WordPress installation..."
if ! $WP core is-installed 2>/dev/null; then
    echo "==> Installing WordPress..."
    $WP core install \
        --url="${WORDPRESS_SITE_URL:-http://localhost}" \
        --title="${WORDPRESS_SITE_TITLE:-Philly Faithful}" \
        --admin_user="${WORDPRESS_ADMIN_USER:-admin}" \
        --admin_password="${WORDPRESS_ADMIN_PASSWORD:-changeme}" \
        --admin_email="${WORDPRESS_ADMIN_EMAIL:-admin@example.com}" \
        --skip-email
    echo "    WordPress installed."
else
    echo "    WordPress is already installed."
fi

echo "==> Checking WooCommerce plugin..."
if ! $WP plugin is-active woocommerce 2>/dev/null; then
    echo "==> Installing WooCommerce..."
    $WP plugin install woocommerce --activate
    echo "    WooCommerce installed and activated."
else
    echo "    WooCommerce is already active."
fi

echo "==> Configuring WooCommerce store settings..."
$WP option update woocommerce_store_address "${WOOCOMMERCE_STORE_ADDRESS:-}"
$WP option update woocommerce_store_city "${WOOCOMMERCE_STORE_CITY:-Philadelphia}"
$WP option update woocommerce_default_country "${WOOCOMMERCE_DEFAULT_COUNTRY:-US:PA}"
$WP option update woocommerce_store_postcode "${WOOCOMMERCE_STORE_POSTCODE:-19103}"
$WP option update woocommerce_currency "${WOOCOMMERCE_CURRENCY:-USD}"

echo "==> Flushing rewrite rules..."
$WP rewrite structure '/%postname%/' --hard

echo "==> Done! WordPress with WooCommerce is ready."
