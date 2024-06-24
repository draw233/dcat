# Specify the Dart SDK base image version using dart:<version> (ex: dart:2.12)
FROM dart:stable AS build

# Resolve app dependencies.
WORKDIR /app
COPY pubspec.* ./
RUN dart pub get

# Copy app source code and AOT compile it.
COPY . .
# Ensure packages are still up-to-date if anything has changed
RUN dart pub get --offline
RUN dart compile exe bin/dcat.dart -o bin/dcat

# Build minimal serving image from AOT-compiled `/dcat` and required system
# libraries and configuration files stored in `/runtime/` from the build stage.
FROM alpine
COPY --from=build /runtime/ /
COPY --from=build /app/bin/dcat /app/bin/

# Start dcat.
EXPOSE 8080
CMD ["/app/bin/dcat"]