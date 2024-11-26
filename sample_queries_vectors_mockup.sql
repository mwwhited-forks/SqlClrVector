/*

-- This script demonstrates the usage of vector data types and functions in SQL.
-- It includes examples of declaring and setting vector variables, casting vectors,
-- and calculating the distance between vectors using different distance metrics.

-- Key differences highlighted:
-- 1. Vector size cannot be defined in value definition or table creation.
-- 2. SQL Azure returns the value as 'casted_value' by default.
-- 3. 'dbo.' prefix is required when calling functions.
-- 4. 'manhattan' distance metric is implemented (not available in SQL Azure).

-- Example 1: Declaring and setting a vector variable.
-- Example 2: Casting a vector to nvarchar and retrieving its size.
-- Example 3: Calculating the Euclidean distance between two vectors using dbo.VECTOR_DISTANCE function.
*/

-- difference: cannot define the vector size in value definition / table creation
DECLARE @v Vector;
SET @v = CAST('[1.0, 2.0, 3.0]' AS Vector);

-- difference: SQL Azure returns the value as casted_value by default
SELECT @v value, cast(@v as nvarchar(max)) casted_value, @v.Size();
GO


DECLARE @v1 Vector = CAST('[1, 2, 3]' AS Vector);
DECLARE @v2 Vector = CAST('[4, 5, 6]' AS Vector);

-- difference: dbo. is required when calling the function
-- difference: manhattan is implemented (in SQL Azure it is not implemented)
SELECT dbo.VECTOR_DISTANCE('euclidean', @v1, @v2) AS Distance;
GO

