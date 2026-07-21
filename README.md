# OffOn Challenges

Welcome to OffOn Challenges! 🚀

These are **hands-on, recurring prompts** designed to help you practice **Cloud Native, OpenTelemetry, AI/ML**, and
other **open source skills**.

Each challenge runs in a **pre-provisioned environment**, so you can focus on solving real problems, not setup
headaches.

**What makes these challenges special:**

- 🎯 **Skill-focused** - Target specific technologies with clear objectives
- 📖 **Story-driven** - Learn through engaging narratives
- 🚀 **Zero setup** - Run in GitHub Codespaces, pre-configured and ready
- ✅ **Two-step verification** - Smoke tests and GitHub Actions validate your solution
- 🎓 **Three levels** - Beginner, Intermediate, and Expert for each adventure

## 💻 Run locally

The challenge environments can also be opened locally using VS Code Dev Containers.

### Requirements

- Docker Desktop or another Docker-compatible runtime
- Visual Studio Code
- The Dev Containers extension: `ms-vscode-remote.remote-containers`
- Git

### Start a challenge locally

1. Fork and clone this repository.
2. Open the repository folder in Visual Studio Code.
3. Open the Command Palette.
4. Select **Dev Containers: Reopen in Container**.
5. Choose the configuration for the adventure and difficulty level you want to run.
6. Wait for the container's `postCreateCommand` and `postStartCommand` to finish.

The container installs and starts the infrastructure required by the selected challenge.

### Repository detection

In GitHub Codespaces, the repository is detected through the
`GITHUB_REPOSITORY` environment variable.

When running locally, Adventure 01 derives the repository URL from the local
`origin` Git remote. GitHub SSH remotes such as:

```text
git@github.com:username/open-source-challenges.git

[Choose your adventure](https://offon.dev/adventures/) and begin learning!
