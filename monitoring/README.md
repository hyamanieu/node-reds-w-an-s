# Monitoring using prompetheus/grafana stack

Most of this folder comes from [Vegasbrianc's Prometheus stack](https://github.com/vegasbrianc/prometheus).

To log in Grafana, the same Keycloak client as for the Node-REDs is used. You can log in as `production-owner` for admin access. `developper` has by default the Editor role within Grafana, like any user with the `developper` role.

There is a single dashboard available which is preloaded. It will show you usage of all containers connected to traefik and from the host.

For receiving or configuring alerts, kindly review [Prometheus documentation](https://github.com/prometheus/prometheus) and [Alertmanager's](https://github.com/prometheus/alertmanager).