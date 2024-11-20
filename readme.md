# Example Code for REST API Calls and Vector Calculations in SQL Server

This repository contains example code for demonstrating REST API integration and vector manipulation within a SQL Server context. **Note:** This is development-level code and is **not intended for production use**.

## Features

1. **REST API Integration**:
   - `myRestEndpoint.cs`: Provides a SQL CLR stored procedure to invoke REST APIs from SQL Server. Supports:
     - GET and POST methods.
     - Custom headers in JSON format.
     - Payload handling for POST requests.

2. **Vector Type and Operations**:
   - `myVector.cs`: Implements a SQL CLR User-Defined Type (UDT) for vectors, allowing:
     - Serialization and deserialization of vectors.
     - Support for multiple distance metrics (e.g., cosine, Euclidean, Manhattan).
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
- SQL Server 2020 or newer with CLR integration enabled.
- The UDF needs EXTERNAL_ACCESS. SQL CLR in linux supports only SAFE assemblies [link](https://learn.microsoft.com/en-us/sql/language-extensions/concepts/compare-extensibility-to-clr?view=sql-server-ver16).

## Limitations
- Vector type:
  - Cannot define vector size during table creation.
  - Requires `dbo.` prefix when invoking vector functions.
- Performance of REST API and vector operations in production scenarios has not been analyzed.
- REST API integration disables certificate validation in testing for convenience (should not be used in production).

## Usage

1. **REST API Calls**:
   - Deploy the `myRestEndpoint` assembly to your SQL Server.
   - Use the `InvokeRestEndpoint` stored procedure to call REST APIs directly from SQL Server.
   - Example SQL query:
```sql
EXEC dbo.sp_invoke_external_rest_endpoint2
@url = @url,
@method = 'POST',   
@payload = @payload,   
@headers = '{"Content-Type":"application/json", "api-key":"zzzzzz"}',
@response = @response OUTPUT;
```

2. **Vector Calculations**:
   - Deploy the `Vector` UDT to your SQL Server.
   - Use the `VECTOR_DISTANCE` function to calculate distances between vectors.
   - Example SQL query:
```sql
DECLARE @v1 Vector = '[1.0, 2.0, 3.0]';
DECLARE @v2 Vector = '[4.0, 5.0, 6.0]';
SELECT dbo.VectorDistance('euclidean', @v1, @v2) AS Distance;
```

## Pending Work
- Add support for local embeddings in vector calculations.
- Optimize performance for large-scale use cases.

## Disclaimer

This repository is for educational and development purposes only. It is not designed for use in production environments. Use it at your own risk.

## License

This project is licensed under the MIT License. See the `LICENSE` file for details.
