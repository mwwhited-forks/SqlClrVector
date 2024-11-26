/*
  This script performs the following operations:

  1. Drops the table `player_positions` if it exists.
  2. Creates a new table `player_positions` with columns:
     - `id`: Primary key with auto-increment.
     - `player_name`: NVARCHAR(100) to store the player's name.
     - `position`: VECTOR to store the player's position.
     - `filler`: CHAR(100) with a default value of 'filler'.
  3. Inserts sample data into the `player_positions` table.
  4. Selects all columns from `player_positions` and casts the `position` column to VARCHAR(MAX).
  5. Declares a variable `@morata_position` with Morata's position and calculates the distance between Morata and selected players using Euclidean, Cosine, Dot Product, and Manhattan similarity measures.
  6. Enables the execution plan display with `SET SHOWPLAN_TEXT ON`.
  7. Creates a Common Table Expression (CTE) `morata` to select Morata's position and compares it with selected players using the same similarity measures.
  8. Creates a non-clustered index `nci_player_position` on `player_name` and includes the `position` column.
  9. Repeats the CTE query to compare Morata's position with selected players, utilizing the newly created index.
  10. Disables the execution plan display with `SET SHOWPLAN_TEXT OFF`.

  The script includes comments and execution plans to analyze the performance of the queries.
*/

DROP TABLE IF EXISTS player_positions;
GO

CREATE TABLE player_positions (
  id INT IDENTITY(1,1) PRIMARY KEY,
  player_name NVARCHAR(100) NOT NULL,
  position VECTOR NOT NULL,
  filler CHAR(100) DEFAULT 'filler'
);
GO

INSERT INTO player_positions (player_name, position) 
VALUES
('Unai Simón', '[5, 30]'),

('Dani Carvajal', '[20, 10]'),
('Aymeric Laporte', '[15, 20]'),
('Robin Le Normand', '[15, 40]'),
('Marc Cucurella', '[20, 50]'),

('Rodri', '[25, 30]'),
('Fabián', '[30, 40]'),
('Dani Olmo', '[30, 20]'),

('Lamine Yamal', '[40, 13]'),
('Morata', '[45, 30]'),
('Nico Williams', '[40, 47]');
GO

SELECT *, cast(position as varchar(max)) FROM player_positions;

-- Calculate the distance between two players using the Euclidean, Cosine, and Dot Product similarity measures
-- pick Morata positition and compare with the rest of the players
declare @morata_position VECTOR = '[45, 30]';
SELECT 
    CAST(dbo.VECTOR_DISTANCE('euclidean', @morata_position, position) AS DECIMAL(10,3)) AS euclidean,
    CAST(dbo.VECTOR_DISTANCE('cosine', @morata_position, position) AS DECIMAL(10,3)) AS cosine,
    dbo.VECTOR_DISTANCE('dot', @morata_position, position) AS negative_dot_product,
    dbo.VECTOR_DISTANCE('manhattan', position, @morata_position) manhattan,
    player_name
    from player_positions
    where player_name in ('Lamine Yamal', 'Morata', 'Rodri', 'Dani Carvajal')
    order by cosine
GO

-- query that finds morata position compared to a few players
-- using EUCLIDEAN, COSINE, DOT PRODUCT AND MANHATTAN search algorithms
-- exec plan
SET SHOWPLAN_TEXT ON
GO
with morata as (
    select 
        player_name,
        position
    from player_positions
    where player_name = 'Morata'
)
SELECT 
    CAST(dbo.VECTOR_DISTANCE('euclidean', morata.[position], p.position) AS DECIMAL(10,3)) AS euclidean,
    CAST(dbo.VECTOR_DISTANCE('cosine', morata.[position], p.position) AS DECIMAL(10,3)) AS cosine,
    CAST(dbo.VECTOR_DISTANCE('dot', morata.[position], p.position) AS DECIMAL(10,3)) AS dot_product,
    CAST(dbo.VECTOR_DISTANCE('manhattan', morata.[position], p.position) AS DECIMAL(10,3)) AS manhattan,
    p.player_name p1, morata.player_name p2
FROM player_positions p, morata
WHERE p.player_name IN ('Lamine Yamal', 'Rodri', 'Dani Carvajal')
or p.player_name = morata.player_name
ORDER BY cosine;

