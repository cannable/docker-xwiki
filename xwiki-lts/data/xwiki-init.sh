#!/bin/sh

# ==============================================================================
# XWiki on Tomcat Init Script (Alpine Linux)
# ==============================================================================

warpath="/data/xwiki-dl/${XWIKI_WARFILE}"
apppath="/usr/local/tomcat/webapps/${LOCAL_APP_NAME}/"

# ------------------------------------------------------------------------------
# Install XWiki
# ------------------------------------------------------------------------------

if [ ! -d $apppath ]; then
    echo XWiki war not deployed yet. New container smell confirmed.
    # Check the PGP signature of the war file
    # (This is done during the build process, but paranoia here is okay)

    echo Checking war file PGP signature...
    gpg --verify ${warpath}.asc $warpath
    if [ $? -ne 0 ]; then
        (>&2 echo URGENT: WAR FILE DOES NOT MATCH PGP SIGNATURE!)
        (>&2 echo THIS IS NOT PARTICULARLY GOOD. THIS IMAGE IS PROBABLY FUBAR.)
        (>&2 echo CONTAINER RUN ABORTED.)
        exit 1
    fi

    echo War file passed PGP signature check.
    echo Extracting war to webapps/xwiki...

    mkdir $apppath
    unzip -d $apppath $warpath

    echo App extracted.
fi


# Set up the DB

if [ "${LOCAL_DB_DRIVER}" == "hsql" ]; then

    # Check to see if the hsql driver is in WEB-INF/lib
    if [ ! -f $apppath/WEB-INF/lib/${HSQL_JARNAME} ]; then
        echo HSQL driver not installed.

        # Download the file, if we have to
        if [ ! -f /data/xwiki-dl/${HSQL_ZIPNAME} ]; then
            curl -o /data/xwiki-dl/${HSQL_ZIPNAME} ${HSQL_DL_URL}
        fi

        # Check the file hash
        echo Checking hash of HSQL driver...

        echo "${HSQL_SHA1}  /data/xwiki-dl/${HSQL_ZIPNAME}" | sha1sum -c -

        if [ $? -ne 0 ]; then
            (>&2 echo ERROR: ${HSQL_FNAME} did not match the expected hash.)
            (>&2 echo Aborting.)
            exit 1
        fi

        # Install the DB driver
        echo Installing the HSQL driver...
        unzip -d /data/xwiki-dl/ /data/xwiki-dl/${HSQL_ZIPNAME} ${HSQL_ZIPPATH}

        cp /data/xwiki-dl/${HSQL_ZIPPATH} $apppath/WEB-INF/lib/${HSQL_JARNAME}
        echo Done.
    fi
fi


# ------------------------------------------------------------------------------
# Call the Tomcat init script from the originating container
# ------------------------------------------------------------------------------
echo Done setting up the container. Bringing up Tomcat.

/data/init.sh
