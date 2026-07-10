# DEMO INSEGURO: corre como root, sin usuario dedicado.
FROM eclipse-temurin:21-jre
USER root
WORKDIR /work
COPY target/quarkus-app/ /work/
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "/work/quarkus-run.jar"]
