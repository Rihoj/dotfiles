# Custom functions

phpunit-docker() {
    docker compose exec app vendor/bin/phpunit "$@" 2>&1 | sed "s|/var/www/html/|$(pwd)/|g"
}
