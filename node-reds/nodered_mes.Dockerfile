FROM nodered/node-red:latest

# Install Node red as in the doc
COPY ./package.json .
RUN npm install --unsafe-perm --no-update-notifier --no-fund --only=production
COPY ./settings.js /data/settings.js
#copying flows is useless as a project repo will be used. 

# Add github as a safe host
RUN --mount=type=ssh mkdir -p /usr/src/node-red/.ssh && \
    chmod 0700 /usr/src/node-red/.ssh && \
    ssh-keyscan github.com > /usr/src/node-red/.ssh/known_hosts
RUN mkdir -p /data/projects
USER root

#Install package for using Open ID Connect of keycloak within node red
WORKDIR /usr/src/node-red
RUN npm install passport-keycloak-oauth2-oidc

#Make node-red the rightful owner of /data 
RUN chown -R node-red:node-red /data
USER node-red

#Default writer role is "*", meaning everybody
ENV KEYCLOAK_WRITER_ROLE=*
