
-- -- differences:

-- --- cannot define the vector size in table creation.
-- --- when calling the VECTOR_DISTANCE function, dbo. is required.
-- --- type vector is SAFE.
-- --- performance analysis is required.



-- -- enable instance level SQL CLR
-- EXEC sp_configure 'clr enabled', 1;
-- RECONFIGURE;
-- GO

-- -- configure database
-- ALTER AUTHORIZATION ON DATABASE::[VERNE] TO sa;
-- ALTER DATABASE VERNE SET TRUSTWORTHY on;
-- GO


-- drop table player_positions;
-- drop FUNCTION VECTOR_DISTANCE;
-- drop type Vector;
-- drop assembly myVector;

-- /*
-- -- find the assemply hash with powershell
-- $assemblies = @(
--     'C:\Users\erincon\Sources\_personal\myVector\bin\Release\net4.8\myVector.dll'
-- )

-- foreach ($assemblyPath in $assemblies) {
--     $hash = Get-FileHash $assemblyPath -Algorithm SHA512
--     Write-Output "$($assemblyPath): $($hash.Hash)"
-- }
-- */

-- ------ not necessary
-- -- EXEC sp_drop_trusted_assembly 0xA85B7B2B1E2AEA6FB1EED0DE666F7A737DF2E25FCF76357B41D7030415870FB1789D031572305B8F62E8E2669974092A8B1AC378ECF2BE84F24E5B3436ADFE89;
-- -- EXEC sp_add_trusted_assembly 0x263D009E6D49595A0D1FB6BF2FB82765666E188449131425988DD0FC63708BDC3DFDD3442FCC19105C676BAA6DC3BE63450D0BEDC4B3196A17F6AFB4EFDE3122, N'myVector-1.0';

-- CREATE ASSEMBLY myVector
-- FROM 'C:\Users\erincon\Sources\_personal\myVector\bin\Release\net4.8\myVector.dll'
-- WITH PERMISSION_SET = SAFE;


-- -- EXEC sp_drop_trusted_assembly 0x5C2CE91A1A24DB97475023057A837B76B7008F13365C5260E586546155BE9ABE41E54DFE7E6BAD62C4D19B1BBC810F2B2F7F9E551AFCD5022F8216E9944169CD;
-- -- 
-- drop  PROCEDURE dbo.sp_invoke_external_rest_endpoint2
-- drop assembly myRestEndpoint;

-- -- select * from sys.trusted_assemblies

-- EXEC sp_add_trusted_assembly 0x5C2CE91A1A24DB97475023057A837B76B7008F13365C5260E586546155BE9ABE41E54DFE7E6BAD62C4D19B1BBC810F2B2F7F9E551AFCD5022F8216E9944169CD, 
-- N'RestEndpoint-1.0';

-- CREATE ASSEMBLY myRestEndpoint 
-- FROM 'C:\Users\erincon\Sources\_personal\myVector\bin\Release\net4.8\RestEndpoint.dll'
-- WITH PERMISSION_SET = EXTERNAL_ACCESS;
-- GO




-- CREATE PROCEDURE dbo.sp_invoke_external_rest_endpoint2
-- @url NVARCHAR(MAX),
-- @method NVARCHAR(10),
-- @payload NVARCHAR(MAX),
-- @headers NVARCHAR(MAX),
-- @response NVARCHAR(MAX) OUTPUT
-- AS EXTERNAL NAME myRestEndpoint.RestEndpoint.InvokeRestEndpoint;
-- GO

-- CREATE TYPE Vector
-- EXTERNAL NAME myVector.Vector;
-- GO

-- DECLARE @v Vector;
-- SET @v = CAST('[1.0, 2.0, 3.0]' AS Vector);

-- SELECT @v, cast(@v as nvarchar(max));
-- GO

-- CREATE FUNCTION dbo.VECTOR_DISTANCE
-- (
--     @distanceMetric NVARCHAR(MAX),
--     @vector1 Vector,
--     @vector2 Vector
-- )
-- RETURNS FLOAT
-- AS EXTERNAL NAME myVector.Vector.VectorDistance;
-- GO

-- DECLARE @v1 Vector = CAST('[1, 2, 3]' AS Vector);
-- DECLARE @v2 Vector = CAST('[4, 5, 6]' AS Vector);

-- SELECT dbo.VECTOR_DISTANCE('euclidean', @v1, @v2) AS Distance;
-- GO


-- -- EXEC dbo.get_embeddings @model = 'text-embedding-ada-002', @text = @summary, @embedding = @embedding_ada_002 OUTPUT;
-- -- EXEC dbo.get_embeddings @model = 'text-embedding-3-small', @text = @summary, @embedding = @embedding_3_small OUTPUT;

-- DECLARE @size INT = 1532;
-- DECLARE @vector VECTOR;
-- DECLARE @text NVARCHAR(MAX) = 'The quick brown fox jumps over the lazy dog';
-- DECLARE @model NVARCHAR(MAX) = 'text-embedding-3-small';
-- DECLARE @retval INT, @response NVARCHAR(MAX);
-- DECLARE @url VARCHAR(MAX);
-- DECLARE  @payload NVARCHAR(MAX) = N'{"input": "' + @text + N'", "dimension": ' + CAST(@size AS NVARCHAR(MAX)) + N'}';
-- -- Set the @url variable with proper concatenation before the EXEC statement
-- SET @url = 'https://xxxxxxx.openai.azure.com/openai/deployments/' + @model + '/embeddings?api-version=2023-03-15-preview';

-- EXEC dbo.sp_invoke_external_rest_endpoint2
--     @url = @url,
--     @method = 'POST',   
--     @payload = @payload,   
--     @headers = '{"Content-Type":"application/json", "api-key":"xxxxxxxx"}',
--     @response = @response OUTPUT;

-- SELECT @vector = STRING_AGG(value, ',')
-- FROM OPENJSON(@response, '$.data[0].embedding');

-- SELECT @vector, cast(@vector as nvarchar(max)), @response;


