:setvar SQLCLR_BIN_PATH /var/opt/mssql/bin/
:setvar ASSEMBLY_NAME myVector
:setvar DATABASE_NAME VectorTest
:setvar TARGET_SCHEMA_NAME dbo

USE [$(DATABASE_NAME)]
GO

EXEC sp_configure 'show advanced options', 1; 
RECONFIGURE; 
EXEC sp_configure 'clr strict security', 0; 
RECONFIGURE; 
EXEC sp_configure 'clr enable', 1; 
RECONFIGURE;
GO

IF NOT EXISTS (
	SELECT *
	FROM sys.assemblies
	WHERE 
		assemblies.name = '$(ASSEMBLY_NAME)'
) BEGIN
	PRINT 'Installing [$(ASSEMBLY_NAME)]';
	EXEC('
		CREATE ASSEMBLY [$(ASSEMBLY_NAME)] 
		FROM ''$(SQLCLR_BIN_PATH)$(ASSEMBLY_NAME).dll'' 
		WITH PERMISSION_SET = SAFE
	');
END ELSE BEGIN
	PRINT 'Update [$(ASSEMBLY_NAME)]';
	EXEC('
		BEGIN TRY
			ALTER ASSEMBLY [$(ASSEMBLY_NAME)] 
			FROM ''$(SQLCLR_BIN_PATH)$(ASSEMBLY_NAME).dll'' 
			WITH PERMISSION_SET = SAFE, UNCHECKED DATA
		END TRY
		BEGIN CATCH
			IF ERROR_NUMBER() IN (6288)
			BEGIN
				-- Ignore this specific error
				PRINT ''-- Assembly was updated with data unchecked.'';
			END
			ELSE IF ERROR_NUMBER() IN (6285)
			BEGIN
				-- Ignore this specific error
				PRINT ''-- Assembly was unchanged.'';
			END
			ELSE 
			BEGIN
				THROW;
			END
		END CATCH
	');
END
GO

IF NOT EXISTS (
	SELECT *
	FROM sys.types
	INNER JOIN sys.type_assembly_usages
		ON type_assembly_usages.user_type_id = types.user_type_id
	INNER JOIN sys.assemblies
		ON assemblies.assembly_id = type_assembly_usages.assembly_id
	WHERE 
			assemblies.name = '$(ASSEMBLY_NAME)'
		AND types.name = 'Vector'
)
BEGIN
	PRINT 'Installing Type [Vector]';
	EXEC('
		CREATE TYPE [Vector]
		EXTERNAL NAME [$(ASSEMBLY_NAME)].Vector;	
	');
END ELSE BEGIN
	PRINT 'Type [Vector] Exists';
END

IF NOT EXISTS (
	SELECT *
	FROM sys.objects
	INNER JOIN sys.assembly_modules
		ON objects.object_id = assembly_modules.object_id
	INNER JOIN sys.assemblies
		ON assemblies.assembly_id = assembly_modules.assembly_id
	WHERE
			objects.type = 'fs'
		AND objects.name = 'VECTOR_DISTANCE'
		AND assemblies.name =  '$(ASSEMBLY_NAME)'
)
BEGIN
	PRINT 'Installing function [$(TARGET_SCHEMA_NAME)].[VECTOR_DISTANCE]';
	EXEC('
		CREATE FUNCTION [$(TARGET_SCHEMA_NAME)].[VECTOR_DISTANCE]
		(
			@distanceMetric NVARCHAR(MAX),
			@vector1 Vector,
			@vector2 Vector
		)
		RETURNS FLOAT
		AS EXTERNAL NAME [$(ASSEMBLY_NAME)].Vector.VectorDistance;
	');
END ELSE BEGIN
	PRINT 'Function [$(TARGET_SCHEMA_NAME)].[VECTOR_DISTANCE] Exists';
END

IF NOT EXISTS (
	SELECT *
	FROM sys.objects
	INNER JOIN sys.assembly_modules
		ON objects.object_id = assembly_modules.object_id
	INNER JOIN sys.assemblies
		ON assemblies.assembly_id = assembly_modules.assembly_id
	WHERE
			objects.type = 'fs'
		AND objects.name = 'VECTOR_LENGTH'
		AND assemblies.name =  '$(ASSEMBLY_NAME)'
)
BEGIN
	PRINT 'Installing function [$(TARGET_SCHEMA_NAME)].[VECTOR_LENGTH]';
	EXEC('
		CREATE FUNCTION [$(TARGET_SCHEMA_NAME)].[VECTOR_LENGTH]
		(
    @vector Vector
		)
		RETURNS FLOAT
		AS EXTERNAL NAME [$(ASSEMBLY_NAME)].Vector.VectorLength;
	');
END ELSE BEGIN
	PRINT 'Function [$(TARGET_SCHEMA_NAME)].[VECTOR_LENGTH] Exists';
END

IF NOT EXISTS (
	SELECT *
	FROM sys.objects
	INNER JOIN sys.assembly_modules
		ON objects.object_id = assembly_modules.object_id
	INNER JOIN sys.assemblies
		ON assemblies.assembly_id = assembly_modules.assembly_id
	WHERE
			objects.type = 'fs'
		AND objects.name = 'VECTOR_MAGNITUDE'
		AND assemblies.name =  '$(ASSEMBLY_NAME)'
)
BEGIN
	PRINT 'Installing function [$(TARGET_SCHEMA_NAME)].[VECTOR_MAGNITUDE]';
	EXEC('
		CREATE FUNCTION [$(TARGET_SCHEMA_NAME)].[VECTOR_MAGNITUDE]
		(
    @vector Vector
		)
		RETURNS FLOAT
		AS EXTERNAL NAME [$(ASSEMBLY_NAME)].Vector.VectorMagnitude;
	');
END ELSE BEGIN
	PRINT 'Function [$(TARGET_SCHEMA_NAME)].[VECTOR_MAGNITUDE] Exists';
END
