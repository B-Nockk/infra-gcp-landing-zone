# ============================== ==============================
# GCP Platform Foundation CLI Orchestrator
# ============================== ==============================
# Usage:
#   make <target> ENV=<environment>

# ============================== ==============================
# Configuration
# ============================== ==============================
TF ?= terraform
ENV ?= dev

# Data-driven targets and flags (No hardcoding in the rules)
REGISTRY_TARGET ?= google_storage_bucket_object.outputs_registry
AUTO_APPROVE_FLAG ?= -auto-approve

ROOT_DIR := $(shell pwd)
PLATFORM_DIR := $(ROOT_DIR)/platform_tooling
SCRIPT_DIR := $(PLATFORM_DIR)/scripts
ENV_DIR := $(ROOT_DIR)/terraform/environments/$(ENV)

# Saved execution plan file
PLAN_FILE := tfplan.binary

export ENV
export TF

# ============================== ==============================
# Help
# ============================== ==============================
.PHONY: help
help:
	@echo ""
	@echo "GCP Platform Foundation CLI"
	@echo ""
	@echo "Usage:"
	@echo "  make <target> ENV=<local|dev|staging|prod>"
	@echo ""
	@echo "Targets:"
	@echo "  bootstrap  Create GCS state bucket and generate backend config"
	@echo "  init       Initialize Terraform (runs bootstrap if needed)"
	@echo "  plan       Generate and show the execution plan"
	@echo "  apply      Apply the execution plan"
	@echo "  destroy    Tear down the environment"
	@echo "  fmt        Format all Terraform files"
	@echo "  validate   Validate Terraform configuration"
	@echo "  clean      Remove .terraform directories and lock files"
	@echo ""

# ============================== ==============================
# Targets
# ============================== ==============================
.PHONY: bootstrap init plan apply destroy publish-outputs deploy fmt validate clean

bootstrap:
	@bash $(SCRIPT_DIR)/bootstrap-state.sh $(ENV)

init: bootstrap
	@bash $(SCRIPT_DIR)/terraform-init.sh $(TF) $(ENV) $(ARGS)

plan:
	@echo "🗺️  Generating execution plan for $(ENV)..."
	@cd $(ENV_DIR) && $(TF) plan -out=$(PLAN_FILE) $(ARGS)

# SMART APPLY: If ARGS are provided (e.g., -target), skip the saved plan file.
# Otherwise, use the safe, saved plan file workflow.
apply:
	@echo "🚀 Applying infrastructure plan for $(ENV)..."
	@if [ -n "$(ARGS)" ]; then \
		echo "🚀 Applying with extra arguments for $(ENV) (skipping saved plan file due to Terraform limitations)..."; \
		cd $(ENV_DIR) && $(TF) apply $(ARGS); \
	else \
		echo "🚀 Applying saved plan for $(ENV)..."; \
		cd $(ENV_DIR) && $(TF) apply $(PLAN_FILE); \
	fi

# Publish outputs to the registry ONLY (Idempotent)
publish-outputs:
	@echo "📤 Publishing outputs to registry for $(ENV)..."
	@cd $(ENV_DIR) && $(TF) apply -target=$(REGISTRY_TARGET) $(AUTO_APPROVE_FLAG)

# The combined command for local dev / manual full deployments
deploy: apply publish-outputs
	@echo "✅ Infrastructure applied and outputs published to registry."

destroy:
	@echo "💥 Destroying $(ENV)..."
	@cd $(ENV_DIR) && $(TF) destroy

fmt:
	@$(TF) fmt -recursive $(ROOT_DIR)/terraform

validate:
	@cd $(ENV_DIR) && $(TF) validate

clean:
	@echo "🧹 Cleaning up Terraform caches and artifacts..."
	@find $(ROOT_DIR)/terraform -type d -name ".terraform" -prune -exec rm -rf {} +
	@find $(ROOT_DIR)/terraform -name ".terraform.lock.hcl" -delete
	@find $(ROOT_DIR)/terraform -name "$(PLAN_FILE)" -delete
	@find $(ROOT_DIR)/platform_tooling/config -name "backend-*.hcl" -delete
