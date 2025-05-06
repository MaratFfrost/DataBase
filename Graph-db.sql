USE master;
GO

IF EXISTS (SELECT * FROM sys.databases WHERE name = 'UkrainianCities')
BEGIN
    ALTER DATABASE UkrainianCities SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE UkrainianCities;
END;
GO

CREATE DATABASE UkrainianCities;
GO

USE UkrainianCities;
GO

-- 1. Создание таблиц узлов
CREATE TABLE UkrainianRegions (
    RegionID INT PRIMARY KEY,
    RegionName NVARCHAR(100) NOT NULL,
    AreaSqKm INT,
    Population INT,
    EstablishmentYear INT
) AS NODE;

CREATE TABLE UkrainianCities (
    CityID INT PRIMARY KEY,
    CityName NVARCHAR(100) NOT NULL,
    Population INT,
    IsRegionalCenter BIT DEFAULT 0,
    Latitude DECIMAL(9,6),
    Longitude DECIMAL(9,6)
) AS NODE;

CREATE TABLE Landmarks (
    LandmarkID INT PRIMARY KEY,
    LandmarkName NVARCHAR(200) NOT NULL,
    Type NVARCHAR(50) NOT NULL,
    ConstructionYear INT,
    Description NVARCHAR(MAX)
) AS NODE;

-- 2. Создание таблиц рёбер
CREATE TABLE CityInRegion (
    DistanceToRegionalCenterKM INT
) AS EDGE;

CREATE TABLE ConnectedByRoad (
    RoadType NVARCHAR(50),
    DistanceKM INT NOT NULL,
    TravelTimeHrs DECIMAL(4,2)
) AS EDGE;

CREATE TABLE LandmarkInCity (
    IsUNESCOHeritage BIT DEFAULT 0,
    EntranceFee DECIMAL(10,2)
) AS EDGE;

-- 3. Заполнение таблиц узлов
INSERT INTO UkrainianRegions VALUES
(1, N'Киевская', 28131, 1764300, 1932),
(2, N'Львовская', 21833, 2511000, 1939),
(3, N'Одесская', 33314, 2377000, 1932),
(4, N'Харьковская', 31415, 2654000, 1932),
(5, N'Днепропетровская', 31914, 3176000, 1932),
(6, N'Закарпатская', 12777, 1256000, 1946),
(7, N'Ивано-Франковская', 13928, 1373000, 1939),
(8, N'Тернопольская', 13823, 1042000, 1939),
(9, N'Херсонская', 28461, 1026000, 1944),
(10, N'Черниговская', 31865, 1005000, 1932),
(11, N'Полтавская', 28748, 1401000, 1932);

INSERT INTO UkrainianCities VALUES
(1, N'Киев', 2967000, 1, 50.4501, 30.5234),
(2, N'Львов', 724000, 1, 49.8397, 24.0297),
(3, N'Одесса', 1015000, 1, 46.4825, 30.7233),
(4, N'Харьков', 1433000, 1, 49.9935, 36.2304),
(5, N'Днепр', 984000, 1, 48.4647, 35.0462),
(6, N'Ужгород', 115000, 1, 48.6208, 22.2879),
(7, N'Ивано-Франковск', 238000, 1, 48.9226, 24.7111),
(8, N'Тернополь', 225000, 1, 49.5535, 25.5948),
(9, N'Херсон', 289000, 1, 46.6354, 32.6169),
(10, N'Чернигов', 286000, 1, 51.4982, 31.2893),
(11, N'Полтава', 284000, 1, 49.5883, 34.5514),
(12, N'Бровары', 109000, 0, 50.5114, 30.7905),
(13, N'Трускавец', 28000, 0, 49.2815, 23.5060),
(14, N'Черноморск', 59000, 0, 46.3049, 30.6546),
(15, N'Кривой Рог', 619000, 0, 47.9105, 33.3918);

INSERT INTO Landmarks VALUES
(1, N'Киево-Печерская лавра', N'Религиозный', 1051, N'Один из первых монастырей на Руси'),
(2, N'Рынок "Вернисаж"', N'Культурный', 1980, N'Известный рынок народного искусства'),
(3, N'Одесский оперный театр', N'Культурный', 1887, N'Один из красивейших театров Европы'),
(4, N'Площадь Свободы', N'Исторический', 1925, N'Центральная площадь Харькова'),
(5, N'Монастырь в Почаеве', N'Религиозный', 1240, N'Крупнейший православный монастырь'),
(6, N'Ужгородский замок', N'Исторический', 1320, N'Средневековый замок в Ужгороде'),
(7, N'Ратуша во Львове', N'Архитектурный', 1835, N'Главная площадь Львова'),
(8, N'Херсонская крепость', N'Исторический', 1778, N'Остатки старинной крепости'),
(9, N'Софиевский собор', N'Религиозный', 1037, N'Древний собор в Чернигове'),
(10, N'Круглый двор', N'Архитектурный', 1800, N'Уникальное сооружение в Полтаве'),
(11, N'Тоннель любви', N'Природный', NULL, N'Романтическое место под Ровно'),
(12, N'Аскания-Нова', N'Природный', 1828, N'Знаменитый биосферный заповедник');

-- 4. Заполнение таблиц рёбер
-- Связи городов с областями
INSERT INTO CityInRegion ($from_id, $to_id, DistanceToRegionalCenterKM)
SELECT 
    (SELECT $node_id FROM UkrainianCities WHERE CityID = c.CityID),
    (SELECT $node_id FROM UkrainianRegions WHERE RegionID = c.RegionID),
    c.Distance
