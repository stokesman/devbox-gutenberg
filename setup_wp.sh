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

mkdir -p ${NGINX_DEV_ROOT}
mkdir -p ${NGINX_TEST_ROOT}

setup 'Gutenberg Dev' "${NGINX_DEV_ROOT}" 'devbox_gutenberg_wp' "${NGINX_DEV_PORT}" 
setup 'Gutenberg Test' "${NGINX_TEST_ROOT}" 'devbox_gutenberg_wp_test' "${NGINX_TEST_PORT}"

if [[ -n ${GUTENBERG_REPO-} ]]; then
	# Links gutenberg plugin in both sites. Removing them first avoids ln
	# failing because they already exist. Using -f with ln would overwrite but
	# would nest because the link is to a directory. -fn would work but not on
	# all systems. see: https://unix.stackexchange.com/a/207296
	rm -f ${NGINX_DEV_ROOT}/wp-content/plugins/gutenberg
	rm -f ${NGINX_TEST_ROOT}/wp-content/plugins/gutenberg
	ln -s ${GUTENBERG_REPO} ${NGINX_DEV_ROOT}/wp-content/plugins/
	ln -s ${GUTENBERG_REPO} ${NGINX_TEST_ROOT}/wp-content/plugins/
	# Activates gutenberg plugin in both sites.
	if ! wp --path="${NGINX_DEV_ROOT}" plugin is-active gutenberg; then
		wp --path="${NGINX_DEV_ROOT}" plugin activate gutenberg; fi
	if ! wp --path="${NGINX_TEST_ROOT}" plugin is-active gutenberg; then
		wp --path="${NGINX_TEST_ROOT}" plugin activate gutenberg; fi

	# Test site only.
	# removes mu-plugins, recreates and links mu-plugins.
	rm -rf "${NGINX_TEST_ROOT}"/wp-content/mu-plugins
	mkdir -p "${NGINX_TEST_ROOT}"/wp-content/mu-plugins
	ln -s "${GUTENBERG_REPO}"/packages/e2e-tests/mu-plugins/* "${NGINX_TEST_ROOT}"/wp-content/mu-plugins/
	# removes all symlinked plugins excluding 'gutenberg' and links them again.
	find $NGINX_TEST_ROOT/wp-content/plugins -type l -not -name gutenberg | xargs rm
	ln -s "${GUTENBERG_REPO}"/packages/e2e-tests/plugins/* "${NGINX_TEST_ROOT}"/wp-content/plugins/
	# removes all symlinked themes and links them again.
	find $NGINX_TEST_ROOT/wp-content/themes -type l | xargs rm
	ln -s "${GUTENBERG_REPO}"/test/gutenberg-test-themes/* "${NGINX_TEST_ROOT}"/wp-content/themes/
	# Installs other themes used in tests.
	if wp --path"${NGINX_TEST_ROOT}" theme is-installed twentytwenty 2>/dev/null; then
		wp --path="${NGINX_TEST_ROOT}" theme install twentytwenty; fi
	if wp --path"${NGINX_TEST_ROOT}" theme is-installed twentytwentyone 2>/dev/null; then
		wp --path="${NGINX_TEST_ROOT}" theme install twentytwentyone; fi
	if wp --path"${NGINX_TEST_ROOT}" theme is-installed twentytwentythree 2>/dev/null; then
		wp --path="${NGINX_TEST_ROOT}" theme install twentytwentythree; fi
	if wp --path"${NGINX_TEST_ROOT}" theme is-installed twentytwentyfour 2>/dev/null; then
		wp --path="${NGINX_TEST_ROOT}" theme install twentytwentyfour; fi
else
	echo Gutenberg and testing plugins/themes were not linked because GUTENBERG_REPO was not set.
fi
