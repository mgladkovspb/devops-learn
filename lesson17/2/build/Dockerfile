FROM openjdk:17 AS build-stage
WORKDIR /build/webbooks
COPY ./build/webbooks .
RUN ./mvnw -DskipTests package
#RUN ./mvnw package

FROM openjdk:17 AS webbooks-app
WORKDIR /opt/webbooks
EXPOSE 8080
COPY --from=build-stage /build/webbooks/target/*.jar /opt/webbooks/*.jar
ENTRYPOINT ["java", "-jar", "/opt/webbooks/*.jar"]
