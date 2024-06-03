FROM php:8.1-fpm-alpine

ARG SHOPIFY_API_KEY
ENV SHOPIFY_API_KEY=$SHOPIFY_API_KEY

RUN apk update && apk add --update nodejs npm \
    composer php-pdo_sqlite php-pdo_mysql php-pdo_pgsql php-simplexml php-fileinfo php-dom php-tokenizer php-xml php-xmlwriter php-session \
    openrc bash nginx

RUN docker-php-ext-install pdo

COPY --chown=www-data:www-data web /app
WORKDIR /app

# Overwrite default nginx config
COPY web/nginx.conf /etc/nginx/nginx.conf

# Use the default production configuration
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"
# Clear npm cache and install dependencies
RUN npm cache clean --force \
    && npm install --loglevel verbose \
    && echo "npm install succeeded"

# Run npm build step
RUN npm run dev

# Expose necessary ports (if applicable, adjust according to your application)
EXPOSE 3000

# Define entrypoint script
ENTRYPOINT [ "/app/entrypoint.sh" ]
