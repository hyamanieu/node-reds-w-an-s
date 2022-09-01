# Node-REDs with an S

A how-to or template for managing several node red services using git-based project

NB: THIS WORK IS STILL IN PROGRESS

## Introduction

If you're looking for an open-source platform:

- where several people can work together on low-code projects,
- where these projects don't step on each other (no side effects!),
- where these projects have version control,
- where authentication & authorization is implemented so that not anybody can mess with production-ready code,
- and where you can monitor all of these,

then you landed on the right page!

## Overview

These are the tools used here (work in progress if unchecked):

- [ ] [Node-Red](https://github.com/node-red/node-red-docker) is used for our low code development platforms (with an S!). It has a large range of modules compatible with most data entries, including the most modern & standard APIs (Rest, MQTT, OPC-UA), or [legacy industrial APIs of old school PLC (Mitsubishi, Allen Bradley, Omron, Siemens, etc)](https://flows.nodered.org/search?term=PLC&type=node). Most importantly, it takes little effort to have code running in production: no DevOps required!
- [ ] [FastAPI](https://github.com/tiangolo/fastapi) is used to make a very simple landing page.
- [X] [Keycloak](https://github.com/keycloak) is used to manage users. It is compatible with common identity providers such as Microsoft Azure Active Directory or Google.
- [X] [Traefik](https://github.com/traefik/traefik) is proxying the various services over TLS thanks to Let's Encrypt
- [ ] [Grafana & Prometheus stack](https://github.com/vegasbrianc/prometheus) for monitoring everything

These services will all be running on docker, so almost everything you need is code.

## Prerequisite

This stack is tested on the following configuration, but similar setups may work:

- Debian 10 & Ubuntu 20.04
- `docker` version 20.10.17
- `docker compose` 2.6.0 (note the lack of dash)
- a domain name directing to your host, although you may make it work on debian/ubuntu with self-signed certificates & proper configuration (topic unaddressed here)

## Getting started

This repository may run as is, although it is meant to be modified to fit your use case. Environmental variables are used for critical information (like the domain name). However some intrinsic passwords of some backends will need to be updated. Review them in each `compose.yaml` file.

### create an `.env` file

Several key environmental values need to be added for this project to work. You can copy the template with `cp template.env .env` and fill it out.

Two important keys are:

- `DOMAINNAME`: your domaine name, e.g. example.com
- `DOMAINEMAIL`: email address you will use for [Let's Encrypt](https://letsencrypt.org)

Then you can run:

```sh
export .env
docker compose -f ./<service>/compose.yaml up -d #execute as many times as needed
```

Where `<service>` are the folders containing available docker micro services.
