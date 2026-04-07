@echo off
echo Kaynnistetaan jkr-front portissa 8080...
echo (build\web mountattu - Flutter-muutokset nakyy ilman imagen uudelleenrakennusta)
echo (verkko: jkr-core-development_default)
echo.
docker compose -f docker-compose.local.yml up
