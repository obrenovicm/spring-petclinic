FROM gradle:8.12-jdk17-focal AS build

RUN mkdir /project
COPY . /project
WORKDIR /project
RUN gradle clean build

FROM eclipse-temurin:17.0.14_7-jre-ubi9-minimal
EXPOSE 8000
RUN mkdir /app
COPY --from=build /project/build/libs/spring-petclinic*.jar /app/java-application.jar
COPY --from=build /project/jmx_prometheus_javaagent-1.2.0.jar /app/jmx_prometheus_javaagent-1.2.0.jar
COPY --from=build /project/config.yaml /app/config.yaml

WORKDIR /app
CMD [ "java", "-javaagent:jmx_prometheus_javaagent-1.2.0.jar=8000:config.yaml", "-jar", "java-application.jar"]
