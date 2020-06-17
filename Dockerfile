#########################
# multi stage Dockerfile
# 1. set up the build environment and build the expath-package
# 2. run the eXist-db
#########################
FROM openjdk:8-jdk as builder
LABEL maintainer="Peter Stadler,Omar Siam"

ENV BUILD_HOME="/opt/builder"

# installing Apache Ant
RUN apt-get update \
    && apt-get install -y --no-install-recommends apt-transport-https ant curl unzip patch

# Get and setup orbeon
RUN curl -OL https://github.com/orbeon/orbeon-forms/releases/download/tag-release-2019.1-ce/orbeon-2019.1.0.201910220019-CE.zip
RUN unzip orbeon-*.zip && rm orbeon-*.zip && mv orbeon-* orbeon-dist &&\
    mkdir orbeon && cd orbeon && unzip ../orbeon-dist/orbeon.war &&\
    rm -rf xforms-jsp &&\
    rm -rf WEB-INF/resources/apps/context WEB-INF/resources/apps/home WEB-INF/resources/apps/sandbox-transformations\
        WEB-INF/resources/apps/xforms-[befs]* &&\
    rm -rf WEB-INF/resources/forms/orbeon/controls &&\
    rm -rf WEB-INF/resources/forms/orbeon/dmv-14  &&\
    rm -rf WEB-INF/lib/orbeon-form-builder.jar &&\
    rm -rf WEB-INF/lib/exist-*.jar &&\
    rm -rf WEB-INF/exist-data &&\
    rm  WEB-INF/exist-conf.xml WEB-INF/jboss-scanning.xml WEB-INF/liferay-display.xml WEB-INF/portlet.xml \
        WEB-INF/jboss-deployment-structure.xml WEB-INF/jboss-web.xml WEB-INF/liferay-portlet.xml WEB-INF/sun-web.xml WEB-INF/weblogic.xml &&\
    cd .. && mkdir orbeon-xforms-filter && cd orbeon-xforms-filter && unzip ../orbeon-dist/orbeon-xforms-filter.war
COPY orbeon-web.xml.patch /
RUN cd orbeon && patch -p0 < /orbeon-web.xml.patch && rm WEB-INF/web.xml.orig

# now building the main App
WORKDIR ${BUILD_HOME}
COPY . .
RUN ant 

#########################
# Now running the eXist-db
# and adding our freshly built xar-package
# as well as orbeon and the orbeon xforms filter
#########################
FROM existdb/existdb:5.3.0-SNAPSHOT

ENV CLASSPATH=/exist/lib/exist.uber.jar:/exist/lib/orbeon-xforms-filter.jar

COPY --from=builder /opt/builder/build/*.xar ${EXIST_HOME}/autodeploy/
COPY --from=builder /orbeon ${EXIST_HOME}/etc/jetty/webapps/orbeon
COPY jetty-exist-additional-config/etc/jetty/webapps/*.xml jetty-exist-additional-config/etc/jetty/webapps/*.properties ${EXIST_HOME}/etc/jetty/webapps/
COPY jetty-exist-additional-config/etc/jetty/webapps/portal/WEB-INF/* ${EXIST_HOME}/etc/jetty/webapps/portal/WEB-INF/
COPY --from=builder /orbeon-xforms-filter/WEB-INF/lib/orbeon-xforms-filter.jar ${EXIST_HOME}/lib/
COPY jetty-exist-additional-config/etc/webapp/WEB-INF/web.xml ${EXIST_HOME}/etc/webapp/WEB-INF/