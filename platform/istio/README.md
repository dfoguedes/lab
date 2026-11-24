# Practical Guide: Install Istio and Perform Canary Deployment with Bookinfo

This guide walks you through installing Istio in a local Kubernetes cluster (using K3d) and implementing a **Canary deployment** using the Bookinfo sample.

---

## Requirements

* `kubectl`
* `k3d` or `kind` (to create a local cluster)
* `istioctl`

---

## Step 1: Create a local cluster with K3d

```bash
k3d cluster create istio-cluster --agents 1 --port 9080:80@loadbalancer
```

---

## Step 2: Install Istio (default profile)

```bash
istioctl install --set profile=demo -y
```

Verify components:

```bash
kubectl get pods -n istio-system
```

You should see `istiod`, `istio-ingressgateway`, and `istio-egressgateway` in `Running` state.

---

## Step 3: Enable Automatic Sidecar Injection

Create the namespace and enable injection:

```bash
kubectl create namespace my-istio-ns
kubectl label namespace my-istio-ns istio-injection=enabled
```

---

## Step 4: Deploy Bookinfo Sample

```bash
kubectl apply -n my-istio-ns -f https://raw.githubusercontent.com/istio/istio/release-1.20/samples/bookinfo/platform/kube/bookinfo.yaml
```

Check that pods are running:

```bash
kubectl get pods -n my-istio-ns
```

---

## Step 5: Expose `productpage`

```bash
kubectl port-forward svc/productpage -n my-istio-ns 9080:9080
```

Access: [http://localhost:9080/productpage](http://localhost:9080/productpage)

---

## Step 6: Canary Deployment for `reviews`

### a) Check `reviews` pods

```bash
kubectl get pods -n my-istio-ns -l app=reviews --show-labels
```

### b) Create DestinationRule

```yaml
apiVersion: networking.istio.io/v1beta1
kind: DestinationRule
metadata:
  name: reviews
  namespace: my-istio-ns
spec:
  host: reviews
  subsets:
  - name: v1
    labels:
      version: v1
  - name: v2
    labels:
      version: v2
```

Apply:

```bash
kubectl apply -f destinationrule-reviews.yaml
```

### c) Create VirtualService with 90% traffic to v1, 10% to v2

```yaml
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: reviews
  namespace: my-istio-ns
spec:
  hosts:
  - reviews
  http:
  - route:
    - destination:
        host: reviews
        subset: v1
      weight: 90
    - destination:
        host: reviews
        subset: v2
      weight: 10
```

Apply:

```bash
kubectl apply -f virtualservice-reviews.yaml
```

---

## Step 7: Test Visually

```bash
kubectl port-forward svc/productpage -n my-istio-ns 9080:9080
```

Access [http://localhost:9080/productpage](http://localhost:9080/productpage) and refresh multiple times:

* If **you see stars**: you're hitting `reviews:v2`
* If **no stars appear**: you're hitting `reviews:v1`

---

## Step 8: Check with Logs

```bash
kubectl logs -n my-istio-ns -l app=reviews -c reviews --tail=20 --follow
```

Check that both `v1` and `v2` pods are receiving requests.

---

## (Optional) Step 9: Install Kiali for Visualization

```bash
istioctl dashboard kiali
```

Open the dashboard and visualize the traffic graph for the `my-istio-ns` namespace.
