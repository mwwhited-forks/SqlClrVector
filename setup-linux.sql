CREATE DATABASE VectorTest
GO
USE VectorTest
GO

EXEC sp_configure 'clr strict security', 0;
RECONFIGURE;
GO
EXEC sp_configure 'clr enabled', 1;
RECONFIGURE;
GO

CREATE ASSEMBLY myVector
FROM '/var/opt/mssql/bin/myVector.dll'
WITH PERMISSION_SET = SAFE;
