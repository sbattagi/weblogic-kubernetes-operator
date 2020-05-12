---
title: "Delete the SOA domain home"
date: 2019-02-22T15:44:42-05:00
draft: false
weight: 3
pre : "<b>3. </b>"
description: "Learn about the steps to cleanup the SOA domain home."
---

Sometimes in production, but most likely in testing environments, you might want to remove the domain home that is generated using the `create-domain.sh` script. Do this by running the generated `delete domain job` script in the `/<path to weblogic-operator-output-directory>/weblogic-domains/<domainUID>` directory.

```
$ kubectl create -f delete-domain-job.yaml

```

