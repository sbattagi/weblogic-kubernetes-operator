+++
title=  "Prepare your environment"
date = 2019-04-18T06:46:23-05:00
weight = 2
pre = "<b>2. </b>"
description = "SOA domains include the deployment of various Oracle Service-Oriented Architecture (SOA) Suite components, such as SOA, Oracle Service Bus (OSB), and Oracle Enterprise Scheduler (ESS)."
+++

{{% notice warning %}}
Oracle SOA Suite is currently supported only for non-production use in Docker and Kubernetes.  The information provided
in this document is a *preview* for early adopters who wish to experiment with Oracle SOA Suite in Kubernetes before
it is supported for production use.
{{% /notice %}}

1. [Set up your Kubernetes cluster](#set-up-your-kubernetes-cluster)
1. [Install Helm and Tiller](#install-helm-and-tiller)
1. [Get dependent Images](#get-dependent-images)
1. [Set up the code repository to deploy Oracle SOA Suite domains](#set-up-the-code-repository-to-deploy-oracle-soa-suite-domains)
1. [Obtaining the SOA Suite Docker image](#obtaining-the-soa-suite-docker-image)
1. [Creating a SOA Suite Docker image](#creating-a-soa-suite-docker-image)
1. [Creating a custom SOA Suite Docker image using Imagetool](#creating-a-custom-soa-suite-docker-image-using-imagetool)
1. [Install the WebLogic Kubernetes Operator](#install-the-weblogic-kubernetes-operator)
1. [Prepare the environment for Oracle SOA Suite Domains](#prepare-the-environment-for-oracle-soa-suite-domains)
    1. [Create a namespace for SOA Domain](#create-a-namespace-for-soa-domain)
    1. [Create a persistent storage for SOA Domain](#create-a-persistent-storage-for-soa-domain)
    1. [Create a secret with domain credentials](#create-a-secret-with-domain-credentials)
    1. [Create a Kubernetes secret with the RCU credentials](#create-a-kubernetes-secret-with-the-rcu-credentials)
    1. [Configuring access to your database](#configuring-access-to-your-database)
    1. [Running the Repository Creation Utility to set up your database schemas](#running-the-repository-creation-utility-to-set-up-your-database-schemas)
1. [Creating a SOA domain](#creating-a-soa-domain)


### Set up your Kubernetes cluster

If you need help setting up a Kubernetes environment, check our [cheat sheet](https://oracle.github.io/weblogic-kubernetes-operator/userguide/overview/k8s-setup/).

After creating Kubernetes clusters, you can optionally:

* Create load balancers to direct traffic to backend domains.
* Configure Kibana and Elasticsearch for your operator logs.

### Install Helm and Tiller

The operator uses Helm to create and deploy the necessary resources and then run the operator in a Kubernetes cluster. For Helm installation and usage information, see [Install Helm and Tiller](https://oracle.github.io/weblogic-kubernetes-operator/userguide/managing-operators/#install-helm-and-tiller).

### Get dependent Images

Get these images and put them into your local registry.

1. If you don't already have one, obtain a Docker store account, log in to the Docker store
and accept the license agreement for the [WebLogic Server image](https://hub.docker.com/_/oracle-weblogic-server-12c).

1. Log in to the Docker store from your Docker client:

    ```bash
    $ docker login
    ```

1. Pull the operator image:

    ```bash
    $ docker pull oracle/weblogic-kubernetes-operator:2.4.0
    ```

1. Pull the Traefik load balancer image:

    ```bash
    $ docker pull traefik:1.7.12
    ```

1. Pull the Oracle Database image:

    ```bash
    $ docker pull container-registry.oracle.com/database/enterprise:12.2.0.1-slim
    $ docker tag container-registry.oracle.com/database/enterprise:12.2.0.1-slim  oracle/database:12.2.0.1
    ```

### Set up the code repository to deploy Oracle SOA Suite domains

Oracle SOA Suite domains deployment on Kubernetes leverages the Oracle WebLogic Kubernetes Operator infrastructure. For deploying the Oracle SOA Suite domains, you need to set up the deployment scripts as below:

1. Create a working directory to setup the source code.
   ```bash
   $ mkdir <work directory>
   $ cd <work directory>
   ```

1. Download the supported version of Oracle WebLogic Kubernetes Operator source code archieve file (`.zip`/`.tar.gz`) from the operator [relases page](https://github.com/oracle/weblogic-kubernetes-operator/releases). Currently the supported operator version is [2.4.0](https://github.com/oracle/weblogic-kubernetes-operator/releases/tag/v2.4.0).

1. Extract the source code archive file (`.zip`/`.tar.gz`) in to the work directory.

1. Download the SOA Suite kubernetes deployment scripts from the SOA [repository](https://orahub.oraclecorp.com/tooling/fmw-kubernetes.git) and copy them in to WebLogic operator samples location.

   ```bash
   $ git clone https://orahub.oraclecorp.com/tooling/fmw-kubernetes.git
   $ cp -rf <work directory>/fmw-kubernetes/OracleSOASuite/kubernetes/2.4.0/create-soa-domain  <work directory>/weblogic-kubernetes-operator-2.4.0/kubernetes/samples/scripts/
   ```

You can now use the deployment scripts from `<work directory>/weblogic-kubernetes-operator-2.4.0/kubernetes/samples/scripts/` to set up the SOA Suite domains as further described in this document.


### Obtaining the SOA Suite Docker Image

The pre-built Oracle SOA Suite image is available at, `container-registry.oracle.com/middleware/soasuite:12.2.1.4` (TBD).

To pull an image from the Oracle Container Registry, in a web browser, navigate to https://container-registry.oracle.com and log in
using the Oracle Single Sign-On authentication service. If you do not already have SSO credentials, at the top of the page, click the Sign In link to create them.

Use the web interface to accept the Oracle Standard Terms and Restrictions for the Oracle software images that you intend to deploy.
Your acceptance of these terms are stored in a database that links the software images to your Oracle Single Sign-On login credentials.

To obtain the image, log in to the Oracle Container Registry:

```
$ docker login container-registry.oracle.com
```

Then, you can pull the image with this command:

```
$ docker pull container-registry.oracle.com/middleware/soasuite:12.2.1.4
```

### Creating a SOA Suite Docker image

You can also create a Docker image containing the Oracle SOA Suite binaries. This is the recommended approach if you have access to the Oracle SOA bundle patch.

Please consult the [README](https://github.com/oracle/docker-images/blob/master/OracleSOASuite/dockerfiles/README.md) file for important prerequisite steps,
such as building or pulling the Server JRE Docker image, Oracle FMW Infrastructure Docker image, and downloading the Oracle SOA Suite installer and bundle patch binaries.

A pre-built Fusion Middleware Infrastructure image, `container-registry.oracle.com/middleware/fmw-infrastructure:12.2.1.4`, is available at `container-registry.oracle.com`. We recommend that you pull and rename this image to build the Oracle SOA Suite image.


  ```bash
    $ docker pull container-registry.oracle.com/middleware/fmw-infrastructure:12.2.1.4
    $ docker tag container-registry.oracle.com/middleware/fmw-infrastructure:12.2.1.4  oracle/fmw-infrastructure:12.2.1.4
  ```

Follow these steps to build the necessary images - a Fusion Middleware Infrastructure image, and then the SOA Suite image as a layer on top of that:

* Make a local clone of the sample repository.

    ```bash
    $ git clone https://github.com/oracle/docker-images
    ```
* Build the `oracle/fmw-infrastructure:12.2.1.4` image as shown below:

  ```bash
    $ cd docker-images/OracleFMWInfrastructure/dockerfiles
    $ sh buildDockerImage.sh -v 12.2.1.4 -s
  ```
    This will produce an image named `oracle/fmw-infrastructure:12.2.1.4`.

* Download the Oracle SOA Suite installer, latest Oracle SOA bundle patch (`30638101` or later) from the Oracle Technology Network or e-delivery.

  >**NOTE**: Copy the installer binaries to the same location as the Dockerfile and the patch ZIP files under the `docker-images/OracleSOASuite/dockerfiles/12.2.1.4/patches` folder.

* Create the Oracle SOA Suite image by running the provided script:

    ```bash
    $ cd docker-images/OracleSOASuite/dockerfiles
    $ ./buildDockerImage.sh -v 12.2.1.4 -s
    ```

    The image produced will be named `oracle/soa:12.2.1.4`. The samples and instructions assume the Oracle SOA Suite image is named `container-registry.oracle.com/middleware/soasuite:12.2.1.4`. You will need to rename your image to match this name, or update the samples to refer to the image you created.

    ```bash
    $ docker tag oracle/soa:12.2.1.4 container-registry.oracle.com/middleware/soasuite:12.2.1.4
    ```

    You can use this image to run the Repository Creation Utility and to run your domain using the “domain on a persistent volume” model.


### Creating a custom SOA Suite Docker image using Imagetool
Steps: To be verified and added here.

### Install the WebLogic Kubernetes Operator

The WebLogic Kubernetes Operator supports the deployment of Oracle SOA Suite domains in Kubernetes environment. Follow the steps in this [document](https://oracle.github.io/weblogic-kubernetes-operator/quickstart/install/) to install the operator.

{{% notice note %}}
For early access customers, with bundle patch access, we recommend that you build and use the Oracle SOA Suite Docker image with the latest bundle patch for Oracle SOA. The Oracle SOA Suite Docker image in `container-registry.oracle.com` does not have the bundle patch installed. However, if you do not have access to the bundle patch, you can obtain the Oracle SOA Suite Docker image without the bundle patch from `container-registry.oracle.com`, as described below.
{{% /notice %}}


### Prepare the environment for Oracle SOA Suite Domains

#### Create a namespace for SOA Domain
   
   Create a Kubernetes namespace (for example, `soans`) for the domain unless you intend to use the default namespace. Use the newly created namespace in all the other steps.
For details, see [Prepare to run a domain](https://oracle.github.io/weblogic-kubernetes-operator/userguide/managing-domains/prepare.md).

  ```
   $ kubectl create namespace soans
  ```
  
#### Create a persistent storage for SOA Domain
  
   In the Kubernetes namespace created above, create the PV and PVC for the database by running the [create-pv-pvc.sh](https://oracle.github.io/weblogic-kubernetes-operator/samples/simple/storage/_index.md) script. Follow the instructions for using the scripts to create a PV and PVC.

    * Change the values in the [create-pv-pvc-inputs.yaml](https://github.com/oracle/weblogic-kubernetes-operator/blob/master/kubernetes/samples/scripts/create-weblogic-domain-pv-pvc/create-pv-pvc-inputs.yaml) file based on your requirements.

    * Ensure that the path for the `weblogicDomainStoragePath` property exists (if not, you need to create it),
    has full access permissions, and that the folder is empty.
	
#### Create a secret with domain credentials
   
   Create the Kubernetes secrets `username` and `password` of the administrative account in the same Kubernetes
  namespace as the domain. For details, see this [document](https://github.com/oracle/weblogic-kubernetes-operator/blob/master/kubernetes/samples/scripts/create-weblogic-domain-credentials/README.md).

    ```bash
    $ cd kubernetes/samples/scripts/create-weblogic-domain-credentials
    $ ./create-weblogic-credentials.sh -u weblogic -p Welcome1 -n soans -d soainfra -s soainfra-domain-credentials
    ```

    You can check the secret with the `kubectl get secret` command. See the following example, including the output:

    ```bash
    $ kubectl get secret soainfra-domain-credentials -o yaml -n soans
    apiVersion: v1
    data:
      password: V2VsY29tZTE=
      username: d2VibG9naWM=
    kind: Secret
    metadata:
      creationTimestamp: 2019-06-02T07:05:25Z
      labels:
        weblogic.domainName: soainfra
        weblogic.domainUID: soainfra
      name: soainfra-domain-credentials
      namespace: soans
      resourceVersion: "11561988"
      selfLink: /api/v1/namespaces/soans/secrets/soainfra-domain-credentials
      uid: a91ef4e1-6ca8-11e9-8143-fa163efa261a
    type: Opaque
    ```
	
#### Create a Kubernetes secret with the RCU credentials
   
   You also need to create a Kubernetes secret containing the credentials for the database schemas.
When you create your domain using the sample provided below, it will obtain the RCU credentials
from this secret.

Use the provided sample script to create the secret as shown below:

```bash
$ cd kubernetes/samples/scripts/create-rcu-credentials
$ ./create-rcu-credentials.sh \
  -u SOA1_SOAINFRA \
  -p Welcome1 \
  -a sys \
  -q Oradoc_db1 \
  -d soainfra \
  -n soans \
  -s soainfra-rcu-credentials
```

The parameter values are as follows:

* The schema owner user name (`-u`) must be the `schemaPrefix`
value followed by an underscore and a component name, for example `SOA1_SOAINFRA`.
* The schema owner password (`-p`) will be the password you provided for regular schema users during RCU creation.
* The database administration user (`-u`) and password (`-q`).
* The `domainUID` for the domain (`-d`).
* The namespace the domain is in (`-n`); if omitted, then `default` is assumed.
* The name of the secret (`-s`).

You can confirm the secret was created as expected with the `kubectl get secret` command.
An example is shown below, including the output:

```bash
$ kubectl get secret soainfra-rcu-credentials -o yaml -n soans
apiVersion: v1
data:
  password: V2VsY29tZTE=
  sys_password: T3JhZG9jX2RiMQ==
  sys_username: c3lz
  username: U09BMQ==
kind: Secret
metadata:
  creationTimestamp: 2019-06-02T07:15:31Z
  labels:
    weblogic.domainName: soainfra
    weblogic.domainUID: soainfra
  name: soainfra-rcu-credentials
  namespace: soans
  resourceVersion: "11562794"
  selfLink: /api/v1/namespaces/soans/secrets/soainfra-rcu-credentials
  uid: 1230385e-6caa-11e9-8143-fa163efa261a
type: Opaque
```

#### Configuring access to your database
   
   SOA Suite domains require a database with the necessary schemas installed in them.
The Repository Creation Utility (RCU) allows you to create
those schemas.  You must set up the database before you create your domain.
There are no additional requirements added by running SOA in Kubernetes; the
same existing requirements apply.

For testing and development, you may choose to run your database inside Kubernetes or outside of Kubernetes.

{{% notice warning %}}
The Oracle Database Docker images are supported for non-production use only.
For more details, see My Oracle Support note:
Oracle Support for Database Running on Docker (Doc ID 2216342.1).
{{% /notice %}}

##### Running the database inside Kubernetes

Follow these instructions to perform a basic deployment of the Oracle
database in Kubernetes. For more details about database setup and configuration, refer to this [page](https://oracle.github.io/weblogic-kubernetes-operator/userguide/managing-fmw-domains/fmw-infra/#running-the-database-inside-kubernetes).

When running the Oracle database in Kubernetes, you have an option to attach persistent volumes (PV) so that the database storage will be persisted across database restarts. If you prefer not to persist the database storage, follow the instructions in this [document](https://github.com/oracle/weblogic-kubernetes-operator/tree/master/kubernetes/samples/scripts/create-rcu-schema#start-an-oracle-database-service-in-a-kubernetes-cluster) to set up a database in a container with no persistent volume (PV) attached.

>**NOTE**: `start-db-service.sh` creates the database in the `default` namespace. If you
>want to create the database in a different namespace, you need to manually update
>the value for all the occurrences of the namespace field in the provided
>sample file `create-rcu-schema/common/oracle.db.yaml`.

These instructions will set up the database in a container with the persistent volume (PV) attached.
If you chose not to use persistent storage, please go to the [RCU creation step](#running-the-repository-creation-utility-to-set-up-your-database-schemas).

* Create the persistent volume and persistent volume claim for the database
using the [create-pv-pvc.sh](https://oracle.github.io/weblogic-kubernetes-operator/samples/simple/storage/) sample.
Refer to the instructions provided in that sample.

{{% notice note %}}
When creating the PV and PVC for the database, make sure that you use a different name
and storage class for the PV and PVC for the domain.
The name is set using the value of the `baseName` field in `create-pv-pvc-inputs.yaml`.
{{% /notice %}}

* Start the database and database service using the following commands:

>**NOTE**: Make sure you update the `kubernetes/samples/scripts/create-soa-domain/domain-home-on-pv/create-database/db-with-pv.yaml`
>file with the name of the PVC created in the previous step. Also, update the value for all the occurrences of the namespace field
>to the namespace where the database PVC was created.

    ```bash
    $ cd weblogic-kubernetes-operator/kubernetes/samples/scripts/create-soa-domain/domain-home-on-pv/create-database
    $ kubectl create -f db-with-pv.yaml
    ```

The database will take several minutes to start the first time, while it
performs setup operations.  You can watch the log to see its progress using
this command:

```bash
$ kubectl logs -f oracle-db -n soans
```

A log message will indicate when the database is ready.  Also, you can
verify the database service status using this command:

```bash
$ kubectl get pods,svc -n soans |grep oracle-db
po/oracle-db   1/1       Running   0          6m
svc/oracle-db   ClusterIP   None         <none>        1521/TCP,5500/TCP   7m
```
Before creating a domain, you will need to set up the necessary schemas in your database.

#### Running the Repository Creation Utility to set up your database schemas

##### Creating schemas

To create the database schemas for Oracle SOA Suite, run the `create-rcu-schema.sh` script as described
[here](https://github.com/oracle/weblogic-kubernetes-operator/tree/master/kubernetes/samples/scripts/create-rcu-schema#create-the-rcu-schema-in-the-oracle-database).

The following example shows commands you might use to execute `create-rcu-schema.sh`:

```bash
$ cd weblogic-kubernetes-operator/kubernetes/samples/scripts/create-rcu-schema
$ ./create-rcu-schema.sh \
  -s SOA1 \
  -t soaessosb \
  -d oracle-db.soans.svc.cluster.local:1521/devpdb.k8s \
  -i container-registry.oracle.com/middleware/soasuite:12.2.1.4
```

For SOA domains, the `create-rcu-schema.sh` script supports the following domain types `soa,osb,soaosb,soaess,soaessosb`.
You must specify one of these using the `-t` flag.

You need to make sure that you maintain the association between the database schemas and the
matching domain just like you did in a non-Kubernetes environment.  There is no specific
functionality provided to help with this.

##### Dropping schemas

If you want to drop the schema, you can use the `drop-rcu-schema.sh` script as described
[here](https://github.com/oracle/weblogic-kubernetes-operator/tree/master/kubernetes/samples/scripts/create-rcu-schema#drop-the-rcu-schema-from-the-oracle-database).

The following example shows commands you might use to execute `drop-rcu-schema.sh`:

```bash
$ cd weblogic-kubernetes-operator/kubernetes/samples/scripts/create-rcu-schema
$ ./drop-rcu-schema.sh \
  -s SOA1 \
  -t soaessosb \
  -d oracle-db.soans.svc.cluster.local:1521/devpdb.k8s
```

For SOA domains, the `drop-rcu-schema.sh` script supports the domain types `soa,osb,soaosb,soaess,soaessosb`.
You must specify one of these using the `-t` flag.

### Creating a SOA domain

Now that you have your Docker images and you have created your RCU schemas, you are ready to create your domain.  To continue, follow the instructions in [Create SOA Domains]({{< relref "/manage-fmw-domains/wcsites-domains/create-soa-domains/_index.md" >}}).

