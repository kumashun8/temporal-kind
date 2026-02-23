CLUSTER_NAME := temporal-kind
NAMESPACE := temporal

.PHONY: cluster-create cluster-delete \
        deploy-postgres deploy-temporal deploy-namespace deploy-all \
        generate-temporal-manifests \
        port-forward-temporal port-forward-ui \
        run-worker run-starter teardown

# --- Cluster ---
cluster-create:
	kind create cluster --name $(CLUSTER_NAME) --config k8s/kind-config.yaml
	kubectl apply -f k8s/namespace.yaml

cluster-delete:
	kind delete cluster --name $(CLUSTER_NAME)

# --- PostgreSQL ---
deploy-postgres:
	kubectl apply -f k8s/postgres/

# --- Temporal Server (from generated manifests) ---
deploy-temporal:
	kubectl apply -R -f k8s/temporal/generated/ -n $(NAMESPACE)

# --- Temporal default namespace ---
deploy-namespace:
	kubectl apply -f k8s/temporal/namespace-setup-job.yaml

# --- Full Deploy ---
deploy-all: deploy-postgres
	@echo "Waiting for PostgreSQL to be ready..."
	kubectl wait --for=condition=ready pod -l app=postgresql \
	  -n $(NAMESPACE) --timeout=120s
	$(MAKE) deploy-temporal
	@echo "Waiting for Temporal schema Job to complete..."
	kubectl wait --for=condition=complete job/temporal-schema-1 \
	  -n $(NAMESPACE) --timeout=180s
	@echo "Waiting for Temporal frontend to be ready..."
	kubectl wait --for=condition=ready pod -l app.kubernetes.io/component=frontend \
	  -n $(NAMESPACE) --timeout=180s
	$(MAKE) deploy-namespace

# --- Helm Template Generation ---
generate-temporal-manifests:
	helm repo add temporalio https://go.temporal.io/helm-charts || true
	helm repo update
	rm -rf k8s/temporal/generated/
	helm template temporal temporalio/temporal \
	  -f k8s/temporal/values-postgresql.yaml \
	  --namespace $(NAMESPACE) \
	  --output-dir k8s/temporal/generated/

# --- Port Forward ---
port-forward-temporal:
	kubectl port-forward -n $(NAMESPACE) svc/temporal-frontend 7233:7233

port-forward-ui:
	kubectl port-forward -n $(NAMESPACE) svc/temporal-web 8080:8080

# --- Go Sample ---
run-worker:
	cd temporal && go run ./worker/

run-starter:
	cd temporal && go run ./starter/

# --- Teardown ---
teardown: cluster-delete
