# Example Code for REST API Calls and Vector Calculations in SQL Server

This repository contains example code for demonstrating REST API integration and vector manipulation within a SQL Server context. **Note:** This is development-level code and is **not intended for production use**. It is meant to showcase how to implement these features in SQL Server using SQL CLR assemblies.

## Table of Contents
## What's new

- Added method to calculate vector size.
- Added function for local embeddings calculation using Ollama models.
- Added sample for Azure OpenAI API integration.

## Features

1. **REST API Integration**:
   - `myRestEndpoint.cs`: Provides a SQL CLR stored procedure to invoke REST APIs from SQL Server. Supports:
     - GET and POST methods.
     - Custom headers in JSON format.
     - Payload handling for POST requests.

2. **Vector Type and Operations**:
   - `myVector.cs`: Implements a SQL CLR User-Defined Type (UDT) for vectors, allowing:
     - Serialization and deserialization of vectors.
     - Support for multiple distance metrics (Cosine, Euclidean, Manhattan, and (dot) Negative Inner Product).
     - Usage within SQL Server for advanced calculations.

## Files in this Repository

### REST API Integration
- **`myRestEndpoint.cs`**:
  - SQL CLR stored procedure for invoking REST APIs.
  - Handles JSON-formatted headers and POST payloads.
  - Supports TLS 1.2 for secure communication.

- **`myRestEndpoint.csproj`**:
  - Project file for compiling the REST API integration code.

### Vector Operations
- **`myVector.cs`**:
  - SQL CLR UDT for vector operations.
  - Supports parsing from JSON-like strings and performing vector distance calculations.
  - Implements serialization for SQL Server compatibility.
  - Assesmbly deployed in SAFE mode.

- **`myVector.csproj`**:
  - Project file for compiling the vector operations code.
  - Assesmbly deployed in EXTERNAL_ACCESS mode.

- **`myVector.sln`**:
  - Solution file to manage both the REST API and vector projects in Visual Studio.

## Requirements

- Visual Studio 2022 (or newer).
- .NET Framework 4.8.
- SQL Server edittion with [CLR support](https://learn.microsoft.com/en-us/sql/relational-databases/clr-integration/common-language-runtime-integration-overview?view=sql-server-ver16).
- The UDF needs EXTERNAL_ACCESS. SQL CLR in linux supports only SAFE assemblies [link](https://learn.microsoft.com/en-us/sql/language-extensions/concepts/compare-extensibility-to-clr?view=sql-server-ver16).

## Limitations
- Vector type:
  - Cannot define vector size during table creation.
  - Requires `dbo.` prefix when invoking vector functions.
- Performance of REST API and vector operations in production scenarios has not been analyzed.
- REST API integration disables certificate validation in testing for convenience (should not be used in production).

## Compile

- dotnet build -c Release myRestEndpoint.csproj
- dotnet build -c Release myVector.csproj


## Usage

1. **REST API Calls**:
   Deploy the `myRestEndpoint` assembly to your SQL Server and use the `sp_invoke_external_rest_endpoint2` stored procedure to call REST APIs directly from SQL Server.

   ### Example for Chat Completion:
```sql
DECLARE @response NVARCHAR(MAX);
DECLARE @chat_completion NVARCHAR(MAX);

EXEC dbo.sp_invoke_external_rest_endpoint2
    @url = 'https://xxxxx.openai.azure.com/openai/deployments/gpt-4o-mini/chat/completions?api-version=2023-05-15',
    @method = 'POST',
    @payload = N'{"messages": [{"role": "system", "content": "Your system message"}, {"role": "user", "content": "Your user prompt"}], "temperature": 0.1, "max_tokens": 1000}',
    @headers = '{"Content-Type":"application/json", "api-key":"zzzzzz"}',
    @response = @response OUTPUT;

SET @chat_completion = CAST(JSON_VALUE(@response, '$.choices[0].message.content') AS NVARCHAR(MAX));
SELECT @chat_completion AS Content;
```


   ### Example for Azure OpenAI Embeddings:

```sql
DECLARE @response NVARCHAR(MAX);
DECLARE @vector NVARCHAR(MAX);

EXEC dbo.sp_invoke_external_rest_endpoint2
    @url = 'https://xxxxxx.openai.azure.com/openai/deployments/gpt-4o-mini/embeddings?api-version=2023-05-15',
    @method = 'POST',
    @payload = N'{"input": "Your input text"}',
    @headers = '{"Content-Type":"application/json", "api-key":"zzzzzz"}',
    @response = @response OUTPUT;

WITH ParsedEmbedding AS (
    SELECT value
    FROM OPENJSON(@response, '$.data[0].embedding')
)
SELECT @vector = STRING_AGG(value, ',')
FROM ParsedEmbedding;

SELECT @vector AS Embedding;
```

2. Local Embeddings Calculation: Use the sp_invoke_ollama_model stored procedure to calculate embeddings locally with a compatible endpoint.

   ### Example for Local Embeddings:

```sql
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

SELECT 
    @vector AS value, 
    @vector.Size() AS size, 
    CAST(@vector AS NVARCHAR(MAX)) AS text;
```


3. **Vector Calculations**:
   - Deploy the `Vector` UDT to your SQL Server.
   - Use the `VECTOR_DISTANCE` function to calculate distances between vectors.
   - Example SQL query:
```sql
DECLARE @v1 Vector = '[1.0, 2.0, 3.0]';
DECLARE @v2 Vector = '[4.0, 5.0, 6.0]';
SELECT dbo.VectorDistance('euclidean', @v1, @v2) AS Distance;
```

## Pending Work
- Optimize performance for large-scale use cases.

## Disclaimer

This repository is for educational and development purposes only. It is not designed for use in production environments. Use it at your own risk.

## License

This project is licensed under the MIT License. See the `LICENSE` file for details.
