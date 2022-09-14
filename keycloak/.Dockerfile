FROM quay.io/keycloak/keycloak:latest as builder

ENV KC_HEALTH_ENABLED=true
ENV KC_METRICS_ENABLED=true
ENV KC_FEATURES=token-exchange
ENV KC_DB=mysql
# Install custom providers
RUN curl -sL https://github.com/aerogear/keycloak-metrics-spi/releases/download/2.5.3/keycloak-metrics-spi-2.5.3.jar -o /opt/keycloak/providers/keycloak-metrics-spi-2.5.3.jar
RUN /opt/keycloak/bin/kc.sh build

FROM quay.io/keycloak/keycloak:latest as prod
COPY --from=builder /opt/keycloak/ /opt/keycloak/
WORKDIR /opt/keycloak
RUN mkdir /opt/keycloak/data/import
COPY nodered-realm.json /opt/keycloak/data/import
ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]