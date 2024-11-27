CREATE DATABASE [VectorTest]
GO
USE [VectorTest]
GO

EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
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
GO

CREATE TYPE Vector
EXTERNAL NAME myVector.Vector;
GO


CREATE FUNCTION dbo.VECTOR_DISTANCE
(
    @distanceMetric NVARCHAR(20),
    @vector1 Vector,
    @vector2 Vector
)
RETURNS FLOAT
AS EXTERNAL NAME myVector.Vector.VectorDistance;
GO

CREATE FUNCTION dbo.VECTOR_LENGTH
(
    @vector Vector
)
RETURNS INT
AS EXTERNAL NAME myVector.Vector.VectorLength;
GO

CREATE FUNCTION dbo.VECTOR_MAGNITUDE
(
    @vector Vector
)
RETURNS FLOAT
AS EXTERNAL NAME myVector.Vector.VectorMagnitude;
GO