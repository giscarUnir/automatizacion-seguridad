# Etapa de build
FROM maven:3.9-eclipse-temurin-21 AS build
WORKDIR /app
COPY pom.xml .
RUN mvn -B -q dependency:go-offline
COPY src ./src
RUN mvn -B -DskipTests package

# Etapa de runtime mínima, sin shell ni gestor de paquetes y fijada por digest.
# checkov:skip=CKV_DOCKER_2:La salud de la aplicacion se verifica con probes HTTP de Kubernetes.
FROM gcr.io/distroless/java21-debian13@sha256:946152d2cf293204caddd74f0b34f056327d55dd6e6309d9ef5f1c8af36ebcb0
WORKDIR /work
COPY --from=build --chown=65532:65532 /app/target/quarkus-app/ /work/
USER 65532:65532
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "/work/quarkus-run.jar"]
