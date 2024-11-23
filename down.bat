SETLOCAL

IF "%APP_PROJECT%"=="" SET APP_PROJECT=vector-test

CALL docker compose --project-name %APP_PROJECT% --file .\containers\docker-compose-cpu.yml down --volumes

ENDLOCAL
