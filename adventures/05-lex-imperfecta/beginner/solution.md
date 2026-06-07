# Lex Imperfecta Beginner Solution

## What was broken

Three admission policies in manifests/policies were misconfigured:

- require-labels was set to Audit instead of blocking violations.
- no-privileged-containers did not evaluate regular containers.
- stamp-travel-permit matched peregrinus workloads but did not mutate labels.

## Fixes applied

### 1) require-labels

Updated validationActions to Deny so pods without republic.rome/gens are rejected at admission.

### 2) no-privileged-containers

Updated the CEL expression to evaluate:

- spec.containers
- spec.initContainers
- spec.ephemeralContainers

Any privileged container type now causes denial.

### 3) stamp-travel-permit

Added an ApplyConfiguration mutation that stamps:

- republic.rome/travel-permit: granted

when republic.rome/traveler equals peregrinus.

## Local policy tests with Kyverno CLI

Ran:

- kyverno apply manifests/policies/require-labels.yaml --resource manifests/pods/missing-labels.yaml
- kyverno apply manifests/policies/no-privileged-containers.yaml --resource manifests/pods/privileged.yaml
- kyverno apply manifests/policies/stamp-travel-permit.yaml --resource manifests/pods/peregrinus.yaml

Observed expected results:

- Missing-label pod failed validation.
- Privileged pod failed validation.
- Peregrinus pod received travel-permit label through mutation.

## Applied to cluster

Ran make apply.

Result:

- Admitted: compliant, peregrinus
- Blocked: missing-labels, privileged, privileged-init-container

## Verification

Ran ./verify.sh and all checks passed:

- 8 of 8 verification checks passed.

## Objective coverage

- Workloads missing republic.rome/gens are blocked.
- Privileged workloads are blocked (including init containers).
- Peregrini receive republic.rome/travel-permit=granted.
- Compliant workloads are admitted and run successfully.
