SETLOCAL

IF "%APP_PROJECT%"=="" SET APP_PROJECT=vector-test

SET BUILD_PATH=.\publish
SET BUILD_PATH_SQLCLR=%BUILD_PATH%\sqlclr

SET BUILD_CONFIGURATION=Release

RMDIR /s/q "%BUILD_PATH_SQLCLR%"
CALL dotnet build .\Vector\myVector.csproj --output "%BUILD_PATH_SQLCLR%" --configuration %BUILD_CONFIGURATION%
CALL dotnet build .\RestEndpoint\myRestEndpoint.csproj --output "%BUILD_PATH_SQLCLR%" --configuration %BUILD_CONFIGURATION%

CALL docker compose --project-name %APP_PROJECT% --file .\containers\docker-compose-cpu.yml build
CALL docker compose --project-name %APP_PROJECT% --file .\containers\docker-compose-cpu.yml up --detach

CALL docker cp %BUILD_PATH_SQLCLR%\myVector.dll %APP_PROJECT%-sql-server-1:/var/opt/mssql/bin

ENDLOCAL
