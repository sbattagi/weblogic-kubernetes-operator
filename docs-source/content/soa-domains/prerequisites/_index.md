---
title: "Prerequisites"
date: 2019-04-18T07:32:31-05:00
weight: 1
pre : "<b>1. </b>"
description: "Sample for creating a SOA Suite domain home on an existing PV or
PVC, and the domain resource YAML file for deploying the generated SOA domain."
---

### Introduction

The operator supports deployment of SOA Suite components such as Oracle Service-Oriented Architecture (SOA), Oracle Service Bus (OSB), and Oracle Enterprise Scheduler (ESS). Currently the operator supports these different domain types:

* `soa`: Deploys a SOA domain
* `osb`: Deploys an OSB (Oracle Service Bus) domain
* `soaess`: Deploys a SOA domain with Enterprise Scheduler (ESS)
* `soaosb`: Deploys a domain with SOA and OSB
* `soaessosb`: Deploys a domain with SOA, OSB, and ESS

This document provides information about the system requirements and limitations for deploying and running SOA Suite domains with the operator.

In this release, SOA Suite domains are supported using the “domain on a persistent volume”
[model](https://oracle.github.io/weblogic-kubernetes-operator/userguide/managing-domains/choosing-a-model/) only, where the domain home is located in a persistent volume (PV).

### System requirements for SOA Suite domains

* Kubernetes 1.13.5+, 1.14.3+ and 1.15.2+ (check with `kubectl version`).
* Flannel networking v0.11.0-amd64 (check with `docker images | grep flannel`).
* Docker 18.9.1 (check with `docker version`)
* Helm 2.14.0+ (check with `helm version`).
* Oracle Fusion Middleware Infrastructure 12.2.1.4.0 image `container-registry.oracle.com/middleware/fmw-infrastructure:12.2.1.4`.
* You must have the `cluster-admin` role to install the operator.
* We do not currently support running SOA in non-Linux containers.

### Limitations

Compared to running a WebLogic Server domain in Kubernetes using the operator, the
following limitations currently exist for SOA Suite domains:

* The "domain in image" model is not supported.
* Only configured clusters are supported.  Dynamic clusters are not supported for
  SOA Suite domains.  Note that you can still use all of the scaling features,
  you just need to define the maximum size of your cluster at domain creation time.
* Deploying and running SOA Suite domains is supported only in operator versions 2.4.0 and later.
* The [WebLogic Logging Exporter](https://github.com/oracle/weblogic-logging-exporter)
  currently supports WebLogic Server logs only.  Other logs will not be sent to
  Elasticsearch.  Note, however, that you can use a sidecar with a log handling tool
  like Logstash or fluentd to get logs.
* The [WebLogic Monitoring Exporter](https://github.com/oracle/weblogic-monitoring-exporter)
  currently supports the WebLogic MBean trees only.  Support for JRF MBeans has not
  been added yet.


### Oracle SOA Cluster Sizing Recommendations
Oracle SOA | Normal Usage | Moderate Usage | High Usage 
--- | --- | --- | --- 
Admin Server | No of CPU(s) : 1, Memory : 4GB | No of CPU(s) : 1, Memory : 4GB | No of CPU(s) : 1, Memory : 4GB 
Managed Server | No of Servers : 2, No of CPU(s) : 2, Memory : 16GB | No of Servers : 2, No of CPU(s) : 4, Memory : 16GB | No of Servers : 3, No of CPU(s) : 6, Memory : 16-32GB
PV Storage | Minimum 250GB | Minimum 250GB | Minimum 500GB


