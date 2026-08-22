# CloudNativePG platform sources

This repository carries the public operator and plugin source boundary only. It does not provision a PostgreSQL operand cluster, change an operand image, resolve credentials, or reconcile a cluster.

## Reviewed sources

| Component | Version | Render source | Release evidence |
| --- | --- | --- | --- |
| CloudNativePG operator | `1.30.0` | `https://raw.githubusercontent.com/cloudnative-pg/cloudnative-pg/4b5e244a7d031f67e025c83c1555e7726ecbbfa1/releases/cnpg-1.30.0.yaml` | Git tag `v1.30.0`, commit `4b5e244a7d031f67e025c83c1555e7726ecbbfa1`; release asset `cnpg-1.30.0.yaml`, SHA-256 `f8bede43fe4ee0d478c2355b204a36876b2ae4faac60f2a9452280b293da3b88` |
| CloudNativePG Barman Cloud plugin | `0.14.0` | `https://github.com/cloudnative-pg/plugin-barman-cloud/releases/download/v0.14.0/manifest.yaml` | Git tag `v0.14.0`, commit `1e13020fe5f09fd8fc29ea03828f7b61375b3721`; release asset `manifest.yaml`, SHA-256 `8d4f1719cc54891ddffd7633279ec93b5d2cc547df8684c3b84f3b156a615e7c` |

The source metadata is also rendered as the `cnpg-platform-source-integrity` ConfigMap. The asset digests were observed from the official GitHub release APIs before this change; a source or release mismatch is a review failure, not a reason to silently accept a different artifact.

Primary sources:

- [CloudNativePG v1.30.0 release](https://github.com/cloudnative-pg/cloudnative-pg/releases/tag/v1.30.0)
- [CloudNativePG v1.30.0 release manifest](https://github.com/cloudnative-pg/cloudnative-pg/releases/download/v1.30.0/cnpg-1.30.0.yaml)
- [CloudNativePG Barman Cloud plugin v0.14.0 release](https://github.com/cloudnative-pg/plugin-barman-cloud/releases/tag/v0.14.0)
- [CloudNativePG Barman Cloud plugin v0.14.0 manifest](https://github.com/cloudnative-pg/plugin-barman-cloud/releases/download/v0.14.0/manifest.yaml)

## Compatibility boundary

CloudNativePG v1.30.0 lists Kubernetes `1.36`, `1.35`, and `1.34` as supported in its release notes. CloudNativePG's published operator and PostgreSQL image documentation describes multi-architecture images including Linux `arm64`. Together these are source-level compatibility evidence for the K3s `1.36` / Linux `arm64` platform; they are not live cluster health evidence.

- [CloudNativePG v1.30.0 supported versions](https://github.com/cloudnative-pg/cloudnative-pg/releases/tag/v1.30.0#supported-versions)
- [CloudNativePG image and architecture documentation](https://cloudnative-pg.io/docs/1.26/)

The selected PostgreSQL operand image remains an application-owned private decision and is intentionally unchanged by this operator/plugin source update. The plugin release is installed only as a controller extension; backup bucket, credentials, retention, restore, and cluster reconciliation belong to the private repository and separately authorized tasks.

## Safety boundary

1. Review the exact release diff before reconciliation.
2. Establish and restore-test current backups for every existing CNPG cluster.
3. Obtain current-session authorization before applying the operator/plugin change.
4. Observe operator readiness, existing cluster health, and backup health before provisioning a Hub cluster.
