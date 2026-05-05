# Open Ecosystem Challenges

Welcome to Open Ecosystem Challenges! 🚀

These are **hands-on, recurring prompts** designed to help you practice **Cloud Native, OpenTelemetry, AI/ML**, and
other **open source skills**.

Each challenge runs in a **pre-provisioned environment**, so you can focus on solving real problems, not setup
headaches.

**What makes these challenges special:**

- 🎯 **Skill-focused** - Target specific technologies with clear objectives
- 📖 **Story-driven** - Learn through engaging narratives
- 🚀 **Zero setup** - Run in GitHub Codespaces, pre-configured and ready
- ✅ **Two-step verification** - [Smoke tests and GitHub Actions](verification.md) validate your solution
- 🎓 **Three levels** - Beginner, Intermediate, and Expert for each adventure

## 🗺️ Available Adventures

Browse the available adventures and pick one that interests you:

### May 2026: [Blind by Design](04-blind-by-design/index.md)

**Story:** The Aletheia Institute's lab has been recording every subject as "untreated" for eight months — the OpenFeature integration was never finished. Wire the SDK, read the chart by cohort, and roll back a misbehaving Phase 3 trial before the next enrollment batch is signed off.

| Level           | Name                                               | 🧠 Key Learnings                                                                                                                                                                                                                                          |
|-----------------|----------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| 🟢 Beginner     | [Stand up the lab](04-blind-by-design/beginner.md) | <ul><li>Wire the [OpenFeature](https://openfeature.dev/) Java SDK into a Spring Boot service</li><li>Configure [flagd](https://flagd.dev/) as a gRPC sidecar provider</li><li>Hot-reload flag definitions from `flags.json` without redeploying</li></ul> |
| 🟡 Intermediate | Outcome by cohort                                  | <ul><li>OpenFeature targeting rules and evaluation context</li><li>Transaction context and Spring `HandlerInterceptor`</li><li>Audit hooks for per-cohort outcome tracking</li></ul>                                                                      |
| 🔴 Expert       | Read the chart                                     | <ul><li>OpenTelemetry traces and metrics with OpenFeature hooks</li><li>Custom `ContextSpanHook` for eval context on Tempo spans</li><li>Fractional rollout detection and rollback via [Grafana LGTM](https://grafana.com/)</li></ul>                     |

### February 2026: [The AI Observatory](03-the-ai-observatory/index.md)

**Story:** Investigate a mysterious bandwidth anomaly at a remote research station by instrumenting its AI system with OpenTelemetry.

| Level           | Name                                                          | 🧠 Key Learnings                                                                                                                                                                                                                                                                  |
|-----------------|---------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| 🟢 Beginner     | [Calibrating the Lens](03-the-ai-observatory/beginner.md)     | <ul><li>Instrument Python AI apps with [OpenLLMetry](https://github.com/traceloop/openllmetry)</li><li>Analyze traces in [Jaeger](https://www.jaegertracing.io/)</li></ul>                                                                                                        |
| 🟡 Intermediate | [The Distracted Pilot](03-the-ai-observatory/intermediate.md) | <ul><li>Instrument RAG pipelines with [OpenLLMetry](https://github.com/traceloop/openllmetry)</li><li>Create custom [OpenTelemetry](https://opentelemetry.io/) metrics in Python</li><li>Write PromQL queries & recording rules in [Prometheus](https://prometheus.io/)</li></ul> |
| 🔴 Expert       | [The Noise Filter](03-the-ai-observatory/expert.md)           | <ul><li>OpenTelemetry GenAI semantic conventions</li><li>Tail sampling in the [OTel Collector](https://opentelemetry.io/docs/collector/)</li></ul>                                                                                                                                |

### January 2026: [Building CloudHaven](02-building-cloudhaven/index.md)

**Story:** Join the Infrastructure Guild and modernize CloudHaven's infrastructure from manual provisioning to a
self-service platform using Infrastructure as Code.

| Level           | Name                   | 🧠 Key Learnings                                                                                                                                           |
|-----------------|------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------|
| 🟢 Beginner     | The Foundation Stones  | <ul><li>Infrastructure as Code with OpenTofu</li><li>Remote state management with GCS backend</li><li>Dynamic & conditional resources</li></ul>            |
| 🟡 Intermediate | The Modular Metropolis | <ul><li>OpenTofu module testing with `tofu test`</li><li>Test-Driven Development (TDD) workflow</li><li>Input validation with regex</li></ul>              |
| 🔴 Expert       | The Guardian Protocols | <ul><li>GitHub Actions for drift detection and plan/apply</li><li>Integration tests with service containers</li><li>Security scanning with Trivy</li></ul> |

### December 2025: [Echoes Lost in Orbit](01-echoes-lost-in-orbit/index.md)

**Story:** Restore interstellar communications by fixing broken GitOps setups, progressive delivery systems, and
observability pipelines across three galactic missions.

| Level           | Name                              | 🧠 Key Learnings                                                                                                                                                                                                                                                     |
|-----------------|-----------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| 🟢 Beginner     | Broken Echoes                     | <ul><li>Debug GitOps flows with Argo CD</li><li>ApplicationSet templating & pitfalls</li><li>Environment isolation & namespaces</li><li>Sync policies: automated, prune & self-heal</li></ul>                                                                        |
| 🟡 Intermediate | The Silent Canary                 | <ul><li>Progressive delivery with Argo Rollouts</li><li>Canary deployments & automated analysis</li><li>Write PromQL queries for health validation</li><li>Kube-state-metrics for deployment decisions</li></ul>                                                     |
| 🔴 Expert       | Hyperspace Operations & Transport | <ul><li>Configure OpenTelemetry Collector pipelines</li><li>Spanmetrics connector (traces → metrics)</li><li>Detect "idle canaries" with traffic validation</li><li>Distributed tracing with Jaeger</li><li>Trace-derived metrics for progressive delivery</li></ul> |

More adventures coming soon!

## 🎮 How It Works

**Each level is independent** - start anywhere, complete in any order. Levels share a connected story but have their
own:

- Codespace configuration
- Documentation and guides
- Validation tests

**Levels:**

- 🟢 **Beginner**: New to the technology? Start here to learn the basics
- 🟡 **Intermediate**: Comfortable with fundamentals? Practice advanced patterns
- 🔴 **Expert**: Want a real challenge? Tackle complex real-world scenarios

## ✅ How to Verify Your Solution

Each challenge includes a two-step verification process:

1. **Smoke Test** - Run locally in your Codespace for quick validation
2. **GitHub Actions Workflow** - Comprehensive verification you manually trigger after pushing

> 📖 **Learn more:** Read the complete [Verification Guide](verification.md) for detailed instructions on both steps.

## ❓ FAQ

**Do I need to complete levels in order?**  
No! Each level is independent. Start wherever you feel comfortable.

**Can I use these for team training?**  
Absolutely! Perfect for upskilling, onboarding, internal training, and hackathons.

**Are there costs?**  
GitHub Codespaces offers free hours per month - usually sufficient for individual use.
Check [GitHub's pricing](https://github.com/features/codespaces) for details.

**Need help?**  
Check adventure-specific docs, [open an issue](https://github.com/dynatrace-oss/open-ecosystem-challenges/issues), or
start a [discussion](https://community.open-ecosystem.com/c/challenges).

## 🚀 Ready to Start?

[Choose your adventure](#available-adventures) and begin learning!
