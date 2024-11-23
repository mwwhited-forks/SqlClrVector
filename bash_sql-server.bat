
SETLOCAL

IF "%APP_PROJECT%"=="" SET APP_PROJECT=vector-test

CALL docker exec -it --user root %APP_PROJECT%-sql-server-1 bash

ENDLOCAL
