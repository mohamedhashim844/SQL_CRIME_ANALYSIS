
--##This data is collected on the basis of LAPD radio comms and Investigation done by them after the crime is reported.
 --It contains crime data from 2020 to present(Feb 2022)

--### SELECTING DATA
SELECT  *  
FROM losanglos_crime.dbo.crime_in_la
ORDER BY [DATE OCC]

--### CLEANING DATA

--REMOVE THE DUPLICATES BY USING CTE TABLE

WITH rownumCTE AS
(SELECT * , ROW_NUMBER()
OVER (PARTITION BY [DATE OCC],
                    [TIME OCC],
					AREA ,
					mocodes,
					location,
					lat,
					lon,
					[vict age],
					[vict sex]
					ORDER BY 
					DR_NO) row_num
FROM losanglos_crime.dbo.crime_in_la
)
DELETE
FROM rownumCTE
WHERE row_num >1

--------------------------------------------------

--## FORMATING TIME COLUMN


ALTER table losanglos_crime.dbo.crime_in_la
ADD time_occ time

UPDATE losanglos_crime.dbo.crime_in_la
SET time_occ = cast([TIME OCC] AS time)

SELECT  *  
FROM losanglos_crime.dbo.crime_in_la
ORDER BY [vict age]

ALTER table losanglos_crime.dbo.crime_in_la
DROP COLUMN [TIME OCC]

-----------------------------------------------------------

--## UPDATE  VICT AGE COLUMN 

WITH rowageCTE AS
(SELECT * , ROW_NUMBER()
OVER (PARTITION BY [DATE OCC],
					AREA ,
					mocodes,
					location,
					lat,
					lon,
					[vict age],
					[vict sex]
					ORDER BY 
					[vict age]) row_num
FROM losanglos_crime.dbo.crime_in_la
)
DELETE
FROM rowageCTE
WHERE  [vict age]=0

UPDATE losanglos_crime.dbo.crime_in_la
SET [vict age] = 1
WHERE [vict age] = -1 

-- cleaning unlogical values from victom age like 0
-- and updating values with index -1 to 1



--## CREATE AGE GROUP COLUMN 

 ALTER TABLE losanglos_crime.dbo.crime_in_la
 ADD age_group VARCHAR(50) 

 UPDATE losanglos_crime.dbo.crime_in_la
 SET age_group =  
  CASE
   WHEN [vict age] BETWEEN 0 AND 18 THEN '-18'
   WHEN [vict age] BETWEEN 18 AND 24 THEN '18-24'
   WHEN [vict age] BETWEEN 25 AND 34THEN '25-34'
   WHEN [vict age] BETWEEN 34 AND 50THEN '34-50'
   WHEN [vict age] BETWEEN 50 AND 100 THEN '+50'
 ELSE NULL END 
 
 SELECT  [crm cd desc] , time_occ 
FROM losanglos_crime.dbo.crime_in_la
ORDER BY time_occ

---------------------------------------------------

--## AREA WITH HIGEST CRIME RATE

SELECT distinct([AREA NAME]) , count([AREA NAME]) AS COUNT
FROM losanglos_crime.dbo.crime_in_la
GROUP BY [AREA NAME]
ORDER BY count([AREA NAME]) DESC

--(CENTRAL) AND (77TH STREET) ARE THE MOST DANGOURS AREAS OF THE CITY 

--## TIME WHEN CRIMS MOSTELY HAPPEND 


SELECT distinct(DATEPART(HOUR ,time_occ)) , count(DATEPART(HOUR ,time_occ)) AS COUNT
FROM losanglos_crime.dbo.crime_in_la
GROUP BY DATEPART(HOUR ,time_occ)
ORDER BY count(DATEPART(HOUR ,time_occ)) DESC

----------------------------------------------

--## WHAT IS MOST CRIMES OCCURRENCE AND IN WHAT TIME

SELECT [crm cd desc] , DATEPART(HOUR ,time_occ) AS hour ,COUNT(*) as count
FROM losanglos_crime.dbo.crime_in_la
GROUP BY [crm cd desc] ,DATEPART(HOUR ,time_occ)
ORDER BY COUNT(*) DESC , DATEPART(HOUR ,time_occ)

--TOP 3  MOST CRIMES OCCURRENCE IS THEFT OF IDENTITY , BURGLARY FROM VEHICLE 
--AND BATTERY - SIMPLE ASSAULT
--- THEFT OF IDENTITY ALWAYS HAPPEND ON 12PM OR IN THE MID-NIGHT
--- BURGLARY FROM VEHICLE MOSTLY HAPPEND IN THE NIGHT AFTER 6PM
--- BATTERY - SIMPLE ASSAULT MOSTLY HAPPEND IN DAYLIGHT OR EVENING 

