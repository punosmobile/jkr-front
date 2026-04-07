# Stage 1: Build Flutter web
FROM ghcr.io/cirruslabs/flutter:3.27.4 AS build

WORKDIR /app

# Kopioi riippuvuustiedostot ensin (Docker layer cache)
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

# Kopioi lähdekoodi
COPY . .

# Generoi koodi (injectable, freezed, jne.)
RUN flutter pub run build_runner build --delete-conflicting-outputs

# Buildaa Flutter web — ei build-aikaisia ympäristömuuttujia,
# arvot tulevat ajonaikaisesti nginx:n generoimasta runtime_config.js:stä
RUN flutter build web --release --no-wasm-dry-run

# Stage 2: Serve with nginx
FROM nginx:alpine

# Poista oletuskonfiguraatio
RUN rm /etc/nginx/conf.d/default.conf

# Kopioi nginx-konfiguraatio
COPY nginx/nginx.conf /etc/nginx/conf.d/default.conf

# Kopioi buildattu Flutter web -sovellus
COPY --from=build /app/build/web /usr/share/nginx/html

# Entrypoint-skripti generoi runtime_config.js ympäristömuuttujista
COPY docker/30-runtime-config.sh /docker-entrypoint.d/
RUN chmod +x /docker-entrypoint.d/30-runtime-config.sh

EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]
