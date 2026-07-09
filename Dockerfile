# Etapa de build
FROM maven:3.9-eclipse-temurin-21 AS build
WORKDIR /app
COPY pom.xml .
RUN mvn -B -q dependency:go-offline || true
COPY src ./src
RUN mvn -B -DskipTests package

# Etapa de runtime (imagen JRE, usuario NO root, version fija - buenas practicas)
FROM eclipse-temurin:25-jre
RUN useradd -r -u 1001 appuser
WORKDIR /work
COPY --from=build /app/target/quarkus-app/ /work/
USER 1001
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "/work/quarkus-run.jar"]
