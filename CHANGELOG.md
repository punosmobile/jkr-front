# Changelog

All notable changes to this project will be documented in this file.

## [0.8.0] - 2026-10-15

### Added

- Deploy pipeline in GitHub Actions (`.github/workflows/deploy.yml`): a merge to `develop`, `test` or `main` deploys to dev, test or prod, and prod waits for approval by another developer. Azure login with OIDC, no stored credentials
- Rollback: a manual run of the deploy workflow with an earlier commit of the branch builds and deploys that commit
- Pull request checks (`.github/workflows/pr-checks.yml`): locked dependencies, analyzer errors and warnings, and the web build
- README: release process

### Changed

- Version tracking starts from this release. The version is set only in `pubspec.yaml`.
- Flutter is pinned to 3.41.6 in `pubspec.yaml`, and `pubspec.lock` is committed
- Deploy logs mask resource names and identifiers, because the repository is public

### Fixed

- Analyzer errors and warnings: unused code and imports removed
