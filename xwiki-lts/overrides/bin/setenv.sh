export JAVA_OPTS="${JAVA_OPTS} -Djava.awt.headless=true"
export CATALINA_OPTS="-Djdk.tls.ephemeralDHKeySize=2048"

# Memory sizing
#export CATALINA_OPTS="${CATALINA_OPTS} -Xmx1024m -XX:MaxPermSize=192m"

# Allow encoded forward slashes in URLs
export CATALINA_OPTS="${CATALINA_OPTS} -Dorg.apache.tomcat.util.buf.UDecoder.ALLOW_ENCODED_SLASH=true"
export CATALINA_OPTS="${CATALINA_OPTS} -Dorg.apache.catalina.connector.CoyoteAdapter.ALLOW_BACKSLASH=true"
