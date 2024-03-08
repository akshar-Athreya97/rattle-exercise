output "loadbalancer_ep" {
    value = kubernetes_service.exercise_service.status
}