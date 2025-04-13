FROM openjdk:17 AS build-stage
WORKDIR /webbooks
COPY ./webbooks .
RUN ./mvnw -DskipTests package

FROM openjdk:17 AS webbooks-app
WORKDIR /opt/webbooks
EXPOSE 8080
COPY --from=build-stage /webbooks/target/*.jar /opt/webbooks/*.jar
ENTRYPOINT ["java", "-jar", "/opt/webbooks/*.jar"]