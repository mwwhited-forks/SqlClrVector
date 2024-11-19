
DROP TABLE IF EXISTS player_positions;
GO

CREATE TABLE player_positions (
  player_name NVARCHAR(100) NOT NULL,
  position VECTOR NOT NULL
);

INSERT INTO player_positions VALUES
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
    player_name
    from player_positions
    where player_name in ('Lamine Yamal', 'Morata', 'Rodri', 'Dani Carvajal')
    order by cosine
GO

declare @morata_position VECTOR = '[45, 30]';
SELECT 
    dbo.VECTOR_DISTANCE('euclidean', position, @morata_position) euclidean,
    dbo.VECTOR_DISTANCE('cosine', position, @morata_position) cosine,
    dbo.VECTOR_DISTANCE('dot', position, @morata_position) negative_dot_product,
    dbo.VECTOR_DISTANCE('manhattan', position, @morata_position) manhattan,
    player_name
    from player_positions
    where player_name in 
    ('Lamine Yamal', 'Morata', 'Rodri', 'Dani Carvajal');