/*
  |--Sort(ORDER BY:([Expr1004] ASC))
       |--Compute Scalar(DEFINE:([Expr1003]=CONVERT(decimal(10,3),[VERNE].[dbo].[VECTOR_DISTANCE](CONVERT_IMPLICIT(nvarchar(max),'euclidean',0),[VERNE].[dbo].[player_positions].[position],[VERNE].[dbo].[player_positions].[position] as [p].[position]),0), [Expr1004]=CONVERT(decimal(10,3),[VERNE].[dbo].[VECTOR_DISTANCE](CONVERT_IMPLICIT(nvarchar(max),'cosine',0),[VERNE].[dbo].[player_positions].[position],[VERNE].[dbo].[player_positions].[position] as [p].[position]),0), [Expr1005]=CONVERT(decimal(10,3),[VERNE].[dbo].[VECTOR_DISTANCE](CONVERT_IMPLICIT(nvarchar(max),'dot',0),[VERNE].[dbo].[player_positions].[position],[VERNE].[dbo].[player_positions].[position] as [p].[position]),0), [Expr1006]=CONVERT(decimal(10,3),[VERNE].[dbo].[VECTOR_DISTANCE](CONVERT_IMPLICIT(nvarchar(max),'manhattan',0),[VERNE].[dbo].[player_positions].[position],[VERNE].[dbo].[player_positions].[position] as [p].[position]),0)))
            |--Nested Loops(Inner Join, WHERE:([VERNE].[dbo].[player_positions].[player_name] as [p].[player_name]=N'Dani Carvajal' OR [VERNE].[dbo].[player_positions].[player_name] as [p].[player_name]=N'Rodri' OR [VERNE].[dbo].[player_positions].[player_name] as [p].[player_name]=N'Lamine Yamal' OR [VERNE].[dbo].[player_positions].[player_name] as [p].[player_name]=[VERNE].[dbo].[player_positions].[player_name]))
                 |--Clustered Index Scan(OBJECT:([VERNE].[dbo].[player_positions].[PK__player_p__3213E83FAEE6B1F9]), WHERE:([VERNE].[dbo].[player_positions].[player_name]=N'Morata'))
                 |--Clustered Index Scan(OBJECT:([VERNE].[dbo].[player_positions].[PK__player_p__3213E83FAEE6B1F9] AS [p]))
*/

GO
SET SHOWPLAN_TEXT OFF
GO

-- non clustered index on player_name and Vector!
CREATE NONCLUSTERED index nci_player_position 
ON player_positions (player_name)
INCLUDE (position);
GO

SET SHOWPLAN_TEXT ON
GO
with morata as (
    select 
        player_name,
        position
    from player_positions
    where player_name = 'Morata'
)
SELECT 
    CAST(dbo.VECTOR_DISTANCE('euclidean', morata.[position], p.position) AS DECIMAL(10,3)) AS euclidean,
    CAST(dbo.VECTOR_DISTANCE('cosine', morata.[position], p.position) AS DECIMAL(10,3)) AS cosine,
    CAST(dbo.VECTOR_DISTANCE('dot', morata.[position], p.position) AS DECIMAL(10,3)) AS dot_product,
    CAST(dbo.VECTOR_DISTANCE('manhattan', morata.[position], p.position) AS DECIMAL(10,3)) AS manhattan,
    p.player_name p1, morata.player_name p2
FROM player_positions p, morata
WHERE p.player_name IN ('Lamine Yamal', 'Rodri', 'Dani Carvajal')
or p.player_name = morata.player_name
ORDER BY cosine;

GO
SET SHOWPLAN_TEXT OFF
GO

/*
  |--Sort(ORDER BY:([Expr1004] ASC))
       |--Compute Scalar(DEFINE:([Expr1003]=CONVERT(decimal(10,3),[VERNE].[dbo].[VECTOR_DISTANCE](CONVERT_IMPLICIT(nvarchar(max),'euclidean',0),[VERNE].[dbo].[player_positions].[position],[VERNE].[dbo].[player_positions].[position] as [p].[position]),0), [Expr1004]=CONVERT(decimal(10,3),[VERNE].[dbo].[VECTOR_DISTANCE](CONVERT_IMPLICIT(nvarchar(max),'cosine',0),[VERNE].[dbo].[player_positions].[position],[VERNE].[dbo].[player_positions].[position] as [p].[position]),0), [Expr1005]=CONVERT(decimal(10,3),[VERNE].[dbo].[VECTOR_DISTANCE](CONVERT_IMPLICIT(nvarchar(max),'dot',0),[VERNE].[dbo].[player_positions].[position],[VERNE].[dbo].[player_positions].[position] as [p].[position]),0), [Expr1006]=CONVERT(decimal(10,3),[VERNE].[dbo].[VECTOR_DISTANCE](CONVERT_IMPLICIT(nvarchar(max),'manhattan',0),[VERNE].[dbo].[player_positions].[position],[VERNE].[dbo].[player_positions].[position] as [p].[position]),0)))
            |--Nested Loops(Inner Join, WHERE:([VERNE].[dbo].[player_positions].[player_name] as [p].[player_name]=N'Dani Carvajal' OR [VERNE].[dbo].[player_positions].[player_name] as [p].[player_name]=N'Rodri' OR [VERNE].[dbo].[player_positions].[player_name] as [p].[player_name]=N'Lamine Yamal' OR [VERNE].[dbo].[player_positions].[player_name] as [p].[player_name]=[VERNE].[dbo].[player_positions].[player_name]))
                 |--Index Seek(OBJECT:([VERNE].[dbo].[player_positions].[nci_player_position]), SEEK:([VERNE].[dbo].[player_positions].[player_name]=N'Morata') ORDERED FORWARD)
                 |--Index Scan(OBJECT:([VERNE].[dbo].[player_positions].[nci_player_position] AS [p]))
*/
