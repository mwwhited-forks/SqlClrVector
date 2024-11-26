
-- This script demonstrates the calculation of embeddings using both external and local models.
-- It includes three main sections:
-- 1. Embeddings calculation using an external model via an Azure OpenAI endpoint.
-- 2. Local embeddings calculation using the 'all-minilm' model.
-- 3. Local embeddings calculation using the 'mxbai-embed-large' model.

-- Section 1: External embeddings calculation
-- - Declares variables for vector size, text input, model, and API endpoint.
-- - Constructs a payload for the API request.
-- - Invokes an external REST endpoint to get embeddings.
-- - Parses the response to extract the embedding vector.
-- - Converts the result to a VECTOR type and verifies the content.

-- Section 2: Local embeddings calculation with 'all-minilm' model
-- - Declares variables for response and vector.
-- - Invokes a local model to get embeddings.
-- - Parses the response to extract the embedding vector.
-- - Converts the result to a VECTOR type and verifies the content.

-- Section 3: Local embeddings calculation with 'mxbai-embed-large' model
-- - Similar to Section 2 but uses a different model with a larger vector size.
-- - Invokes a local model to get embeddings.
-- - Parses the response to extract the embedding vector.
-- - Converts the result to a VECTOR type and verifies the content.

--- embeddings calculation

DECLARE @vectorSize INT = 1532;
DECLARE @vector VECTOR;
DECLARE @text NVARCHAR(MAX) = 'The quick brown fox jumps over the lazy dog';
DECLARE @model NVARCHAR(MAX) = 'text-embedding-3-small'; -- 'text-embedding-3-small'
DECLARE @retval INT, @response NVARCHAR(MAX);
DECLARE @url VARCHAR(MAX) = 'https://zzzzz.openai.azure.com/openai/deployments/' + @model + '/embeddings?api-version=2023-03-15-preview';
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
GO


-- local embeddings calculation
-- all-minilm model --> -- 384 vector size

DECLARE @response NVARCHAR(MAX);
DECLARE @vector VECTOR;
EXEC dbo.sp_invoke_ollama_model 
    @endpoint = 'http://localhost:11434/api/embeddings',
    @model = 'all-minilm', 
    @prompt = 'The sky is blue because of Rayleigh scattering',
    @response = @response OUTPUT;

WITH ParsedEmbedding AS (
    SELECT value
    FROM OPENJSON(@response, '$.embedding')
)
SELECT @vector = CAST(STRING_AGG(value, ',') AS VECTOR)
FROM ParsedEmbedding;

-- Verificar el contenido del VECTOR
SELECT 
    @vector AS value, 
    @vector.Size() AS size, 
    CAST(@vector AS NVARCHAR(MAX)) AS text;

select @response;

-- convert result to Vector
SELECT @vector = STRING_AGG(value, ',')
FROM OPENJSON(@response, '$.data[0].embedding');

SELECT @vector value, @vector.Size() size, cast(@vector as nvarchar(max)) text;
GO


-- local embeddings calculation
-- all-minilm model --> -- 1024 vector size

DECLARE @response NVARCHAR(MAX);
DECLARE @vector VECTOR;
EXEC dbo.sp_invoke_ollama_model 
    @endpoint = 'http://localhost:11434/api/embeddings',
    @model = 'mxbai-embed-large', -- 1024 vector size
    @prompt = 'The sky is blue because of Rayleigh scattering',
    @response = @response OUTPUT;

WITH ParsedEmbedding AS (
    SELECT value
    FROM OPENJSON(@response, '$.embedding')
)
SELECT @vector = CAST(STRING_AGG(value, ',') AS VECTOR)
FROM ParsedEmbedding;

-- Verificar el contenido del VECTOR
SELECT 
    @vector AS value, 
    @vector.Size() AS size, 
    CAST(@vector AS NVARCHAR(MAX)) AS text;

select @response;

-- convert result to Vector
SELECT @vector = STRING_AGG(value, ',')
FROM OPENJSON(@response, '$.data[0].embedding');

SELECT @vector value, @vector.Size() size, cast(@vector as nvarchar(max)) text;



