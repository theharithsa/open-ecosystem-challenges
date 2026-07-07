# Adventure Idea: ♿ The Accessibility Nightmare

## Overview

**Theme:** ShopSmart's e-commerce expansion is blocked by ADA lawsuits and strict European Accessibility Act (EAA) fines. As the lead frontend engineer, your mission is to audit the broken site, build an accessible component library, and automate compliance to save the EU launch and protect the company from millions in fines.

**Skills:**

- Audit and remediate critical WCAG 2.2 violations using automated and manual testing tools
- Build and document an accessible component library with proper focus management and ARIA patterns
- Implement automated accessibility gates and performance budgets in CI/CD pipelines to ensure continuous compliance

**Technologies:** axe-core, Lighthouse, Playwright, Pa11y, NVDA, VoiceOver, React, Storybook, GitHub Actions

---

## Levels

### 🟢 Beginner: The Initial Audit

#### Description

Audit the ShopSmart homepage and fix critical WCAG 2.2 violations to pass the initial legal compliance check.

#### Story

The legal notice just landed. The CEO is panicking over the ADA and EAA violations. Your first task is to look at the public-facing homepage, run the automated audits, and fix the glaring issues that are triggering the lawsuit before the regulators escalate.

#### The Problem

The homepage is riddled with basic accessibility failures. It currently scores a 45 on Lighthouse. Interactive elements can't be reached via keyboard, images lack alt text, color contrast fails WCAG standards, and focus states are completely hidden, making it impossible for motor-impaired users to navigate.

#### Objective

- Run Lighthouse and axe-core to identify and interpret the accessibility violations
- Fix color contrast and missing alt text on all homepage assets
- Ensure all interactive elements are keyboard accessible and have visible Focus Appearance (WCAG 2.4.11)
- Achieve a Lighthouse accessibility score of 95+ with zero critical axe-core violations

#### What You'll Learn

- How to interpret automated accessibility reports (Lighthouse, axe-core)
- The fundamentals of WCAG 2.2 perceivable and operable criteria
- How to test and fix basic keyboard navigation and focus states using screen readers

#### Tools & Infrastructure

- **Tools:** Lighthouse, axe DevTools, NVDA/VoiceOver, Browser DevTools
- **Infrastructure:** ShopSmart E-commerce Frontend (React/Next.js)

---

### 🟡 Intermediate: The Component Forge

#### Description

Build and document an accessible component library in Storybook to ensure all future features are built correctly from the start.

#### Story

The homepage is fixed, but the rest of the checkout flow is a disaster. The design team keeps using broken, inaccessible patterns, and developers are reinventing the wheel—and breaking accessibility in the process. You need to build a standardized, accessible component library so the team can stop making the same mistakes.

#### The Problem

The current UI kit lacks focus management, uses incorrect ARIA roles, and has no automated testing. Modals trap focus incorrectly, dropdowns aren't navigable by screen readers, and forms lack proper error announcements. Every time a developer builds a new feature, they introduce new accessibility bugs.

#### Objective

- Build accessible Modal, Dropdown, and Form components in Storybook
- Implement strict focus trapping in modals and correct ARIA live regions for form errors
- Ensure 100% keyboard navigability and correct screen reader announcements for all components
- Write Playwright accessibility tests for each component to prevent future regressions

#### What You'll Learn

- How to implement complex ARIA patterns (dialogs, menus, live regions)
- How to manage focus programmatically and prevent keyboard traps
- How to write automated E2E accessibility tests using Playwright

#### Tools & Infrastructure

- **Tools:** Storybook, Playwright, axe-core, NVDA/VoiceOver
- **Infrastructure:** Component Library Repository, ShopSmart Frontend

---

### 🔴 Expert: The Compliance Engine

#### Description

Integrate automated accessibility gates into the CI/CD pipeline and build a monitoring dashboard to uncover hidden regressions and ensure long-term EAA/ADA compliance.

#### Story

The components are ready, but developers are still bypassing them, and new PRs are introducing regressions. The legal team needs proof of continuous compliance for the EAA audit next week. You must build an automated compliance engine that blocks bad code before it merges, but when you turn it on, it's not catching the issues the lawyers are complaining about. Dig into the pipeline and the production telemetry to find out what's slipping through.

#### The Problem

Two things are broken before compliance can be proven. First, the CI pipeline's accessibility checks are running too early in the build process, before dynamic client-side content is rendered, so they miss critical violations in the checkout flow. Second, even when fixed to run post-render, the pipeline only checks static pages; it doesn't catch regressions in user-specific flows. 

With proper Playwright E2E accessibility tests finally integrated and running against the fully rendered app, the root cause of the legal complaint becomes clear: a third-party payment widget is injecting inaccessible iframes that break the keyboard flow, which static audits missed. You must implement Real User Monitoring (RUM) to catch these dynamic, third-party regressions in production.

#### Objective

- Fix the GitHub Actions pipeline so accessibility checks run against the fully rendered application, not just the static HTML
- Implement an accessibility performance budget that fails the build if the Lighthouse score drops below 95 or if new axe-core violations are introduced
- Configure Playwright to test complex, multi-step user flows (like checkout) for accessibility
- Set up Real User Monitoring (RUM) to track accessibility metrics and third-party widget failures in production
- Generate an automated compliance report for the legal team proving EAA/ADA adherence

#### What You'll Learn

- How to integrate accessibility testing into CI/CD pipelines as a hard, post-render gate
- How to set and enforce accessibility performance budgets
- How to test complex, multi-step user flows for accessibility using Playwright
- How to monitor accessibility in production using Real User Monitoring (RUM) to catch dynamic and third-party regressions
- How to translate technical accessibility metrics into legal compliance reports

#### Tools & Infrastructure

- **Tools:** GitHub Actions, Playwright, Pa11y, Lighthouse CI, OpenTelemetry, Grafana
- **Infrastructure:** CI/CD Pipeline, Production E-commerce Environment, Monitoring Stack