FROM (VALUES
    (1, 1, 0), (2, 2, 0), (3, 3, 0), (4, 4, 0), (5, 5, 0),
    (6, 6, 0), (7, 7, 0), (8, 8, 0), (9, 9, 0), (10, 10, 0),
    (11, 11, 0), (12, 1, 20), (13, 2, 100), (14, 3, 45), (15, 5, 150)
) AS c(CityID, RegionID, Distance);

-- Связи городов дорогами
INSERT INTO ConnectedByRoad ($from_id, $to_id, RoadType, DistanceKM, TravelTimeHrs)
SELECT 
    (SELECT $node_id FROM UkrainianCities WHERE CityID = r.CityFrom),
    (SELECT $node_id FROM UkrainianCities WHERE CityID = r.CityTo),
    r.RoadType, r.Distance, r.Time
FROM (VALUES
    (1, 2, N'Автомагистраль', 540, 6.5), (1, 3, N'Автомагистраль', 480, 6.0),
    (1, 4, N'Автомагистраль', 480, 5.5), (1, 5, N'Автомагистраль', 480, 5.5),
    (2, 6, N'Областная', 120, 2.0), (2, 7, N'Автомагистраль', 130, 2.0),
    (3, 9, N'Автомагистраль', 200, 3.0), (4, 5, N'Автомагистраль', 220, 3.5),
    (5, 15, N'Автомагистраль', 150, 2.5), (6, 7, N'Горная', 180, 3.5),
    (7, 8, N'Автомагистраль', 130, 2.0), (8, 10, N'Автомагистраль', 320, 4.5),
    (9, 12, N'Областная', 45, 1.0), (10, 11, N'Автомагистраль', 180, 2.5)
) AS r(CityFrom, CityTo, RoadType, Distance, Time);

-- Связи достопримечательностей с городами
INSERT INTO LandmarkInCity ($from_id, $to_id, IsUNESCOHeritage, EntranceFee)
SELECT 
    (SELECT $node_id FROM Landmarks WHERE LandmarkID = l.LandmarkID),
    (SELECT $node_id FROM UkrainianCities WHERE CityID = l.CityID),
    l.UNESCO, l.Fee
FROM (VALUES
    (1, 1, 1, 50.00), (2, 2, 0, 0.00), (3, 3, 1, 100.00),
    (4, 4, 0, 0.00), (5, 8, 0, 20.00), (6, 6, 0, 30.00),
    (7, 2, 0, 0.00), (8, 9, 0, 15.00), (9, 10, 1, 40.00),
    (10, 11, 0, 10.00), (11, 7, 0, 0.00), (12, 9, 0, 50.00)
) AS l(LandmarkID, CityID, UNESCO, Fee);

-- 5. Примеры запросов с использованием MATCH
-- 1. Найти все города в Киевской области
SELECT c.CityName, c.Population
FROM UkrainianCities c, CityInRegion e, UkrainianRegions r
WHERE MATCH(c-(e)->r)
AND r.RegionName = N'Киевская';

-- 2. Найти маршруты из Киева в другие областные центры
SELECT c2.CityName, e.DistanceKM, e.TravelTimeHrs
FROM UkrainianCities c1, ConnectedByRoad e, UkrainianCities c2
WHERE MATCH(c1-(e)->c2)
AND c1.CityName = N'Киев'
AND c2.IsRegionalCenter = 1;

-- 3. Найти все достопримечательности ЮНЕСКО в Украине
SELECT l.LandmarkName, l.Type, c.CityName
FROM Landmarks l, LandmarkInCity e, UkrainianCities c
WHERE MATCH(l-(e)->c)
AND e.IsUNESCOHeritage = 1;

-- 4. Найти города, соединенные автомагистралями с Львовом
SELECT c2.CityName, e.DistanceKM
FROM UkrainianCities c1, ConnectedByRoad e, UkrainianCities c2
WHERE MATCH(c1-(e)->c2)
AND c1.CityName = N'Львов'
AND e.RoadType = N'Автомагистраль';

-- 5. Найти все достопримечательности в городах с населением > 500000
SELECT l.LandmarkName, c.CityName, c.Population
FROM Landmarks l, LandmarkInCity e, UkrainianCities c
WHERE MATCH(l-(e)->c)
AND c.Population > 500000
ORDER BY c.Population DESC;




--6 пункт
-- -- Найти все пути из Киева в другие города 
SELECT 
    N'Киев' AS StartCity,
    STRING_AGG(EndCity.CityName, ' -> ') WITHIN GROUP (GRAPH PATH) AS Path,
    SUM(road.DistanceKM) WITHIN GROUP (GRAPH PATH) AS TotalDistance,
    COUNT(EndCity.CityName) WITHIN GROUP (GRAPH PATH) AS ConnectionCount
FROM
    UkrainianCities AS StartCity,
    UkrainianCities FOR PATH AS EndCity,
    ConnectedByRoad FOR PATH AS road
WHERE
    MATCH(SHORTEST_PATH(StartCity(-(road)->EndCity)+))
    AND StartCity.CityName = N'Киев'
ORDER BY
    ConnectionCount, TotalDistance;


-- Найти пути из Одессы с 1-2 пересадками
SELECT 
    N'Одесса' AS StartCity,
    STRING_AGG(EndCity.CityName, ' -> ') WITHIN GROUP (GRAPH PATH) AS Path,
    SUM(road.DistanceKM) WITHIN GROUP (GRAPH PATH) AS TotalDistance,
    COUNT(EndCity.CityName) WITHIN GROUP (GRAPH PATH) AS ConnectionCount
FROM
    UkrainianCities AS StartCity,
    UkrainianCities FOR PATH AS EndCity,
    ConnectedByRoad FOR PATH AS road
WHERE
    MATCH(SHORTEST_PATH(StartCity(-(road)->EndCity){1,2}))
    AND StartCity.CityName = N'Одесса'
ORDER BY
    ConnectionCount, TotalDistance;