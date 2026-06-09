.PHONY: help apply verify

help:
	@echo "Lex Imperfecta - Intermediate: Available Commands:"
	@echo "  make apply    Reset workloads, re-apply policies and exceptions"
	@echo "  make verify   Run the verification script"

apply:
	@kubectl delete validatingpolicies --all --ignore-not-found > /dev/null 2>&1; \
	kubectl delete namespacedvalidatingpolicies --all -A --ignore-not-found > /dev/null 2>&1; \
	true
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
