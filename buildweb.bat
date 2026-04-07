@echo off
echo [1/2] Builtataan Flutter web...
call flutter build web --no-wasm-dry-run
if not exist "build\web\index.html" (
    echo Flutter build epaonnistui.
    exit /b 1
)

echo [2/2] Builtataan Docker-image jkr-front...
docker build -f Dockerfile.local -t jkr-front .
if %errorlevel% neq 0 (
    echo Docker build epaonnistui.
    exit /b %errorlevel%
)

echo.
echo Valmis. Kaynnista sovellus: rundocker.bat
echo.
echo Vihje: Flutter-muutokset eivat vaadi imagen uudelleenrakennusta.
echo Aja muutosten jalkeen vain:
echo   flutter build web --dart-define-from-file=.env.local
