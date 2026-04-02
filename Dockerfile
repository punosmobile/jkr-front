# Stage 1: Build Flutter web
FROM ghcr.io/cirruslabs/flutter:3.27.4 AS build

WORKDIR /app

# Kopioi riippuvuustiedostot ensin (Docker layer cache)
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

# Kopioi lähdekoodi
COPY . .

# Build-time ympäristömuuttujat
ARG API_BASE_URL=http://localhost:8000
ARG AZURE_CLIENT_ID
ARG AZURE_TENANT_ID

# Generoi koodi (injectable, freezed, jne.)
RUN flutter pub run build_runner build --delete-conflicting-outputs

# Buildaa Flutter web
RUN flutter build web --release \
    --dart-define=API_BASE_URL=${API_BASE_URL} \
    --dart-define=AZURE_CLIENT_ID=${AZURE_CLIENT_ID} \
    --dart-define=AZURE_TENANT_ID=${AZURE_TENANT_ID}

# Stage 2: Serve with nginx
FROM nginx:alpine

# Poista oletuskonfiguraatio
RUN rm /etc/nginx/conf.d/default.conf

# Kopioi nginx-konfiguraatio
COPY nginx/nginx.conf /etc/nginx/conf.d/default.conf

# Kopioi buildattu Flutter web -sovellus
COPY --from=build /app/build/web /usr/share/nginx/html

EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]
