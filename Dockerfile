# Etapa de build
FROM maven:3.9-eclipse-temurin-21 AS build
WORKDIR /app
COPY pom.xml .
RUN mvn -B -q dependency:go-offline
COPY src ./src
RUN mvn -B -DskipTests package

# Etapa de runtime mínima, sin shell ni gestor de paquetes y fijada por digest.
# checkov:skip=CKV_DOCKER_2:La salud de la aplicacion se verifica con probes HTTP de Kubernetes.
FROM gcr.io/distroless/java21-debian13@sha256:258e48dcf7e9441095e8332c654e5005b21cd06f610ca9807ccbb56a5da412f7
WORKDIR /work
COPY --from=build --chown=65532:65532 /app/target/quarkus-app/ /work/
USER 65532:65532
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "/work/quarkus-run.jar"]
