provider "kubernetes" {
    config_context_cluster = var.eks_cluster_arn
}


resource "kubernetes_namespace" "exercise" {
    metadata {
        name = "exercise" 
    }
}
resource "kubernetes_deployment" "exercise-app" {
    metadata {
        name = "exercise-app"
        namespace = kubernetes_namespace.exercise.metadata[0].name
    }
    spec {
        replicas = 2
        selector {
            match_labels = {
                app = "exercise-app"
            }
        }
        template {
            metadata {
                labels = {
                app = "exercise-app"
            }
        }

            spec {
                container {
                    image = var.exercise_image
                    name = "hello-world"
                }
            }
        }
    }
}

resource "kubernetes_service" "exercise_service" {
    metadata {
        name      = "exercise-service"
        namespace = kubernetes_namespace.exercise.metadata[0].name
    }

    spec {
        selector = {
            app = kubernetes_deployment.exercise-app.spec[0].template[0].metadata[0].labels.app
        }

        port {
            port        = 80
            target_port = 8080
        }

        type = "LoadBalancer"
    }

    depends_on = [ kubernetes_deployment.exercise-app ]
}