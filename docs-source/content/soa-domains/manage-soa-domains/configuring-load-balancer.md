---
title: "Configuring a load balancer for SOA Domains"
date: 2019-02-22T15:44:42-05:00
draft: false
weight: 1
pre: "<b>1. </b>"
description: "Learn about configuring an Ingress based load balancer for SOA domains."
---

An Ingress based load balancer can be configured to access the Oracle SOA and Oracle Service Bus domain application URLs.
Refer to the [setup Ingress](https://oracle.github.io/weblogic-kubernetes-operator/userguide/managing-domains/ingress/) document for details.

As part of the `ingress-per-domain` setup for Oracle SOA and Oracle Service Bus domains, the `values.yaml` file (under the `ingress-per-domain` directory) needs to be updated with the appropriate values from your environment. A sample `values.yaml` file (for the Traefik load balancer) is shown below:

```bash
# Default values for ingress-per-domain.
# This is a YAML-formatted file.
# Declare variables to be passed into your templates.

# Load balancer type.  Supported values are: TRAEFIK, VOYAGER
type: TRAEFIK

# WLS domain as backend to the load balancer
wlsDomain:
  domainUID: soainfra
  soaClusterName: soa_cluster
  osbClusterName: osb_cluster
  soaManagedServerPort: 8001
  osbManagedServerPort: 9001
  adminServerName: adminserver
  adminServerPort: 7001

# Traefik specific values
traefik:
  # hostname used by host-routing
  hostname: testhost.domain.com

# Voyager specific values
voyager:
  # web port
  webPort: 30305
  # stats port
  statsPort: 30315
```

Below are the path-based, Ingress routing rules (`spec.rules` section) that need to be defined for Oracle SOA and Oracle Service Bus domains. You need to update the appropriate Ingress template YAML file based on the load balancer being used. For example, the template YAML file for the Traefik load balancer is located at `kubernetes/samples/charts/ingress-per-domain/templates/traefik-ingress.yaml`.

```bash
rules:
  - host: '{{ .Values.traefik.hostname }}'
    http:
      paths:
      - path: /console
        backend:
          serviceName: '{{ .Values.wlsDomain.domainUID }}-{{ .Values.wlsDomain.adminServerName | lower | replace "_" "-" }}'
          servicePort: {{ .Values.wlsDomain.adminServerPort }}
      - path: /em
        backend:
          serviceName: '{{ .Values.wlsDomain.domainUID }}-{{ .Values.wlsDomain.adminServerName | lower | replace "_" "-" }}'
          servicePort: {{ .Values.wlsDomain.adminServerPort }}
      - path: /servicebus
        backend:
          serviceName: '{{ .Values.wlsDomain.domainUID }}-{{ .Values.wlsDomain.adminServerName | lower | replace "_" "-" }}'
          servicePort: {{ .Values.wlsDomain.adminServerPort }}
      - path: /lwpfconsole
        backend:
          serviceName: '{{ .Values.wlsDomain.domainUID }}-{{ .Values.wlsDomain.adminServerName | lower | replace "_" "-" }}'
          servicePort: {{ .Values.wlsDomain.adminServerPort }}
      - path:
        backend:
          serviceName: '{{ .Values.wlsDomain.domainUID }}-cluster-{{ .Values.wlsDomain.soaClusterName | lower | replace "_" "-" }}'
          servicePort: {{ .Values.wlsDomain.soaManagedServerPort }}
```

Now you can access the Oracle SOA Suite domain URLs, as listed below, based on the domain type you selected.

* Oracle SOA:

  http://\<hostname\>:\<port\>/weblogic/ready
  http://\<hostname\>:\<port\>/console
  http://\<hostname\>:\<port\>/em
  http://\<hostname\>:\<port\>/soa-infra
  http://\<hostname\>:\<port\>/soa/composer
  http://\<hostname\>:\<port\>/integration/worklistapp

* Oracle Enterprise Scheduler Service (ESS):

  http://\<hostname\>:\<port\>/ess
  http://\<hostname\>:\<port\>/EssHealthCheck

* Oracle Service Bus (OSB):

  http://\<hostname\>:\<port\>/servicebus
  http://\<hostname\>:\<port\>/lwpfconsole

