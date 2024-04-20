#! /bin/bash

# Downloads, configures and installs WP.
# Parameters:
# $1 Site title
# $2 Site path
# $3 DB name
# $4 Site port
function setup() {
	if ! wp --path=$2 core is-installed 2>/dev/null; then
		echo "$1 installation absent. Installing…"
		wp core download --path=$2 --force
		wp --path=$2 config create --force --dbname=$3 --dbuser=devbox_user --dbpass=password --dbhost=127.0.0.1:3306
		wp --path=$2 core install --url=${NGINX_WEB_SERVER_NAME}:$4 --title="$1" --admin_user=admin --admin_password=password --admin_email=info@example.com --skip-email
	else
		echo "$1 installation present."
	fi	
}

setup 'Gutenberg Dev' "${NGINX_DEV_PATH}" 'devbox_gutenberg_wp' "${NGINX_DEV_PORT}" 
setup 'Gutenberg Test' "${NGINX_TEST_PATH}" 'devbox_gutenberg_wp_test' "${NGINX_TEST_PORT}"

if [[ -n ${GUTENBERG_REPO-} ]]; then
	# Links gutenberg plugin in both sites.
	ln -s "${GUTENBERG_REPO}" "${NGINX_DEV_PATH}"/wp-content/plugins/
	ln -s "${GUTENBERG_REPO}" "${NGINX_TEST_PATH}"/wp-content/plugins/
	# Activates gutenberg plugin in both sites.
	wp --path="${NGINX_DEV_PATH}" plugin activate gutenberg
	wp --path="${NGINX_TEST_PATH}" plugin activate gutenberg

	# Links test plugins and themes in test site.
	mkdir -p "${NGINX_TEST_PATH}"/wp-content/mu-plugins
	ln -s "${GUTENBERG_REPO}"/packages/e2e-tests/mu-plugins/* "${NGINX_TEST_PATH}"/wp-content/mu-plugins/
	ls -s "${GUTENBERG_REPO}"/packages/e2e-tests/plugins/* "${NGINX_TEST_PATH}"/wp-content/plugins/
	ls -s "${GUTENBERG_REPO}"/test/gutenberg-test-themes/* "${NGINX_TEST_PATH}"/themes/
	# Installs other themes used in tests.
	wp --path="${NGINX_TEST_PATH}" theme install twentytwenty
	wp --path="${NGINX_TEST_PATH}" theme install twentytwentyone
	wp --path="${NGINX_TEST_PATH}" theme install twentytwentythree
	wp --path="${NGINX_TEST_PATH}" theme install twentytwentyfour
else
	echo Gutenberg and testing plugins/themes were not linked because GUTENBERG_REPO was not set.
fi
