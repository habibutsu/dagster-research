SHELL:=bash
NAMESPACE:=dagster
REVISION:=$(shell git describe --always)
REGISTRY:=$(shell minikube ip):5000


ifneq (,$(shell which paplay))
ifneq (,$(wildcard /usr/share/sounds/freedesktop/stereo/complete.oga))
IS_SOUND:=true
endif
endif

ifdef IS_SOUND
define sound_complete =
	paplay /usr/share/sounds/freedesktop/stereo/complete.oga
endef
else
define sound_complete =
	echo "Complete"
endef
endif

test-sound:
	$(call sound_complete)

docker-build:
	eval $$(minikube docker-env) && \
	docker build -t pipelines:latest . && \
	docker tag pipelines:latest $(shell minikube ip):5000/pipelines:${REVISION} && \
	docker push ${REGISTRY}/pipelines:${REVISION}
	$(call sound_complete)

helm-init:
	helm repo add dagster https://dagster-io.github.io/helm
	helm repo add minio https://charts.min.io/
	helm repo update

secrets:
	kubectl create namespace ${NAMESPACE} \
		--dry-run=client -o yaml | kubectl apply -f -
	kubectl create secret generic \
		dagster-aws-access-key-id --from-literal=AWS_ACCESS_KEY_ID=root -n ${NAMESPACE} \
		--dry-run=client -o yaml | kubectl apply -f -
	kubectl create secret generic \
		dagster-aws-secret-access-key --from-literal=AWS_SECRET_ACCESS_KEY=pass1234 -n ${NAMESPACE} \
		--dry-run=client -o yaml | kubectl apply -f -

purge:
	kubectl delete pod --all -n ${NAMESPACE}
	kubectl delete jobs.batch --all -n ${NAMESPACE}
	kubectl delete pvc --all -n ${NAMESPACE}
	kubectl delete pv --all -n ${NAMESPACE}
	kubectl delete namespaces ${NAMESPACE}

apply:
	export REVISION=${REVISION} && \
		export REGISTRY=${REGISTRY} && \
		helmfile apply

destroy:
	helmfile destroy

forward-minio:
	kubectl port-forward service/minio-console --address 0.0.0.0 9001:9001 -n ${NAMESPACE}

forward-dagit:
	kubectl port-forward service/dagster-dagit --address 0.0.0.0 8080:80 -n ${NAMESPACE}

forward-rabbitmq:
	kubectl port-forward service/dagster-rabbitmq --address 0.0.0.0 15672:15672 -n ${NAMESPACE}

cluster-init:
	minikube start --insecure-registry "10.0.0.0/24,192.168.39.0/24" --addons=registry

deploy: docker-build secrets apply