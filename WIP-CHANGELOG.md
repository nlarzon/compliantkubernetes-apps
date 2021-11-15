# Release notes

* Check out the [upgrade guide](https://github.com/elastisys/compliantkubernetes-apps/blob/main/migration/v0.18.x-v0.19.x/upgrade-apps.md) for a complete set of instructions needed to upgrade.

# Updated

- updated falco helm chart to version 1.16.0, this upgrades falco to version 0.30.0
- kube-prometheus-stack to v19.2.2 [#685](https://github.com/elastisys/compliantkubernetes-apps/pull/685)
  - upgrade prometheus-operator to v0.50.0
  - sync dashboards, rules and subcharts
  - add endpoint port mertics for kube-state-metrics self monitor
  - dont create webhookconfigurations when prometheus operator is disabled
  - add ability to specify existing secret with additional alertmanager configs
  - Add default ingress pathType for prometheus
  - Support multicluster dashboards only for etcd
  - add support for prometheus TLS and basic auth on HTTP endpoints
  - allows to pass hashed credentials to the helm chart
  - template the relabellings which are passed into the service monitors
  - Support for secrets store CSI driver
  - allow to set a timezone for the default grafana dashboards
  - add option to override the allowUiUpdates for grafana dashboards
- promethues to v2.28.1 [full changelog](https://github.com/prometheus/prometheus/blob/main/CHANGELOG.md)
  - UI: Make the new experimental PromQL editor the default. #8925
  - HTTP SD: Add generic HTTP-based service discovery. #8839
  - Kubernetes SD: Allow configuring API Server access via a kubeconfig file. #8811
  - Kubernetes SD: Add ingress class name label for ingress discovery. #8916
- grafana to v8.2.3 [full changelog](https://github.com/grafana/grafana/blob/main/CHANGELOG.md)
  - **Security:** Fixes [CVE-2021-41174](https://grafana.com/blog/2021/11/03/grafana-8.2.3-released-with-medium-severity-security-fix-cve-2021-41174-grafana-xss/)
  - **Security:** Fix stylesheet injection vulnerability [#38432](https://github.com/grafana/grafana/pull/38432)
  - **Security:** Fix short URL vulnerability [#38436](https://github.com/grafana/grafana/pull/38436)
  - **Security:** Update dependencies to fix CVE-2021-36222. [#37546](https://github.com/grafana/grafana/pull/37546)
  - **Security**: Fixes CVE-2021-39226. For more information, see our [blog](https://grafana.com/blog/2021/10/05/grafana-7.5.11-and-8.1.6-released-with-critical-security-fix/)
  - **Docker:** Force use of libcrypto1.1 and libssl1.1 versions to fix CVE-2021-3711. [#38585](https://github.com/grafana/grafana/pull/38585)
  - **Prometheus:** We fixed the problem that resulted in an error when a user created a query with a $\_\_interval min step. [#40525](https://github.com/grafana/grafana/pull/40525)
  - **Scale:** We fixed how the system handles NaN percent when data min = data max. [#40622](https://github.com/grafana/grafana/pull/40622)
  - **RowsToFields:** We fixed the issue where the system was not properly interpreting number values. [#40580](https://github.com/grafana/grafana/pull/40580)
  - **Prometheus:** Add Headers to HTTP client options. [#40214](https://github.com/grafana/grafana/pull/40214)
  - **Prometheus:** Metrics browser can now handle label values with special characters. [#39713](https://github.com/grafana/grafana/pull/39713)
  - **Prometheus:** Removed autocomplete limit for metrics. [#39363](https://github.com/grafana/grafana/pull/39363)
  - **AccessControl:** Document new permissions restricting data source access. [#39091](https://github.com/grafana/grafana/pull/39091)
  - **InfluxDB:** Added support for $\_\_interval and $\_\_interval_ms in Flux queries for alerting. [#38889](https://github.com/grafana/grafana/pull/38889)
  - **InfluxDB:** Flux queries can use more precise start and end timestamps with nanosecond-precision. [#39415](https://github.com/grafana/grafana/pull/39415)
  - **Admin:** Prevent user from deleting user's current/active organization. [#38056](https://github.com/grafana/grafana/pull/38056)
  - **OAuth:** Make generic teams URL and JMES path configurable. [#37233](https://github.com/grafana/grafana/pull/37233),
- kube-state-metrics to v2.2.0 [full changelog](https://github.com/kubernetes/kube-state-metrics/blob/master/CHANGELOG.md)
  - Add support for native TLS #1354
  - Add wildcard option to metric-labels-allowlist #1403
  - Introduce metrics for Kubernetes object annotations #1468
  - Introduce metrics for cronjob job history limits #1535
  - Add available replica metric for statefulsets #1532
  - Add ready replica metric for deployments #1534
- node exporter to v1.2.2 [full changelog](https://github.com/prometheus/node_exporter/blob/master/CHANGELOG.md)
  - Add nvme collector #2062
  - Add conntrack statistics metrics #1155
  - Add ethtool stats collector #1832
  - Filesystem collector flags have been renamed. --collector.filesystem.ignored-mount-points is now --collector.filesystem.mount-points-exclude and --collector.filesystem.ignored-fs-types is now --collector.filesystem.fs-types-exclude. The old flags will be removed in 2.x.

### Changed

- The falco grafana dashboard now shows the misbehaving pod and instance for traceability
- Reworked configuration handling to use a common config in addition to the service and workload configs. This is handled in the same way as the sc and wc configs, meaning it is split between a default and an override config. Running `init` will update this configuration structure, update and regenerate any missing configs, as well as merge common options from sc and wc overrides into the common override.
- Updated fluentd config to adhere better with upsream configuration
- Fluentd now logs reasons for 400 errors from elasticsearch
- Enabled the default rules from kube-prometheus-stack and deleted them from `prometheus-alerts` chart [#681](https://github.com/elastisys/compliantkubernetes-apps/pull/681)
- Increased resources requests and limits for Starboard-operator in the common config [#681](https://github.com/elastisys/compliantkubernetes-apps/pull/681)
- moved the elasticsearch alerts from the prometheus-elasticsearch-exporter chart to the prometheus-alerts chart [#685](https://github.com/elastisys/compliantkubernetes-apps/pull/685)

### Fixed
- Grafana dashboards by keeping more metrics from the kubeApiServer [#681](https://github.com/elastisys/compliantkubernetes-apps/pull/681)

### Added

- Added fluentd metrics
- Enabled automatic compaction (cleanup) of pos_files for fluentd

### Removed

- Removed disabled helm charts. All have been disabled for at least one release which means no migration steps are needed as long as the updates have been done one version at a time.
  - `nfs-client-provisioner`
  - `gatekeeper-operator`
  - `common-psp-rbac`
  - `workload-cluster-psp-rbac`
