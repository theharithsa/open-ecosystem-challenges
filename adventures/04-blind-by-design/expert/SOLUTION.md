# Adventure 04: Blind by Design — Expert Solution

## Overview

Four changes wire the full observability pipeline: metrics exporter, MetricsHook, ContextSpanHook, and the bad-rollout rollback.

---

## Changes Made

### 1. `otel.properties` — Enable metrics exporter

```diff
-otel.metrics.exporter=none
+otel.metrics.exporter=otlp
```

The OTel Java Agent had the metrics pipeline disabled. Flipping to `otlp` causes all meter recordings to flow into the LGTM stack. The export interval was already set to `10000` ms (10 s) so the Grafana dashboard refreshes quickly after traffic starts.

---

### 2. `OpenFeatureConfig.java` — Register MetricsHook and ContextSpanHook

```java
api.addHooks(new MetricsHook(GlobalOpenTelemetry.get()));
api.addHooks(new ContextSpanHook());
```

`MetricsHook` emits `feature_flag_evaluation_requests_total` (and three companion counters) for every flag evaluation. It needs an `OpenTelemetry` handle; `GlobalOpenTelemetry.get()` returns the instance installed by the agent before `main()` ran.

`ContextSpanHook` (see below) enriches spans with the evaluation context that drove each decision.

---

### 3. `ContextSpanHook.java` — New hook (authored from scratch)

Copies a fixed allowlist of evaluation-context keys onto the active OTel span:

```java
@Override
public Optional<EvaluationContext> before(HookContext ctx, Map hints) {
    Span span = Span.current();
    EvaluationContext ec = ctx.getCtx();
    if (ec != null) {
        for (String key : ALLOWLIST) {          // List.of("species", "country", "dose")
            Value v = ec.getValue(key);
            if (v != null && !v.isNull()) {
                span.setAttribute("feature_flag.context." + key, v.asString());
            }
        }
    }
    return Optional.empty();
}
```

This makes `feature_flag.context.dose=underdose` searchable in Tempo right next to `feature_flag.variant`, closing the loop between *what* happened and *why*.

**Why an allowlist?** The merged evaluation context routinely carries `targetingKey` (a stable user id that joins to PII in real apps). Span attributes are retained for days in Tempo; redacting after the fact is hard. The allowlist matches the discipline `AuditHook` already follows.

---

### 4. `flags.json` — Roll back bad rollout and enable loadgen

**`vision_amplifier_v2`** had its fractional rollout set to 100 % `on`, causing ~10 % 5xx errors and elevated latency. Rolled back:

```diff
-["off", 0],
-["on", 100]
+["off", 100],
+["on", 0]
```

**`loadgen_active`** flipped to `"on"` so the k6 loadgen drives continuous traffic, populating Prometheus counters and Tempo spans.

```diff
-"defaultVariant": "off"
+"defaultVariant": "on"
```

---

## Verification Results

```
✅ PASSED: All 8 checks passed

  ✓ App reachable at localhost:8080
  ✓ flagd reachable
  ✓ Grafana LGTM stack reachable
  ✓ vision_amplifier_v2 evaluates to false (rollout rolled back)
  ✓ feature_flag_evaluation_requests_total is non-zero (sum=4734)
  ✓ Tempo has 20+ traces for service 'fun-with-flags-java-spring'
  ✓ Tempo has spans tagged feature_flag.context.dose=underdose
  ✓ HTTP 5xx rate is 0.00% (< 1%)
```
