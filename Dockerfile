# Etapa de build
FROM maven:3.9-eclipse-temurin-21 AS build
WORKDIR /app
COPY pom.xml .
RUN mvn -B -q dependency:go-offline
COPY src ./src
RUN mvn -B -DskipTests package

# Etapa de runtime (imagen JRE, usuario NO root, version fija - buenas practicas)
# checkov:skip=CKV_DOCKER_2:La salud de la aplicacion se verifica con probes HTTP de Kubernetes.
FROM eclipse-temurin:21-jre
RUN useradd -r -u 10001 appuser
WORKDIR /work
COPY --from=build /app/target/quarkus-app/ /work/
USER 10001
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "/work/quarkus-run.jar"]
