# Kubernetes

## 1. Install calico on EKS cluster :

> ⚠
> make sure to apply the first 8 terraform files without 10-nodegroup.tf file becuase 
> we want empty eks cluster 

**for setting up the calico CNI 
follow these steps**

### ➡**steps:**
1. delete the aws-node daemon set to disable AWS VPC networking for pods
    ```powershell
    kubectl delete daemonset -n kube-system aws-node
    ```


2. Install the operator
    ```powershell
    kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.28.0/manifests/tigera-operator.yaml
    ```

3. Configure the Calico installation:
    ```powershell
    kubectl create -f - <<EOF
    kind: Installation
    apiVersion: operator.tigera.io/v1
    metadata:
    name: default
    spec:
    kubernetesProvider: EKS
    cni:
        type: Calico
    calicoNetwork:
        bgp: Disabled
    EOF
    ```  

4. Add node-group
    ```powershell
    terraform apply 
    ```
5. Check installation
    ```powershell
    kubectl get pod -n tigera-operator
    ```

6. Verify cluster
    ```powershell
    aws eks --region eu-central-1 update-kubeconfig --name my_eks_cluster --profile default
    ```


## 2. Install calicoctl to manage calico resources :

### ➡**steps:**
1. download calicoctl binary 
    ```powershell
    Invoke-WebRequest -Uri "https://github.com/projectcalico/calico/releases/download/v3.28.0/calicoctl-windows-amd64.exe" -OutFile "calicoctl.exe"
    ``` 
2. verify the plugin works
    ```powershell
    kubectl calico version
    ```
    **output:**
    ![](<images/CALICO.png>)
    
## 3. Enable kubectl to manage Calico APIs

1. Create the following manifest, which will install the API server as a deployment in the calico-apiserver namespace.

    ```powershell
    kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.28.0/manifests/apiserver.yaml
    ```

2. Generate a private key and CA bundle using the following openssl command. This certificate will be used by the main API server to authenticate with the Calico API server.
    > ⚠ Do this step on a linux machine

    ```bash
    openssl req -x509 -nodes -newkey rsa:4096 -keyout apiserver.key -out apiserver.crt -days 365 -subj "/" -addext "subjectAltName = DNS:calico-api.calico-apiserver.svc"
    ```
    **output:**
    ![](<images/CALICO-certificate.png>)

3. Copy the ***apiserver.crt*** and ***apiserver.key*** files to the main machine.

4. Provide the key and certificate to the Calico API server as a Kubernetes secret
    ```powershell
    cd C:\path\to\certifates\ 
    ```
    ```powershell
    kubectl create secret -n calico-apiserver generic calico-apiserver-certs --from-file=apiserver.key --from-file=apiserver.crt
    ```
5. Configure the main API server with the CA bundle.
    ```powershell
    kubectl patch apiservice v3.projectcalico.org -p \
        "{\"spec\": {\"caBundle\": \"$(kubectl get secret -n calico-apiserver calico-apiserver-certs -o go-template='{{ index .data "apiserver.crt" }}')\"}}"
    ```
6. Verify api installation
    ```powershell
    kubectl api-resources | grep '\sprojectcalico.org'
    ```
    output: 
    
kubectl get ippools

## 4. Configure calicoctl to connect to the Kubernetes API datastore

>configure the calicoctl CLI tool for your Kubernetes cluster

### ➡**steps:**

1. create configuration file 
    ```yaml
    apiVersion: projectcalico.org/v3
    kind: CalicoAPIConfig
    metadata:
    spec:
      datastoreType: 'kubernetes'
      kubeconfig: '/path/to/.kube/config'
    ```
    ### **check this:** ###
    #### [calicoctl.cfg](./configuration/calicoctl.cfg) 
    ####        

2. apply the configuration file 
    ```powershell
    calicoctl --config C:\path\to\your\calicoctl.cfg get nodes
    #calicoctl --config C:\Users\HP\Documents\usal\spring 24\fyp\vpc\configuration\calicoctl.cfg get nodes
    ```
## 5. Monitor Calico component metrics   

>Use Prometheus configured for Calico components to get valuable metrics about the health of Calico.

