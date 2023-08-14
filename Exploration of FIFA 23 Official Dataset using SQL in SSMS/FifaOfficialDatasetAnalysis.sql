-- Preprocessing and Data Cleaning

-- Showing the column names
SELECT COLUMN_NAME
FROM FifaOfficialDataset.INFORMATION_SCHEMA.COLUMNS


-- Removing unnecessary columns Photo, Flag, and Club Logo since they're of no use
ALTER TABLE FIFA23_official_data
DROP COLUMN Photo, Flag, [Club Logo]



-- Checking if the [Best Overall Rating] has any values other than NULL and extracting them
UPDATE FIFA23_official_data
SET [Best Overall Rating] = SUBSTRING([Best Overall Rating], CHARINDEX('>', [Best Overall Rating]) + 1, LEN([Best Overall Rating]) - CHARINDEX('>', [Best Overall Rating]) - CHARINDEX('<', REVERSE([Best Overall Rating])))
WHERE [Best Overall Rating] LIKE '<span class="bp3-tag p p-%">%';



-- Formatting the Value, Wage, and Release Clause columns by removing the currency symbol and unit
UPDATE FIFA23_official_data
SET Value = REPLACE(Value, N'€', ''),
    Wage = REPLACE(Wage, N'€', ''),
    [Release Clause] = REPLACE([Release Clause], N'€', '')
WHERE Value LIKE N'%€%' OR Wage LIKE N'%€%' OR [Release Clause] LIKE N'%€%';



-- Removing NaN values from [Release Clause] For converting the values to Whole numbers  
UPDATE FIFA23_official_data
SET [Release Clause] = 0
WHERE [Release Clause] = 'Nan'



UPDATE FIFA23_official_data
SET Value = CASE
                WHEN RIGHT(Value, 1) = 'M' THEN CAST(REPLACE(Value, 'M', '') AS FLOAT) * 1000000
                WHEN RIGHT(Value, 1) = 'K' THEN CAST(REPLACE(Value, 'K', '') AS FLOAT) * 1000
                ELSE CAST(Value AS FLOAT)
            END,
    Wage = CASE
               WHEN RIGHT(Wage, 1) = 'M' THEN CAST(REPLACE(Wage, 'M', '') AS FLOAT) * 1000000
               WHEN RIGHT(Wage, 1) = 'K' THEN CAST(REPLACE(Wage, 'K', '') AS FLOAT) * 1000
               ELSE CAST(Wage AS FLOAT)
           END,
    [Release Clause] = CASE
                           WHEN RIGHT([Release Clause], 1) = 'M' THEN CAST(REPLACE([Release Clause], 'M', '') AS FLOAT) * 1000000
                           WHEN RIGHT([Release Clause], 1) = 'K' THEN CAST(REPLACE([Release Clause], 'K', '') AS FLOAT) * 1000
                           ELSE CAST([Release Clause] AS FLOAT)
                       END;



-- Formatting the Position column by removing the HTML tags
UPDATE FIFA23_official_data
SET Position = RIGHT(Position, CHARINDEX('>', REVERSE(Position)) - 1)
WHERE Position LIKE '%>%';



-- Formatting the Loaned From column by removing the HTML tags
UPDATE FIFA23_official_data
SET [Loaned From] = SUBSTRING([Loaned From], CHARINDEX('>', [Loaned From]) + 1, LEN([Loaned From]) - CHARINDEX('>', [Loaned From]) - CHARINDEX('<', REVERSE([Loaned From])));



-- Converting all contract dates to years
UPDATE FIFA23_official_data
SET [Contract Valid Until] = YEAR(CONVERT(DATE, CONVERT(VARCHAR(10), [Contract Valid Until]), 120))
WHERE ISDATE([Contract Valid Until]) = 1;



-- Changing the name of the Height and Weeight Columns and changing the values to Float
EXEC sp_rename 'FIFA23_official_data.Height', [Height in cm], 'COLUMN';
EXEC sp_rename 'FIFA23_official_data.Weight', [Weight in kg], 'COLUMN';

UPDATE FIFA23_official_data
SET [Height in cm] = REPLACE([Height in cm], 'cm', ''),
    [Weight in kg] = REPLACE([Weight in kg], 'kg', '');

