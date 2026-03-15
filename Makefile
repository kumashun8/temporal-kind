CLUSTER_NAME := temporal-kind
NAMESPACE := temporal

.PHONY: cluster-create cluster-delete \
        install-argocd deploy-apps deploy-namespace deploy-all \
        port-forward-argocd port-forward-temporal port-forward-ui \
        port-forward-grafana port-forward-prometheus \
        argocd-password \
        run-worker run-starter teardown

# --- Cluster ---
cluster-create:
	kind create cluster --name $(CLUSTER_NAME) --config k8s/kind-config.yaml

cluster-delete:
	kind delete cluster --name $(CLUSTER_NAME)

# --- Argo CD ---
install-argocd:
	kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
	kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml --server-side --force-conflicts
	@echo "Waiting for Argo CD server to be ready..."
	kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=argocd-server \
	  -n argocd --timeout=300s

# --- Deploy Applications ---
deploy-apps:
	kubectl apply -f k8s/argocd/postgresql.yaml
	@echo "Waiting for PostgreSQL Application to be Healthy..."
	@while true; do \
	  HEALTH=$$(kubectl get application postgresql -n argocd -o jsonpath='{.status.health.status}' 2>/dev/null); \
	  SYNC=$$(kubectl get application postgresql -n argocd -o jsonpath='{.status.sync.status}' 2>/dev/null); \
	  if [ "$$HEALTH" = "Healthy" ] && [ "$$SYNC" = "Synced" ]; then break; fi; \
	  echo "  PostgreSQL: health=$$HEALTH sync=$$SYNC"; \
	  sleep 5; \
	done
	@echo "PostgreSQL Application is Healthy."
	kubectl apply -f k8s/argocd/temporal.yaml
	@echo "Waiting for Temporal Application to be Healthy..."
	@while true; do \
	  HEALTH=$$(kubectl get application temporal -n argocd -o jsonpath='{.status.health.status}' 2>/dev/null); \
	  SYNC=$$(kubectl get application temporal -n argocd -o jsonpath='{.status.sync.status}' 2>/dev/null); \
	  if [ "$$HEALTH" = "Healthy" ] && [ "$$SYNC" = "Synced" ]; then break; fi; \
	  echo "  Temporal: health=$$HEALTH sync=$$SYNC"; \
	  sleep 10; \
	done
	@echo "Temporal Application is Healthy."

# --- Temporal default namespace ---
deploy-namespace:
	kubectl apply -f k8s/temporal/namespace-setup-job.yaml

# --- Full Deploy ---
deploy-all: install-argocd deploy-apps
	@echo "Waiting for Temporal frontend to be ready..."
	kubectl wait --for=condition=ready pod -l app.kubernetes.io/component=frontend \
	  -n $(NAMESPACE) --timeout=300s
	$(MAKE) deploy-namespace

# --- Port Forward ---
port-forward-argocd:
	kubectl port-forward -n argocd svc/argocd-server 8443:443

port-forward-temporal:
	kubectl port-forward -n $(NAMESPACE) svc/temporal-frontend 7233:7233

port-forward-ui:
	kubectl port-forward -n $(NAMESPACE) svc/temporal-web 8080:8080

port-forward-grafana:
	kubectl port-forward -n $(NAMESPACE) svc/temporal-grafana 3000:80

port-forward-prometheus:
	kubectl port-forward -n $(NAMESPACE) svc/temporal-prometheus-server 9090:80

# --- Argo CD Admin Password ---
argocd-password:
	@kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d && echo

# --- Go Sample ---
run-worker:
	cd temporal && go run ./worker/

run-starter:
	cd temporal && go run ./starter/

# --- Teardown ---
teardown: cluster-delete