**Overview:**
- Configure Calico to enable the metrics reporting.
- Create the namespace and service account that Prometheus will need.
- Deploy and configure Prometheus.
- View the metrics in the Prometheus dashboard and create a simple graph.
### ➡**steps:**

1. Configure Calico to enable metrics reporting (enable felix metrics)
    ```powershell
    kubectl patch felixconfiguration default --type merge --patch '{"spec":{"prometheusMetricsEnabled": true}}'
    ```
    output: felixconfiguration.projectcalico.org/default patched

    - Creating a service to expose Felix metrics
    ```powershell
    kubectl apply -f - <<EOF
    apiVersion: v1
    kind: Service
    metadata:
      name: felix-metrics-svc
      namespace: calico-system
    spec:
      clusterIP: None
      selector:
        k8s-app: calico-node
      ports:
      - port: 9091
        targetPort: 9091
    EOF
    ```
    - Typha Configuration
    ```powershell
    kubectl patch installation default --type=merge -p '{"spec": {"typhaMetricsPort":9093}}'
    ```
    output: installation.operator.tigera.io/default patched

    - Creating a service to expose Typha metrics
    ```powershell
    kubectl apply -f - <<EOF
    apiVersion: v1
    kind: Service
    metadata:
      name: typha-metrics-svc
      namespace: calico-system
    spec:
      clusterIP: None
      selector:
        k8s-app: calico-typha
      ports:
      - port: 9093
        targetPort: 9093
    EOF
    ```
    - kube-controllers configuration
    (verify):
    ```powershell
    kubectl get svc -n calico-system
    ```
    output: calico-kube-controllers-metrics   ClusterIP   10.43.77.57  <'none'>        9094/TCP   39d

2. Cluster preparation
    - namespace creation
    ```powershell
    kubectl create -f -<<EOF
    apiVersion: v1
    kind: Namespace
    metadata:
      name: calico-monitoring
      labels:
        app:  ns-calico-monitoring
        role: monitoring
    EOF
    ```    
    - Service account creation
    ```powershell
    kubectl apply -f - <<EOF
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRole
    metadata:
      name: calico-prometheus-user
    rules:
    - apiGroups: [""]
      resources:
      - endpoints
      - services
      - pods
      verbs: ["get", "list", "watch"]
    - nonResourceURLs: ["/metrics"]
      verbs: ["get"]
    ---
    apiVersion: v1
    kind: ServiceAccount
    metadata:
      name: calico-prometheus-user
      namespace: calico-monitoring
    ---
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRoleBinding
    metadata:
      name: calico-prometheus-user
    roleRef:
      apiGroup: rbac.authorization.k8s.io
      kind: ClusterRole
      name: calico-prometheus-user
    subjects:
    - kind: ServiceAccount
      name: calico-prometheus-user
      namespace: calico-monitoring
    EOF
    ```   

3. Install prometheus
    ```powershell
    kubectl apply -f - <<EOF
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: prometheus-config
      namespace: calico-monitoring
    data:
      prometheus.yml: |-
        global:
          scrape_interval:   15s
          external_labels:
            monitor: 'tutorial-monitor'
        scrape_configs:
        - job_name: 'prometheus'
          scrape_interval: 5s
          static_configs:
          - targets: ['localhost:9090']
        - job_name: 'felix_metrics'
          scrape_interval: 5s
          scheme: http
          kubernetes_sd_configs:
          - role: endpoints
          relabel_configs:
          - source_labels: [__meta_kubernetes_service_name]
            regex: felix-metrics-svc
            replacement: $1
            action: keep
        - job_name: 'felix_windows_metrics'
          scrape_interval: 5s
          scheme: http
          kubernetes_sd_configs:
          - role: endpoints
          relabel_configs:
          - source_labels: [__meta_kubernetes_service_name]
            regex: felix-windows-metrics-svc
            replacement: $1
            action: keep
        - job_name: 'typha_metrics'
          scrape_interval: 5s
          scheme: http
          kubernetes_sd_configs:
          - role: endpoints
          relabel_configs:
          - source_labels: [__meta_kubernetes_service_name]
            regex: typha-metrics-svc
            replacement: $1
            action: keep
          - source_labels: [__meta_kubernetes_pod_container_port_name]
            regex: calico-typha
            action: drop
        - job_name: 'kube_controllers_metrics'
          scrape_interval: 5s
          scheme: http
          kubernetes_sd_configs:
          - role: endpoints
          relabel_configs:
          - source_labels: [__meta_kubernetes_service_name]
            regex: calico-kube-controllers-metrics
            replacement: $1
            action: keep
    EOF
    ```
    - Create Prometheus pod
    ```powershell
    kubectl apply -f - <<EOF
    apiVersion: v1
    kind: Pod
    metadata:
      name: prometheus-pod
      namespace: calico-monitoring
      labels:
        app: prometheus-pod
        role: monitoring
    spec:
      nodeSelector:
        kubernetes.io/os: linux
      serviceAccountName: calico-prometheus-user
      containers:
      - name: prometheus-pod
        image: prom/prometheus
        resources:
          limits:
            memory: "128Mi"
            cpu: "500m"
        volumeMounts:
        - name: config-volume
          mountPath: /etc/prometheus/prometheus.yml
          subPath: prometheus.yml
        ports:
        - containerPort: 9090
      volumes:
      - name: config-volume
        configMap:
          name: prometheus-config
    EOF
    ```
    - check installation
    ```powershell
    kubectl get pods prometheus-pod -n calico-monitoring
    ```
    output:
    ![alt text](/images/image.png)

