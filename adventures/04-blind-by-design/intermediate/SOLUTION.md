# Adventure 04: Blind by Design — Intermediate Solution

## Problem

The lab was returning `"blurry"` (the default variant) for every request because the evaluation context was always empty. The OpenFeature flagd targeting rules rely on three attributes — `species`, `country`, and `dose` — but nothing was populating them.

## What Was Added / Changed

### 1. `SpeciesInterceptor.java` (new file)

A Spring `HandlerInterceptor` that bridges the HTTP request into the OpenFeature **transaction context**.

- **Static initializer** — registers a `ThreadLocalTransactionContextPropagator` on the `OpenFeatureAPI` singleton once when the class loads. Without this, the SDK has no mechanism to carry per-request data and the transaction context is silently ignored.
- **`preHandle`** — reads `?species=` from the incoming request and writes it into the transaction context. If the parameter is absent, an empty context is written (prevents stale data from a previous request on the same thread).
- **`afterCompletion`** — clears the transaction context. Servlet threads are pooled; failing to clear here would cause the previous request's `species` to leak into the next request that lands on the same thread.

### 2. `AuditHook.java` (new file)

Implements `Hook<String>` — OpenFeature's interceptor for flag evaluations.

- **`after`** — fires after every successful evaluation. Reads the merged evaluation context from `HookContext.getCtx()` and logs an `[AUDIT]` line with `flag`, `variant`, `reason`, and the values of `species`, `country`, and `dose`.
  - `clouded` variant → `WARN` (with "improper dosing or off-protocol cohort, follow-up required" suffix).
  - All other variants → `INFO`.
- **`error`** — logs failed evaluations at `ERROR` so they are never silently swallowed.
- Uses a **fixed allowlist** (`List.of("species", "country", "dose")`) rather than dumping the whole context — a deliberate discipline so that sensitive attributes added later don't accidentally appear in audit logs.

### 3. `OpenFeatureConfig.java` (updated)

Now also implements `WebMvcConfigurer` so it can wire everything into Spring in one place.

- **`addInterceptors`** — registers the `SpeciesInterceptor` with Spring MVC.
- **`initProvider` (`@PostConstruct`)** — three additions on top of the existing flagd provider setup:
  1. Reads `COUNTRY` from the environment (`System.getenv("COUNTRY")`) and sets it as the **global evaluation context**. This is merged into every flag evaluation automatically, regardless of which request triggered it.
  2. Registers `AuditHook` globally via `api.addHooks(...)` so it fires for every evaluation the app performs.

### 4. `Trial.java` (updated)

The REST controller now participates in context building at the **invocation layer**.

- Accepts an optional `?dose=` query parameter.
- If `dose` is not supplied, picks randomly from `["standard", "standard", "standard", "underdose", "overdose"]` — weighted toward `standard` to simulate the occasional lab error.
- Passes `dose` as the **invocation context** in the third argument to `client.getStringDetails("vision_state", "untreated", invocationCtx)`. This context is per-call and not stored anywhere.

## Context Layers and Precedence

OpenFeature merges three context layers before handing attributes to flagd. In descending priority:

| Layer       | Set by                     | Contains     |
|-------------|----------------------------|--------------|
| Invocation  | `Trial.observeSubject`     | `dose`       |
| Transaction | `SpeciesInterceptor`       | `species`    |
| Global      | `OpenFeatureConfig`        | `country`    |

Higher layers win on key conflicts. The `flags.json` targeting evaluates `species` first, so a `zyklop` subject always gets `"enhanced"` even when `dose=underdose`.

## How to Run

```bash
# Germany cohort (country=de → "sharp" for standard subjects)
./run-germany.sh

# Austria cohort (country=at → no country branch fires → "blurry" for standard subjects)
./run-austria.sh
```

## Manual Verification

```bash
# species wins regardless of dose or country
curl -s 'http://localhost:8080/?species=zyklop' | jq .value          # "enhanced"

# global country context fires (run-germany.sh must be running)
curl -s 'http://localhost:8080/?dose=standard' | jq .value           # "sharp"

# invocation dose fires for non-zyklop subjects
curl -s 'http://localhost:8080/?dose=underdose' | jq .value          # "clouded"

# species takes precedence over improper dose
curl -s 'http://localhost:8080/?species=zyklop&dose=underdose' | jq .value  # "enhanced"

# inspect audit trail
grep '\[AUDIT\]' app.log | head
```

## Automated Verification

```bash
./verify.sh
```
