#!/bin/sh
set -e

if [ -z "${PHPENV_GLOBAL_PACKAGES+defined}" ]; then
    PHPENV_GLOBAL_PACKAGES='
        laravel/installer
    '
fi

if [ -z "${PHPENV_PECLS+defined}" ]; then
    PHPENV_PECLS='
        xdebug
    '
fi

export PHPENV_VERSION="${1:-$PHPENV_VERSION}"
if [ -z "$PHPENV_VERSION" ]; then
    echo "usage: $0 version"
    exit
fi
if ! echo "$PHPENV_VERSION" | grep -q -E '^\d+\.\d+\.\d+$'; then
    echo "not php version: $1"
    exit
fi

if ! type phpenv >/dev/null 2>&1; then
    echo 'missing phpenv'
    exit
fi

if [ -z "$FORCE" -a -d "`phpenv root`/versions/$PHPENV_VERSION" ]; then
    echo "already installed: $PHPENV_VERSION"
    exit
fi

rpv=`echo "$PHPENV_VERSION" | sed -e 's/\./_0/g; s/_0*\([0-9][0-9]\)/\1/g'`
if [ $rpv -lt 70205 ]; then
    echo "unsupported version: $PHPENV_VERSION"
    [ -z "$FORCE" ] && exit
    echo "installing may fail..."
fi

if ! type brew >/dev/null 2>&1; then
    echo 'missing: Homebrew'
    exit
fi

libs='bzip2 libiconv tidy-html5 libzip zlib'
if [ $rpv -lt 70400 ]; then
    libs="$libs bison@2.7 libedit re2c"
fi
if [ $rpv -lt 60000 ]; then
    libs="$libs curl libmcrypt"
fi

missing=''
for lib in $libs; do
    prefix=`brew --prefix "$lib" 2>/dev/null` ||:
    if [ -z "$prefix" -o ! -d "$prefix" ]; then
        missing="$missing $lib"
    fi
done
if [ -n "$missing" ]; then
    echo "missing lib:$missing"
    exit
fi

export PHP_BUILD_EXTRA_MAKE_ARGUMENTS="-j`sysctl -n hw.logicalcpu`"
export PHP_BUILD_CONFIGURE_OPTS="\
    --with-pear \
    --with-zlib \
    --with-bz2=$(brew --prefix bzip2) \
    --with-iconv=$(brew --prefix libiconv) \
    --with-tidy=$(brew --prefix tidy-html5) \
    --with-zlib-dir=$(brew --prefix zlib) \
"
if [ $rpv -lt 70400 ]; then
    export PATH="$(brew --prefix bison@2.7)/bin:$PATH"
    export CPPFLAGS="$CPPFLAGS \
        -DU_DEFINE_FALSE_AND_TRUE=1 \
        -Wno-implicit-function-declaration \
    "
fi
if [ $rpv -lt 60000 ]; then
    export PHP_BUILD_CONFIGURE_OPTS="$PHP_BUILD_CONFIGURE_OPTS \
        --with-curl=$(brew --prefix curl) \
    "
fi

phpenv install -f "$PHPENV_VERSION"

if [ -n "$PHPENV_PECLS" ]; then
    for pecl in $PHPENV_PECLS; do
        pecl install "$pecl"
    done
fi

if [ -n "$PHPENV_GLOBAL_PACKAGES" ]; then
    for package in $PHPENV_GLOBAL_PACKAGES; do
        composer global require "$package"
    done
fi

phpenv rehash
