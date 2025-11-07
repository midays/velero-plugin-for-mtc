FROM brew.registry.redhat.io/rh-osbs/openshift-golang-builder:rhel_8_golang_1.24 AS builder
COPY . /workspace/
WORKDIR /workspace/
ENV GOEXPERIMENT strictfipsruntime
ENV BUILDTAGS containers_image_ostree_stub exclude_graphdriver_devicemapper exclude_graphdriver_btrfs containers_image_openpgp exclude_graphdriver_overlay include_gcs include_oss strictfipsruntime
ENV BIN velero-plugin-for-mtc
RUN GO111MODULE=auto CGO_ENABLED=1 GOOS=linux go build -mod=readonly -v -installsuffix "static" -tags "$BUILDTAGS" -o _output/$BIN ./velero-plugins

FROM registry.redhat.io/ubi8/ubi:latest
RUN mkdir /plugins
COPY --from=builder /workspace/_output/$BIN /plugins/
COPY LICENSE /licenses/
USER 65534:65534
ENTRYPOINT ["/bin/bash", "-c", "cp /plugins/* /target/."]

LABEL \
        "io.k8s.description"="Migration Toolkit for Containers Velero Plugin For MTC" \
        "io.k8s.display-name"="Migration Toolkit for Containers" \
        "io.openshift.tags"="migration" \
        "summary"="Migration Toolkit for Containers Velero Plugin For MTC" \
        "io.openshift.maintainer.project"="MIG"
