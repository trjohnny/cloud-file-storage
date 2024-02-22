# Deploying MinIO on Kubernetes with Minikube

This guide walks through the deployment of the MinIO Operator and a MinIO Tenant with TLS encryption on a Kubernetes cluster using Minikube. The MinIO Tenant will be configured for high availability and persistent storage, ensuring data durability across pod restarts and deletions.

## Prerequisites

- **Minikube**: Ensure Minikube is installed and running on your local machine. Follow the [Minikube installation guide](https://minikube.sigs.k8s.io/docs/start/) if needed.
- **Helm**: Helm 3 is required for deploying the MinIO Operator and Tenant. Install Helm from the [official documentation](https://helm.sh/docs/intro/install/).
- **Kubectl**: Ensure `kubectl` is installed to interact with your Kubernetes cluster. Installation instructions can be found [here](https://kubernetes.io/docs/tasks/tools/).

## Step 1: Start Minikube

Start your Minikube cluster with sufficient resources:

```shell
minikube start --cpus 4 --memory 8192
```

Adjust the CPU and memory allocations based on your system's capabilities and the expected workload.

## Step 2: Install MinIO Operator

1. **Add the MinIO Helm repository:**

    ```shell
    helm repo add minio https://helm.min.io/
    ```

2. **Update your local Helm chart repository cache:**

    ```shell
    helm repo update
    ```

3. **Install the MinIO Operator:**

    ```shell
    helm install \
      --namespace minio-operator \
      --create-namespace \
      operator minio-operator/operator
    ```

## Step 3: Prepare TLS Secret

The TLS secret named minio-tls-secret.yaml, containing the TLS certificate and key for the domain easyminiostorage.corp.company.it, has already been prepared. This secret will be applied to your Kubernetes cluster to enable TLS encryption for the MinIO service. If you want the browser to trust the certificate when accessing the MinIO console, make sure to insert the CA certificate (CA-cert.crt) into the keychain of your laptop. This step is crucial for avoiding security warnings when accessing the MinIO service through the browser.

## Step 4: Create Tenant Namespace

Create a namespace for your MinIO Tenant:

```shell
kubectl create namespace minio
```

## Step 5: Apply TLS Secret

Apply the secret to your cluster:

```shell
kubectl apply -f minio-tls-secret.yaml
```

## Step 6: Install MinIO Tenant

1. **(Optional) Adjust your custom `values.yaml` file for the Tenant deployment.** This file specifies configurations such as resource allocations, persistence settings, and the TLS secret reference.

2. **Install the Tenant using Helm, specifying your custom values:**

    ```shell
    helm install \
      --namespace minio \
      minio-tenant minio-operator/tenant \
      -f values.yaml
    ```


## Accessing MinIO

To access the MinIO Console after deployment, a couple of additional steps are required to ensure proper routing:

1. **Modify your `/etc/hosts` file:** Add an entry for `127.0.0.1 easyminiostorage.corp.company.it` to your `/etc/hosts` file. This step is necessary to route the domain name to your local Minikube environment.

    ```plaintext
    127.0.0.1 easyminiostorage.corp.company.it
    ```

2. **Enable ingress addon:** Enable the `ingress` addon on minikube running:
    ```shell
    minikube addons enable ingress
    ```
3. **Use `minikube tunnel`:** Upon verifying that all the pods are in the READY state, run `minikube tunnel` in a separate terminal window to expose the MinIO service externally. This command requires administrative privileges and will ask for your password.

After setting up the `/etc/hosts` file and starting `minikube tunnel`, you can access the MinIO Console by navigating to `https://easyminiostorage.corp.company.it` in your web browser. Ensure your browser trusts the CA certificate used by the MinIO service to avoid security warnings.


## Cleanup

To delete the MinIO Tenant and Operator from your cluster, use:

```shell
helm uninstall minio-tenant --namespace minio
helm uninstall minio-operator
kubectl delete namespace minio
```

## (Optional) Monitoring MinIO with Prometheus Operator

After deploying MinIO, you can monitor your cluster using Prometheus. Here are the steps to install the Prometheus Operator and configure it to scrape metrics from MinIO.

### Install Prometheus Operator

1. **Add the Prometheus community Helm repository:**

   ```shell
   helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
   ```

2. **Update your local Helm chart repository cache:**

   ```shell
   helm repo update
   ```

3. **Install the Prometheus Operator:**

   ```shell
   helm install prometheus-operator prometheus-community/kube-prometheus-stack
   ```

### Accessing Prometheus

1. **Port-forward Prometheus:**

   ```shell
   kubectl port-forward service/prometheus-operated 9090:9090
   ```

2. **Open Prometheus in your browser:**

Navigate to `http://localhost:9090` to access the Prometheus web UI.

### Accessing Grafana (Installed with Prometheus Operator)

1. **Port-forward Grafana:**

   ```shell
   kubectl port-forward service/prometheus-operator-grafana 3000:80
   ```

2. **Open Grafana in your browser:**

Navigate to `http://localhost:3000` to access the Grafana dashboard. Default login credentials are usually `admin` for both username and password unless configured otherwise.

### Cleanup

To delete the Prometheus Operator and its components from your cluster, use:

```shell
helm uninstall prometheus-operator
```

**Note:** Replace `prometheus-operator` with the release name you used during installation if it was different. Adjust `minio-servicemonitor.yaml` and label selectors based on your environment's configuration.