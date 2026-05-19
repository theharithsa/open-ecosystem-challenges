# 🧪 Adventure 04: Blind by Design

Three levels of OpenFeature with **flagd** as the provider, in a Java + Spring Boot service. Wire the SDK against a flagd sidecar (Beginner), layer evaluation context to target by cohort (Intermediate), then instrument flag evaluations with OpenTelemetry and roll back a misbehaving fractional rollout (Expert) — all without redeploying.

The entire **infrastructure is pre-provisioned in your Codespace** — no local setup required.

## 🪐 The Backstory

The **Aletheia Institute** is running a multi-phase vision-enhancement trial. The **lab** is a Spring Boot service whose one job is to record the **`vision_state`** of every subject who walks through the protocol — `blurry`, `sharp`, `enhanced`, or `clouded` — because subjects don't all arrive with the same biology, the same dose adherence, or the same trial-jurisdiction baseline. The flag definitions that drive those readings live in `flags.json`, watched by a **flagd** sidecar; the **OpenFeature** SDK is supposed to call that sidecar on every evaluation.

It hasn't been. For the past **eight months**, every subject through the door has been recorded as `"untreated"` — the integration was never finished, and the lab director assumed the system was reading the chart. Worse, **eight weeks ago** the Institute opened its flagship Phase 3 trial: a new amplifier variant rolled out fractionally to a cohort by a targeting rule in `flags.json`. **Four adverse-event reports** have since been filed, each one a subject whose `vision_state` at discharge was worse than at enrollment.

The monitoring is dark — not by accident, but because no one ever turned the lights on. Your mission across three levels: **stand up the lab** so it reads the chart, **read the chart by cohort** so outcomes can be tracked, then **turn on the lights and roll back the Phase 3 variant** before the director signs off on the next enrollment batch.

## 🧠 What you'll be using

OpenFeature is a vendor-neutral standard for feature flags. The reference cloud-native implementation is **flagd** — it serves flag definitions from a JSON file, locally or remotely, and the OpenFeature SDK in your application calls it on every evaluation.

In this adventure, the lab uses OpenFeature exactly the way a real engineering team would: a Spring Boot service holds the SDK client, flagd holds the flag definitions, and the targeting rules in `flags.json` decide what reading every subject ends up with. By the end, you'll have wired the SDK in from scratch, learned to record outcomes by cohort, and rolled back a misbehaving Phase 3 trial without redeploying.

## 🏆 Rewards

Adventure 04 is the **first adventure with rewards**. To be eligible, you must complete **all three levels** before the deadline: **Tuesday, 26 May 2026 at 23:59 CET**.

- 🥇 **1st place:** a 50% voucher for a Linux Foundation certification

Additionally, the **top 3** finishers each receive a **Credly badge** to showcase the achievement.

> ℹ️ Ranking is determined by total points across all three levels. Points per level are awarded by submission order within the active week (100 for the first valid solution, 95 for the second, and so on; late submissions still earn 60). See the [points & ranking rules](https://community.open-ecosystem.com/t/about-the-challenges-category/16) for the full breakdown.

## 🎮 Choose Your Level

Each level is a standalone challenge with its own Codespace, building on the story while staying technically independent.

### 🟢 Beginner: Stand up the lab

- **Status:** ✅ Ready to Play
- **Topics:** OpenFeature Java SDK, flagd as a sidecar (`Resolver.RPC`), Spring Boot

Wire OpenFeature into a Spring Boot service so the lab's `vision_state` reading is resolved by a flagd sidecar against a `flags.json` instead of a hard-coded literal.

[**Start the Beginner Challenge**](beginner.md){ .md-button .md-button--primary }

### 🟡 Intermediate: Outcome by cohort

- **Status:** ✅ Ready to Play
- **Topics:** OpenFeature targeting, transaction context, hooks, Spring `HandlerInterceptor`

Add request-scoped context, a global runtime context, an invocation context at the call site, and an audit hook so the lab records the right reading per subject cohort.

[**Start the Intermediate Challenge**](intermediate.md){ .md-button .md-button--primary }

### 🔴 Expert: Phase 3 — read the chart

- **Status:** 🚧 Coming Soon
- **Topics:** OpenTelemetry traces + metrics, custom hooks, Grafana LGTM, fractional rollout, OpenFeature OTel hooks

Finish wiring OpenTelemetry through to the Grafana LGTM stack, write a `ContextSpanHook` that puts the merged eval context onto Tempo spans, find the misbehaving Phase 3 amplifier in the dashboard, and roll it back without redeploying.
