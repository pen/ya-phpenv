#!/bin/sh
set -e

PHPENV_ROOT="${1:-${PHPENV_ROOT:-$HOME/.phpenv}}"
if [ -e "$PHPENV_ROOT" ]; then
    echo "already exists: $PHPENV_ROOT"
    exit
fi

git clone --depth 1 "https://github.com/sstephenson/rbenv"            "$PHPENV_ROOT"
git clone --depth 1 "https://github.com/CHH/php-build"                "$PHPENV_ROOT/plugins/php-build"
git clone --depth 1 "https://github.com/ngyuki/phpenv-composer"       "$PHPENV_ROOT/plugins/phpenv-composer"
git clone --depth 1 "https://github.com/sergeyklay/phpenv-config-add" "$PHPENV_ROOT/plugins/phpenv-config-add"

rbenv_paths=`find "$PHPENV_ROOT" | awk '/\/rbenv[^\/]*$/ {print length(), $0}' | sort -nr | awk '{ print $2 }'`
for rbenv_path in $rbenv_paths; do
    phpenv_path="${rbenv_path%/*}"/`echo "${rbenv_path##*/}" | sed 's/rbenv/phpenv/'`
    [ -e "$phpenv_path" ] && continue

    mv "$rbenv_path" "$phpenv_path"
done

ln -sf ../libexec/phpenv "$PHPENV_ROOT/bin/phpenv"

sep=' '
if sed --version 2>&1 | grep -q GNU; then
    sep=''
fi

rbenv_files=`grep -lR -iF -e 'ruby' -e 'rbenv' "$PHPENV_ROOT" | grep -v -e '/\.git' -e '\.md$'`
for rbenv_file in $rbenv_files; do
    [ -L "$rbenv_file" ] && continue

    sed -i$sep'' -e 's/ruby/php/g; s/RUBY/PHP/g; s/Ruby/PHP/g; s/rbenv/phpenv/g; s/RBENV/PHPENV/g' "$rbenv_file"
done