ALTER TABLE FIFA23_official_data
ALTER COLUMN [Height in cm] FLOAT;
ALTER TABLE FIFA23_official_data
ALTER COLUMN [Weight in kg] FLOAT;


-- Showing the outcome
SELECT * 
FROM FIFA23_official_data









--QUESTIONS AND ANSWERS


-- How many players are there in the dataset?
SELECT COUNT(*) AS 'Number of Players'
FROM FIFA23_official_data;



--SELECT COUNT(DISTINCT Nationality) 
SELECT COUNT(DISTINCT Nationality) AS 'Number of Countries'
FROM FIFA23_official_data
WHERE Nationality IS NOT NULL 



-- What is the average age of the players?
SELECT AVG(Age) AS 'Average Age'
FROM FIFA23_official_data;



-- Who is the oldest player in the dataset and which club does he belong to?
SELECT TOP 1 Name, Age, Club
FROM FIFA23_official_data
ORDER BY Age DESC;



-- Who is the youngest player in the dataset and which club does he belong to?
SELECT TOP 1 Name, Age, Club
FROM FIFA23_official_data
ORDER BY Age ASC;



--Which player has the highest wage in the dataset?
SELECT TOP 1 Name, Wage/1000 as [Wage in K]
FROM FIFA23_official_data
ORDER BY Wage DESC



--Which player has the highest potential in the dataset?
SELECT TOP 1 Name, Potential 
FROM FIFA23_official_data 
ORDER BY Potential DESC 



-- Which club has the most players with an overall rating of 80 or above?
SELECT TOP 5 Club, COUNT(*) AS 'Number of Players with Overall Rating >= 80'
FROM FIFA23_official_data
WHERE Overall >= 80
GROUP BY Club
ORDER BY COUNT(*) DESC;



-- What is the average age of the players in each position?
SELECT Position, ROUND(AVG(Age), 0) AS 'Average Age'
FROM FIFA23_official_data
GROUP BY Position
ORDER BY 'Average Age' DESC;



-- Who is the youngest player with a potential rating of 85 or higher?
SELECT TOP 1 Name, Age, Potential
FROM FIFA23_official_data
WHERE Potential >= 85
ORDER BY Age ASC;



-- Distribution of foots and percentage?
SELECT [Preferred Foot], COUNT(*) AS 'Number of Players', ROUND((COUNT(*) * 100.0 / (SELECT COUNT(*) FROM FIFA23_official_data)), 1) AS 'Percentage'
FROM FIFA23_official_data
GROUP BY [Preferred Foot];



-- How many players have a preferred foot of left and a skill moves of 5?
SELECT COUNT(*) AS 'Number of Players with Preferred Foot Left and Skill Moves 5'
FROM FIFA23_official_data
WHERE [Preferred Foot] = 'Left' AND [Skill Moves] = 5;



-- Which nationality has the highest number of players in the dataset?
SELECT TOP 1 Nationality, COUNT(*) AS 'Number of Players'
FROM FIFA23_official_data
GROUP BY Nationality
ORDER BY COUNT(*) DESC;



--What is the most common position among players in the dataset?
SELECT TOP 3 Position, COUNT(*) as Count
FROM FIFA23_official_data
GROUP BY Position



-- Which body types are the most common among the players?
SELECT TOP 3 [Body Type], COUNT(*) AS 'Number of Players'
FROM FIFA23_official_data
GROUP BY [Body Type]
ORDER BY COUNT(*) DESC;



-- What is the distribution of the international reputation ratings among the players?
SELECT [International Reputation], COUNT(*) AS 'Number of Players'
FROM FIFA23_official_data
GROUP BY [International Reputation]
ORDER BY COUNT(*);



-- Which club has the highest average overall rating among its players?
SELECT TOP 1 Club, AVG(Overall) AS 'Average Overall Rating'
FROM FIFA23_official_data
GROUP BY Club
ORDER BY AVG(Overall) DESC;



-- Who is the player with the highest special rating in the dataset?
SELECT TOP 1 Name, Special AS 'Highest Special Rating'
FROM FIFA23_official_data
ORDER BY Special DESC;

