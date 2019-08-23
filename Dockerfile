# TODO: this can be replaced by a hardened image once available.
FROM httpd:2.4-alpine

COPY htaccess.conf /usr/src/
RUN apk --no-cache add curl libarchive-tools && \
    curl -L -o /tmp/html5-boilerplate.zip https://github.com/h5bp/html5-boilerplate/releases/download/v7.2.0/html5-boilerplate_v7.2.0.zip && \
    bsdtar vxzC /usr/local/apache2/htdocs -f /tmp/html5-boilerplate.zip && \
    curl -L -o /tmp/apache-server-configs.zip https://github.com/h5bp/server-configs-apache/archive/3.2.1.zip && \
    mkdir -p /usr/src/server-configs-apache && \
    bsdtar vxzC /usr/src/server-configs-apache --strip-components=1 -f /tmp/apache-server-configs.zip && \
    rm /usr/local/apache2/htdocs/.htaccess && \
    /usr/src/server-configs-apache/bin/build.sh /usr/local/apache2/htdocs/.htaccess /usr/src/htaccess.conf && \
    sed -i'' -E 's/#LoadModule (setenvif|headers|deflate|filter|expires|rewrite|include)/LoadModule \1/g' /usr/local/apache2/conf/httpd.conf && \
    { \
    echo '<Directory "/usr/local/apache2/htdocs">'; \
    echo '    AllowOverride All'; \
    echo '</Directory>'; \
    echo 'TraceEnable Off'; \
    } >> /usr/local/apache2/conf/httpd.conf && \
    rm -rf /tmp/* /usr/src && \
    apk del curl libarchive-tools
