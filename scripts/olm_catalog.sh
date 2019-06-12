#!/usr/bin/env bash

indent() {
  INDENT="      "
  sed "s/^/$INDENT/" | sed "s/^${INDENT}\($1\)/${INDENT:0:-2}- \1/"
}

CRDDIR=${DIR:-$(cd $(dirname "$0")/../deploy/crds && pwd)}
PKGDIR=${DIR:-$(cd $(dirname "$0")/../deploy/olm-catalog/openshift-pipelines-operator && pwd)}
CSVDIR=${DIR:-$(cd ${PKGDIR}/0.3.1 && pwd)}

NAME=${NAME:-openshift-pipelines-operator-registry}
x=( $(echo $NAME | tr '-' ' ') )
DISPLAYNAME=${DISPLAYNAME:=${x[*]^}}

CRD=$(cat $(ls $CRDDIR/*crd.yaml) | grep -v -- "---" | indent apiVersion)
CSV=$(cat $(ls $CSVDIR/*version.yaml) | indent apiVersion)
PKG=$(cat $(ls $PKGDIR/*openshift-pipelines-operator.package.yaml) | indent packageName)

cat <<EOF | sed 's/^  *$//'
# This file was autogenerated by 'tektoncd-pipeline-operator/scripts/olm_catalog.sh'
# Do not edit it manually!
---
apiVersion: v1
kind: Namespace
metadata:
  name: openshift-pipelines-operator
---
apiVersion: operators.coreos.com/v1
kind: OperatorGroup
metadata:
  name: openshift-pipelines-operator
  namespace: openshift-pipelines-operator
spec:
  targetNamespaces:
  - openshift-pipelines-operator
---
apiVersion: operators.coreos.com/v1alpha1
kind: CatalogSource
metadata:
  name: $NAME
  namespace: openshift-pipelines-operator
spec:
  configMap: $NAME
  displayName: $DISPLAYNAME
  publisher: Red Hat
  sourceType: configmap
---
kind: ConfigMap
apiVersion: v1
metadata:
  name: $NAME
  namespace: openshift-pipelines-operator
data:
  customResourceDefinitions: |-
$CRD
  clusterServiceVersions: |-
$CSV
  packages: |-
$PKG
EOF
