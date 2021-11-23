# Upgrade v0.18.x to v0.19.0

## Steps

1. Run migration script: `copy-environment-variables.sh`

    This will copy over the variables set for the environment regarding cloud provider, environment name, and flavor to the new location: the common default config.

1. Run migration script: `opensearch-migration-configuration.sh`

    This will migrate the configuration from ODFE to OpenSearch, and set `opensearch.createIndices` to `false` as these will be restored from ODFE.
    All settings will be carried over from `elasticsearch` to `opensearch`, and from `kibana` to `opensearch.dashboards`.

    Review and tweak the configuration in `sc-config.yaml` according to your preferences.
    By default it will configure OpenSearch using the subdomain `opensearch` on `ops.${DOMAIN}`, OpenSearch Dashboards using the subdomain `opensearch` on `${DOMAIN}`, and the snapshot repository using the bucket `${ENVIRONMENT_NAME}-opensearch`.
    These must be prepared for the migration.

1. Update apps configuration:

    This will take a backup into `backups/` before modifying any files.

    ```bash
    bin/ck8s init
    ```

    This will generate new `defaults/common-config.yaml` and `common-config.yaml`, which will contain common configuration options set for both the service and workload cluster. Any common option set for the service and workload cluster in the `service-config.yaml` and `workload-config.yaml` will be moved to `common-config.yaml` automatically.

1. Migrate from ODFE to OpenSearch:

    This will set up a fresh OpenSearch cluster and migrate the data from ODFE via snapshots.
    **Note** that this will *not* carry over security settings.
    Any user, role, or rolemapping that has been manually created must be either added into the configuration manifests or later manually added when the data migration is complete.

    If there is enough resources in the service cluster, and OpenSearch will be running under a new subdomain, then the two clusters can run in parallel during migration allowing you to verify that everything is carried over.
    **Note** that this will introduce authentication issues later for ODFE when Dex is updated, as the connector to Kibana will be remvoed.
    So make sure that you are already signed in to Kibana when you start if go with that method.

    1. Remove Fluentd from the workload cluster to stop the flow of logs to ODFE:
        ```bash
        bin/ck8s ops helmfile wc -l app=fluentd delete
        ```

    1. Create a final snapshot in ODFE:
        ```
        curl -u "admin:passwd" -XPUT http://localhost:9200/_snapshot/elastic-snapshots/final?wait_for_completion=true
        ```

    1. If using OIDC: Update Dex to add OpenSearch client:
        ```bash
        bin/ck8s ops helmfile sc -l app=dex apply
        ```

    1. Deploy OpenSearch:
        ```bash
        bin/ck8s ops helmfile sc -l group=opensearch apply
        ```
        When completed the cluster should be ready, verify by signing in to OpenSearch Dashboards.

    1. Delete Kibana index from OpenSearch which will later be restored from ODFE:
        ```curl
        curl -u "admin:passwd" -XDELETE http://localhost:9200/.kibana_1
        ```

    1. Add ODFE snapshot repository as readonly to OpenSearch:
        ```curl
        curl -u "admin:passwd" -XPUT http://localhost:9200/_snapshot/elastic-snapshots/ \
          -H "Content-Type: application/json" \
          -d '{"type":"s3","settings":{"bucket":"<>","readonly":true}}'
        ```

    1. Find final ODFE snapshot:
        ```curl
        curl -u "admin:passwd" -XGET http://localhost:9200/_snapshot/elastic-snapshots/final
        ```
        Make sure it contains the indices `.kibana*`, `authlog*`, `kubeaudit*`, `kubernetes*`, and `other*`, these are the ones that will be restored.

    1. Restore final ODFE snapshot:
        ```curl
        curl -u "admin:passwd" -XPOST http://localhost:9200/_snapshot/elastic-snapshots/final/_restore?wait_for_completion=true \
          -H "Content-Type: application/json" \
          -d '{"indices":".kibana*,authlog*,kubeaudit*,kubernetes*,other*","include_global_state":false}'
        ```
        When completed verify that all logs and saved objects appear in OpenSearch.

    1. Remove ODFE snapshot repository from OpenSearch:
        ```curl
        curl -u "admin:passwd" -XDELETE http://localhost:9200/_snapshot/elastic-snapshots
        ```

    1. Remove ODFE from the service cluster.

        This can be skipped as upgrading the rest of the apps will remove it as well, but if the service cluster is resource starved it might be a good idea to that before the full upgrade.

        ```bash
        bin/ck8s ops helmfile sc -l group=opendistro delete
        ```

1. Delete deprecated parameter `fluentd.forwarder.queueLimitSizeBytes` in `sc-config.yaml`

1. Rename parameter `fluentd.forwarder.chunkLimitSizeBytes` to `fluentd.forwarder.chunkLimitSize` in `sc-config.yaml`

1. Upgrade applications:

    ```bash
    bin/ck8s apply {sc|wc}
    ```
