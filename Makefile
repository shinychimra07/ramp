#!/usr/bin/env make
.PHONY: run_webapp install_kubectl install_kind create_docker_registry connect_registry_to_kind connect_registry_to_kind_network create_kind_cluster create_kind_cluster_with_registry push_docker_image_to_local_repo apply_deployment apply_ingress configure_contour_ingress  helm_chart

run_webapp:
	docker build -t simple-web-app-img . && \
		docker run --rm -d -p 8000:8000 -d --name simple-web-app-container simple-web-app-img

install_kubectl:
	brew install kubectl || true;

install_kind:
	curl -o ./kind https://github.com/kubernetes-sigs/kind/releases/download/v0.17.0/kind-darwin-amd64

create_docker_registry:
	if ! docker ps | grep -q 'local-registry'; \
	then docker run -d -p 5000:5000 --name local-registry --restart=always registry:2; \
	else echo "---> local-registry is already running. There's nothing to do here."; \
	fi

connect_registry_to_kind_network:
	docker network connect kind local-registry || true;

create_kind_cluster: install_kind install_kubectl
	kind create cluster --image=kindest/node:v1.21.12 --config ./kind_config.yaml || true \
	kubectl get nodes 

connect_registry_to_kind: connect_registry_to_kind_network
	kubectl apply -f ./kind_configmap.yaml;

create_kind_cluster_with_registry:
	$(MAKE) create_kind_cluster && $(MAKE) connect_registry_to_kind

push_docker_image_registry:
	docker tag simple-web-app-img shinychimra07/simple-web-app-img && \
	docker push shinychimra07/simple-web-app-img

apply_deployment:
	kubectl apply -f ./deployment.yaml && \
	kubectl port-forward deployment/simple-web-app 8080:8000 

apply_service:
	kubectl apply -f ./service.yaml && \
	kubectl port-forward service/simple-web-app 8000:8000 

apply_ingress:
	kubectl apply -f ./ingress.yaml && \
	kubectl patch ingress simple-web-app -p '{"spec":{"ingressClassName": "contour"}}'


configure_contour_ingress:
	kubectl apply -f https://projectcontour.io/quickstart/contour.yaml 

helm_chart:
	helm upgrade --atomic --install simple-web-app ./chart