#########################
# multi stage Dockerfile
# 1. set up the build environment and build the expath-package
# 2. run the eXist-db
#########################
ARG EXISTDB_IMAGE=existdb/existdb:6.0.1
FROM eclipse-temurin:8-jdk AS builder

ENV BUILD_HOME="/opt/builder"

# installing Apache Ant
RUN apt-get update \
    && apt-get install -y --no-install-recommends ant curl zip unzip patch git

# Get and setup orbeon
RUN curl -OL https://github.com/orbeon/orbeon-forms/releases/download/tag-release-2018.2.1-ce/orbeon-2018.2.1.201902072242-CE.zip
COPY orbeon-form-runner.jar /form-runner.jar
RUN unzip orbeon-*.zip && rm orbeon-*.zip && mv orbeon-* orbeon-dist &&\
    mkdir orbeon && cd orbeon && unzip ../orbeon-dist/orbeon.war &&\
    rm -rf xforms-jsp &&\
    rm -rf WEB-INF/resources/apps/context WEB-INF/resources/apps/home WEB-INF/resources/apps/sandbox-transformations\
        WEB-INF/resources/apps/xforms-[befs]* &&\
    rm -rf WEB-INF/resources/forms/orbeon/controls &&\
    rm -rf WEB-INF/resources/forms/orbeon/dmv-14  &&\
    rm -rf WEB-INF/lib/orbeon-form-builder.jar &&\
    rm -rf WEB-INF/lib/exist-*.jar &&\
    rm -rf WEB-INF/lib/slf4j-*.jar &&\
    rm -rf WEB-INF/exist-data &&\
    rm  WEB-INF/exist-conf.xml WEB-INF/jboss-scanning.xml WEB-INF/liferay-display.xml WEB-INF/portlet.xml \
        WEB-INF/jboss-web.xml WEB-INF/liferay-portlet.xml WEB-INF/sun-web.xml WEB-INF/weblogic.xml &&\
    cd /form-runner.jar && zip -u /orbeon/WEB-INF/lib/orbeon-form-runner.jar &&\
    cd .. && mkdir orbeon-xforms-filter && cd orbeon-xforms-filter && unzip ../orbeon-dist/orbeon-xforms-filter.war
COPY orbeon-web.xml.patch /
RUN cd orbeon && patch -p0 < /orbeon-web.xml.patch && rm -f WEB-INF/web.xml.orig

# now building the main App
WORKDIR ${BUILD_HOME}
COPY . .
RUN ant

#########################
# Now running the eXist-db
# and adding our freshly built xar-package
# as well as orbeon and the orbeon xforms filter
#########################
FROM ${EXISTDB_IMAGE}
LABEL org.opencontainers.image.authors="Peter Stadler,Omar Siam"
LABEL org.opencontainers.image.source="https://github.com/Edirom/MerMEId"

ENV CLASSPATH=/exist/lib/*

# add xar dependencies to the autodeploy folder 
ADD http://exist-db.org/exist/apps/public-repo/public/shared-resources-0.9.1.xar ${EXIST_HOME}/autodeploy
ADD http://exist-db.org/exist/apps/public-repo/public/functx-1.0.1.xar ${EXIST_HOME}/autodeploy

# add our freshly build MerMEId xar to the autodeploy folder
COPY --from=builder /opt/builder/build/*.xar ${EXIST_HOME}/autodeploy/

COPY --from=builder /orbeon ${EXIST_HOME}/etc/jetty/webapps/orbeon
COPY jetty-exist-additional-config/etc/jetty/webapps/*.xml jetty-exist-additional-config/etc/jetty/webapps/*.properties ${EXIST_HOME}/etc/jetty/webapps/
COPY jetty-exist-additional-config/etc/jetty/webapps/portal/WEB-INF/* ${EXIST_HOME}/etc/jetty/webapps/portal/WEB-INF/
COPY --from=builder /orbeon-xforms-filter/WEB-INF/lib/orbeon-xforms-filter.jar ${EXIST_HOME}/lib/
COPY jetty-exist-additional-config/etc/webapp/WEB-INF/*.xml ${EXIST_HOME}/etc/webapp/WEB-INF/
COPY orbeon-additional-config/WEB-INF/resources/config/* ${EXIST_HOME}/etc/jetty/webapps/orbeon/WEB-INF/resources/config/
RUN ["java", "net.sf.saxon.Transform", "-s:/exist/etc/log4j2.xml", "-xsl:/exist/etc/jetty/webapps/orbeon/WEB-INF/resources/config/log4j2-patch.xsl", "-o:/exist/etc/log4j2.xml"]

# install all the default application XAR so startup is faster. See tei-publisher's Dockerfile
# pre-populate the database by launching it once
# NB, this does not work for us since we want to be able to overwrite settings (via `post-install.xql`)
# and this is *only* possible on installation of the package!
#RUN [ "java", \
#    "org.exist.start.Main", "client", "-l", \
#    "--no-gui",  "--xpath", "system:get-version()" ]

# overwrite default healthcheck and explicitly set `-ouri`
# see https://github.com/Edirom/MerMEId/issues/222
HEALTHCHECK CMD [ "java", \
    "org.exist.start.Main", "client", \
    "--no-gui",  \
    "--user", "guest", "--password", "guest", \
    "-ouri=xmldb:exist://localhost:8080/xmlrpc", \
    "--xpath", "system:get-version()" ]