--------------------------------------------------------

--## Where Does Rape Occur Most Often? Which Gender Is More Likely To Be Raped?

SELECT [crm cd desc] , [premis desc] ,[vict sex], COUNT(*) AS COUNT 
FROM  losanglos_crime.dbo.crime_in_la
WHERE [crm cd desc] = 'RAPE, FORCIBLE'
GROUP BY [crm cd desc] , [premis desc] , [vict sex]
ORDER BY  COUNT(*) DESC

--The most common areas where rape occurs is (SINGLE FAMILY DWELLING)It happened 559 times,
--(MULTI-UNIT DWELLING (APARTMENT, DUPLEX, ETC)It happened 498 times and(STREET)It happened 225 times
-- and it happend to femails

--## What is the most age group of femals has been raped

SELECT age_group , COUNT(*)
FROM  losanglos_crime.dbo.crime_in_la
WHERE [vict sex] IN (SELECT [vict sex]
                    FROM  losanglos_crime.dbo.crime_in_la
					WHERE [crm cd desc] = 'RAPE, FORCIBLE')
GROUP BY age_group 
ORDER BY COUNT(*) DESC

-- Femail between 34-50 has been raped the most
-----------------------------------------------------

--## BURGLARY VS TIME

SELECT time_occ , COUNT([crm cd desc]) AS BURGLARY
FROM losanglos_crime.dbo.crime_in_la
WHERE [crm cd desc] = 'BURGLARY'
GROUP BY time_occ
ORDER BY COUNT([crm cd desc]) DESC

-- Most Burglaries Happen At 12PM

---------------------------------------------------

--## The percentage of females who were robbed from the street compared to all crimes VS percentage
-- of mails who were robbed from the street compared to all crimes
SELECT  *  
FROM losanglos_crime.dbo.crime_in_la
--ORDER BY [vict age]

-- times when femails have been robbed from the street
SELECT CAST(COUNT([vict sex])AS numeric(10,4))
FROM losanglos_crime.dbo.crime_in_la
WHERE [vict sex] = 'F'
AND [premis desc] = 'STREET'
AND [crm cd desc] = 'ROBBERY'
GROUP BY [vict sex]

--The total number of times a female is exposed to a crime

SELECT CAST(COUNT([vict sex])AS numeric(10,4))  
FROM losanglos_crime.dbo.crime_in_la
WHERE [vict sex] = 'F' 
GROUP BY [vict sex] 

-- times when mails have been robbed from the street

SELECT CAST(COUNT([vict sex])AS numeric(10,4))
FROM losanglos_crime.dbo.crime_in_la
WHERE [vict sex] = 'M'
AND [premis desc] = 'STREET'
AND [crm cd desc] = 'ROBBERY'
GROUP BY [vict sex]

-- The total number of times a mails is exposed to a crime

SELECT CAST(COUNT([vict sex])AS numeric(10,4))  
FROM losanglos_crime.dbo.crime_in_la
WHERE [vict sex] = 'M' 
GROUP BY [vict sex] 


SELECT TOP 1 ROUND((SELECT CAST(COUNT([vict sex])AS numeric(10,3))/(SELECT CAST(COUNT([vict sex])AS numeric(10,3))  
                                                             FROM losanglos_crime.dbo.crime_in_la
                                                             WHERE [vict sex] = 'M' 
														 	 GROUP BY [vict sex])
             FROM losanglos_crime.dbo.crime_in_la
             WHERE [vict sex] = 'M'
             AND [premis desc] = 'STREET'
             AND [crm cd desc] = 'ROBBERY'
             GROUP BY [vict sex])*100,2 ,0) AS MAIL,
             (SELECT CAST(COUNT([vict sex])AS numeric(10,4))/(SELECT CAST(COUNT([vict sex])AS numeric(10,4))  
                                                              FROM losanglos_crime.dbo.crime_in_la
                                                              WHERE [vict sex] = 'F' 
                                                              GROUP BY [vict sex] )
              FROM losanglos_crime.dbo.crime_in_la
              WHERE [vict sex] = 'F'
              AND [premis desc] = 'STREET'
              AND [crm cd desc] = 'ROBBERY'
              GROUP BY [vict sex])*100 AS FEMAIL
FROM losanglos_crime.dbo.crime_in_la
 

-- 1.96% of mails who get ROBBERY in the street 
-- 0.80% of femail who get ROBBERY in the street


