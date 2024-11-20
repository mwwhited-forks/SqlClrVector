
-- differences:

--- cannot define the vector size in table creation.
--- when calling the VECTOR_DISTANCE function, dbo. is required.
--- type vector is SAFE.
--- performance analysis is required.



-- enable instance level SQL CLR
EXEC sp_configure 'clr enabled', 1;
RECONFIGURE;
GO

-- configure database
ALTER AUTHORIZATION ON DATABASE::[VERNE] TO sa;
ALTER DATABASE VERNE SET TRUSTWORTHY on;
GO


CREATE ASSEMBLY myVector
FROM 'C:\Users\erincon\Sources\_personal\myVector\bin\Release\net4.8\myVector.dll'
WITH PERMISSION_SET = SAFE;

/*

DROP TABLE player_positions;
DROP FUNCTION VECTOR_DISTANCE;
DROP TYPE Vector;
DROP ASSEMBLY myVector;

*/



CREATE TYPE Vector
EXTERNAL NAME myVector.Vector;
GO

-- difference: cannot define the vector size in value definition / table creation
DECLARE @v Vector;
SET @v = CAST('[1.0, 2.0, 3.0]' AS Vector);

-- difference: SQL Azure returns the value as casted_value by default
SELECT @v value, cast(@v as nvarchar(max)) casted_value;
GO


CREATE FUNCTION dbo.VECTOR_DISTANCE
(
    @distanceMetric NVARCHAR(MAX),
    @v1 Vector,
    @v2 Vector
)
RETURNS FLOAT
AS EXTERNAL NAME myVector.Vector.VectorDistance;
GO

DECLARE @v1 Vector = CAST('[1, 2, 3]' AS Vector);
DECLARE @v2 Vector = CAST('[4, 5, 6]' AS Vector);

-- difference: dbo. is required when calling the function
-- difference: manhattan is implemented (in SQL Azure it is not implemented)
SELECT dbo.VECTOR_DISTANCE('euclidean', @v1, @v2) AS Distance;
GO


CREATE ASSEMBLY myRestEndpoint 
FROM 'C:\Users\erincon\Sources\_personal\myVector\bin\Release\net4.8\myRestEndpoint.dll'
WITH PERMISSION_SET = EXTERNAL_ACCESS;
GO

/*

DROP PROCEDURE dbo.sp_invoke_external_rest_endpoint2
DROP ASSEMBLY myRestEndpoint;

*/


CREATE PROCEDURE dbo.sp_invoke_external_rest_endpoint2
    @url NVARCHAR(MAX),
    @method NVARCHAR(10),
    @payload NVARCHAR(MAX),
    @headers NVARCHAR(MAX),
    @response NVARCHAR(MAX) OUTPUT
AS EXTERNAL NAME myRestEndpoint.RestEndpoint.InvokeRestEndpoint;
GO


DECLARE @vectorSize INT = 1532;
DECLARE @vector VECTOR;
DECLARE @text NVARCHAR(MAX) = 'The quick brown fox jumps over the lazy dog';
DECLARE @model NVARCHAR(MAX) = 'text-embedding-3-small'; -- 'text-embedding-3-small'
DECLARE @retval INT, @response NVARCHAR(MAX);
DECLARE @url VARCHAR(MAX) == 'https://zzzzz.openai.azure.com/openai/deployments/' + @model + '/embeddings?api-version=2023-03-15-preview';
DECLARE  @payload NVARCHAR(MAX) = N'{"input": "' + @text + N'", "dimension": ' + CAST(@vectorSize AS NVARCHAR(MAX)) + N'}';

-- difference: credential cannot be passed as parameter
EXEC dbo.sp_invoke_external_rest_endpoint2
    @url = @url,
    @method = 'POST',   
    @payload = @payload,   
    @headers = '{"Content-Type":"application/json", "api-key":"zzzzzz"}',
    @response = @response OUTPUT;


---- difference: SQL Azure sp_invoke_external_rest_endpoint returns: '$.result.data[0].embedding'
-- DECLARE @json NVARCHAR(MAX) = JSON_QUERY(@response, '$.result.data[0].embedding');

-- convert result to Vector
SELECT @vector = STRING_AGG(value, ',')
FROM OPENJSON(@response, '$.data[0].embedding');

SELECT @vector, cast(@vector as nvarchar(max)), @response;
