#!/bin/sh

# ==============================================================================
# XWiki on Tomcat Build Script (Alpine Linux)
# ==============================================================================

# ------------------------------------------------------------------------------
# Install Prerequisite Packages
# ------------------------------------------------------------------------------

apk update
apk add --no-cache \
    curl \
    gnupg
echo Purging apk cache...
apk cache clean

# ------------------------------------------------------------------------------
# Go Get XWiki
# ------------------------------------------------------------------------------
mkdir /data/xwiki-dl

# See if we need to download XWiki

if [ ! -f /data/xwiki-dl/${XWIKI_WARFILE} ]; then
    echo Downloading warfile...
    curl -o /data/xwiki-dl/${XWIKI_WARFILE} ${XWIKI_DL_URL}
fi

if [ ! -f /data/xwiki-dl/${XWIKI_WARFILE}.asc ]; then
    echo Downloading PGP sig...
    curl -o "/data/xwiki-dl/${XWIKI_WARFILE}.asc" "${XWIKI_DL_URL}.asc"
fi


# Check the war file signature
gpg --recv-key $XWIKI_WAR_KEY

gpg --verify "/data/xwiki-dl/${XWIKI_WARFILE}.asc" \
    "/data/xwiki-dl/${XWIKI_WARFILE}"

if [ $? -ne 0 ]; then
    (>&2 echo URGENT: WAR FILE DOES NOT MATCH PGP SIGNATURE!)
    (>&2 echo THIS IS NOT PARTICULARLY GOOD. CHECK YOUR DOWNLOAD.)
    (>&2 echo BUILD PROCESS TERMINATED. CONTAINER WILL NOT FUNCTION.)
    exit 1
fi

echo War file passed PGP signature check.

# ------------------------------------------------------------------------------
# Some Configuration
# ------------------------------------------------------------------------------

# Apply build-time file overrides
echo Applying build-time file overrides...
cp -R /data/overrides/* /usr/local/tomcat/
#rm -rf /data/overrides

echo Container build complete.
