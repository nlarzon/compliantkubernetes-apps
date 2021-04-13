package testPolicy

violation[{"msg": msg}] {
    input.review.object.apiVersion == "extensions/v1beta1"
    input.review.object.kind == "Ingress"
    msg := sprintf("%s/%s: API extensions/v1beta1 for Ingress is deprecated, use networking.k8s.io/v1beta1 instead.", [input.review.object.kind, input.review.object.metadata.name])
}


violation[{"msg": msg}] {
    input.review.object.apiVersion == "networking.k8s.io/v1beta1"
    input.review.object.kind == "Ingress"
    msg := sprintf("%s/%s: API networking.k8s.io/v1beta1 for Ingress is deprecated, use networking.k8s.io/v1 instead.", [input.review.object.kind, input.review.object.metadata.name])
}
