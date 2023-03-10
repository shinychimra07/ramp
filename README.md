# Simple web app

1. Created a simple web app listening to port 8080
2. Build a container image of the app with docker
    `docker build -t shinychimra07/simple-web-app .`
3. Create kind cluster
    `kind create cluster --config kind.yaml`
    Check cluster info
    `kubectl cluster-info --context kind-simple-app-web-app`
    Check pods are running
    `kubectl get pods -n kube-system`
4. Deploy the built app to kind cluster (with kubectl) - Apply deployment YAML file to the kind cluster
    `kubectl apply -f deployment.yaml`
    check deployment status
    `kubectl get deployments`
    check pods status
    `kubectl get pods` 
5. Deploy K8s service for the app (with kubectl)
    a. A NodePort Service
    `kubectl apply -f deployment.yaml`
    Note:- Minikube/cluster ip did not work and had to use `minikube service go-app-svc-v1 --url` https://github.com/kubernetes/minikube/issues/7344 or `kubectl cluster-info` . Used localhost ip 127.0.01 for testing

    b. TODO: A LoadBalancer Service with cloud provider -https://kubernetes.io/docs/concepts/services-networking/service/#loadbalancer

    c. An Ingress or Route

    Verify the pods and service are ready
    `kubectl get po,svc,ing -l app=simple-web-app`
6. Access the app from browser with kubectl port forwarding
    When it comes to exposing your Kubernetes workload to external traffic, creating ingresses or services such as NodePorts and LoadBalancers are the standard practices. Each of these functions differ in how they allow Pods to be accessed.

    Port forwarding, on the other hand, offers you the opportunity to investigate issues and adjust your applications locally without the need to expose them beforehand.
    `kubectl port-forward <pod_id> 8080:8080`
    Check we are able to access the app using below curl
    `curl http://127.0.0.1:8080/`
7. Deploy an Countour Ingress controller to kind cluster (https://kind.sigs.k8s.io/docs/user/ingress/)
    Add the bitnami chart repository (which contains the Contour chart) by running the following:
    `helm repo add bitnami https://charts.bitnami.com/bitnami`
    Install the Contour chart by running the following:
    `helm install my-release bitnami/contour --namespace projectcontour --create-namespace`
    Verify Contour is ready by running:
    `kubectl get po,svc`
    Apply ingress config in deployment.yaml file
    `kubectl apply -f deployment.yaml`
    ensure the Ingress has an ingress class of contour with the following
    `kubectl patch ingress simple-web-app -p '{"spec":{"ingressClassName": "contour"}}'`
    Test ingress with port forwarding
    `kubectl port-forward service/simple-web-app 8080:8080`
    `curl http://simple-web-app-local:8080/`
8. Access the browser without kubectl port forwarding via ingress controller.
9. Common docker commands
10. Common podman commands
11. Deployment / orchestration with helm
12. Deployment / orchestration with skaffold
13. K8s operators
14. Commands to validate each layer of the K8s layer
15. Gitops / CICD
