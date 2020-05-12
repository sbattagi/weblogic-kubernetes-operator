---
title: "Oracle SOA Suite"
date: 2019-02-23T16:43:45-05:00
description: "The WebLogic Kubernetes operator supports deployment of SOA Suite components such as Oracle Service-Oriented Architecture (SOA), Oracle Service Bus (OSB), and Oracle Enterprise Scheduler (ESS). Follow the instructions in this guide to set up these Oracle SOA Suite domains on Kubernetes."
---

The WebLogic Kubernetes operator supports deployment of SOA Suite components such as Oracle Service-Oriented Architecture (SOA), Oracle Service Bus (OSB), and Oracle Enterprise Scheduler (ESS).

{{% notice warning %}}
Oracle SOA Suite is currently supported for non-production use only in Docker and Kubernetes.  The information provided
in this document is a *preview* for early adopters who wish to experiment with Oracle SOA Suite in Kubernetes before
it is supported for production use.
{{% /notice %}}

In this release, SOA Suite domains are supported using the “domain on a persistent volume”
[model](https://oracle.github.io/weblogic-kubernetes-operator/userguide/managing-domains/choosing-a-model/) only, where the domain home is located in a persistent volume (PV).

The operator has several key features to assist you with deploying and managing SOA domains in a Kubernetes
environment. You can:

* Create SOA instances in a Kubernetes persistent volume. This persistent volume can reside in an NFS file system or other Kubernetes volume types.
* Start servers based on declarative startup parameters and desired states.
* Expose the SOA Services and Composites for external access.
* Scale SOA domains by starting and stopping Managed Servers on demand, or by integrating with a REST API to initiate scaling based on WLDF, Prometheus, Grafana, or other rules.
* Publish operator and WebLogic Server logs into Elasticsearch and interact with them in Kibana.
* Monitor the SOA instance using Prometheus and Grafana.

### Limitations

See [here]({{< relref "/soa-domains/prerequisites#limitations">}}) for limitations in this release.

### Getting started

For detailed information about deploying Oracle SOA Suite domains, see the [User guide]({{< relref "/soa-domains/create-soa-domains" >}}).

### Current release

The [current release of the operator is 2.4.0](https://github.com/oracle/weblogic-kubernetes-operator/releases).