4. View metrics
    ```powershell
    kubectl port-forward pod/prometheus-pod 9090:9090 -n calico-monitoring
    ```
    
    Verify: Browse to http://localhost:9090 
     
## 6. Visualizing metrics via Grafana

>Use Grafana dashboard to view Calico component metrics.

>create a service to make your prometheus visible to Grafana
 
1. Preparing Prometheus

    ```powershell
    kubectl apply -f - <<EOF
        apiVersion: v1
        kind: Service
        metadata:
          name: prometheus-dashboard-svc
          namespace: calico-monitoring
        spec:
          selector:
            app:  prometheus-pod
            role: monitoring
          ports:
          - port: 9090
            targetPort: 9090
        EOF
    ```

2. Preparing Grafana pod

    >setup a datasource and point it to the prometheus service in the cluster

    - 1. Provisioning datasource
    
    ```powershell
    kubectl apply -f - <<EOF
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: grafana-config
      namespace: calico-monitoring
    data:
      prometheus.yaml: |-
        {
            "apiVersion": 1,
            "datasources": [
                {
                   "access":"proxy",
                    "editable": true,
                    "name": "calico-demo-prometheus",
                    "orgId": 1,
                    "type": "prometheus",
                    "url": "http://prometheus-dashboard-svc.calico-monitoring.svc:9090",
                    "version": 1
                }
            ]
        }
    EOF
    ```
 
    - 2. Provisioning Calico dashboards
    ```powershell
    kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.28.0/manifests/grafana-dashboards.yaml
    ```
    - 3. Creating Grafana pod
    ```powershell
    kubectl apply -f - <<EOF
    apiVersion: v1
    kind: Pod
    metadata:
      name: grafana-pod
      namespace: calico-monitoring
      labels:
        app:  grafana-pod
        role: monitoring
    spec:
      nodeSelector:
        kubernetes.io/os: linux
      containers:
      - name: grafana-pod
        image: grafana/grafana:latest
        resources:
          limits:
            memory: "128Mi"
            cpu: "500m"
        volumeMounts:
        - name: grafana-config-volume
          mountPath: /etc/grafana/provisioning/datasources
        - name: grafana-dashboards-volume
          mountPath: /etc/grafana/provisioning/dashboards
        - name: grafana-storage-volume
          mountPath: /var/lib/grafana
        ports:
        - containerPort: 8000
      volumes:
      - name: grafana-storage-volume
        emptyDir: {}
      - name: grafana-config-volume
        configMap:
          name: grafana-config
      - name: grafana-dashboards-volume
        configMap:
          name: grafana-dashboards-config
    EOF
    ```
    - 4. Accessing Grafana Dashboard
    ```powershell
    kubectl port-forward pod/grafana-pod 8000:8000 -n calico-monitoring
    ```
    check:  access the Grafana web-ui at http://localhost:8000
    