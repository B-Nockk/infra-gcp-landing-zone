# ==============================================================================
# Terraform Commands & Orchestration
# ==============================================================================

ENV_DIR := terraform/environments/$(ENV)
BACKEND_CONFIG := platform_tooling/config/backend-$(ENV).hcl

.PHONY: init plan apply destroy fmt validate clean bootstrap auth

# 1. Bootstrap: Auto-creates the GCS bucket if it doesn't exist (Skipped for 'local')
bootstrap:
	@if [ "$(ENV)" != "local" ]; then \
		echo "🪣 Bootstrapping state backend for environment: $(ENV)"; \
		bash platform_tooling/scripts/bootstrap-state.sh $(ENV); \
	else \
		echo "ℹ️  Environment is 'local'. Skipping GCS bootstrap."; \
	fi

# 2. Auth: Runs the pluggable auth wrapper before any state-changing commands
auth:
	@bash platform_tooling/scripts/auth-wrapper.sh

# 3. Init: Depends on bootstrap
init: bootstrap
	@echo "🔧 Initializing Terraform for $(ENV)..."
	@if [ "$(ENV)" = "local" ]; then \
		cd $(ENV_DIR) && $(TF) init; \
	else \
		cd $(ENV_DIR) && $(TF) init -backend-config=../../$(BACKEND_CONFIG); \
	fi

# 4. Plan: Depends on auth
plan: auth
	@echo "🗺️  Generating plan for $(ENV)..."
	cd $(ENV_DIR) && $(TF) plan

# 5. Apply: Depends on auth
apply: auth
	@echo "🚀 Applying plan for $(ENV)..."
	cd $(ENV_DIR) && $(TF) apply

# 6. Destroy
destroy: auth
	@echo "💥 Destroying $(ENV)..."
	cd $(ENV_DIR) && $(TF) destroy

# 7. Utility Targets
fmt:
	$(TF) fmt -recursive terraform/

validate:
	cd $(ENV_DIR) && $(TF) validate

clean:
	find terraform/ -type d -name ".terraform" -prune -exec rm -rf {} +
	find terraform/ -name ".terraform.lock.hcl" -delete
