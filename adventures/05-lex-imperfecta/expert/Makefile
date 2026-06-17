.PHONY: help apply verify

help:
	@echo "Lex Imperfecta - Expert: Available Commands:"
	@echo "  make apply    Reload Falco rules, reset workloads, re-apply policies and exceptions"
	@echo "  make verify   Run the verification script"

apply:
	@echo "Reloading Falco rules..."
	@helm upgrade falco falcosecurity/falco \
		--namespace falco \
		--reuse-values \
		--set-file 'customRules.praetorian-guard\.yaml=./falco-rules.yaml' \
		--wait > /dev/null
	@echo "  praetorian-guard.yaml"
	@echo ""
	@echo "Applying Policies:"; \
	for f in manifests/policies/*.yaml; do \
		name=$$(grep '^  name:' "$$f" | head -1 | awk '{print $$2}'); \
		out=$$(kubectl apply -f "$$f" 2>&1); rc=$$?; \
		if [ $$rc -ne 0 ]; then \
			echo ""; \
			echo "$$out"; \
			exit 1; \
		fi; \
		echo "  $$name"; \
	done; \
	echo ""
	@echo "Applying Exceptions:"; \
	for f in manifests/exceptions/*.yaml; do \
		name=$$(grep '^  name:' "$$f" | head -1 | awk '{print $$2}'); \
		out=$$(kubectl apply -f "$$f" 2>&1); rc=$$?; \
		if [ $$rc -ne 0 ]; then \
			echo ""; \
			echo "$$out"; \
			exit 1; \
		fi; \
		echo "  $$name"; \
	done; \
	echo ""
	@echo "Applying Secrets:"; \
	for f in manifests/secrets/*.yaml; do \
		name=$$(grep '^  name:' "$$f" | head -1 | awk '{print $$2}'); \
		out=$$(kubectl apply -f "$$f" 2>&1); rc=$$?; \
		if [ $$rc -ne 0 ]; then \
			echo ""; \
			echo "$$out"; \
			exit 1; \
		fi; \
		echo "  $$name"; \
	done; \
	echo ""
	@echo "Deploying Workloads..."
	@for ns in gallia hispania aegyptus britannia castra; do \
		kubectl delete pods --all -n $$ns --ignore-not-found --grace-period=0 --force \
			> /dev/null 2>&1 & \
	done; \
	wait
	@kubectl apply -f manifests/workloads/ 2>&1 || true
	@echo ""
	@echo "Blocked workloads above mean a policy is enforcing. Run 'make verify' to check your progress."

verify:
	@./verify.sh
