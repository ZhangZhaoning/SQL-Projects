#Author: Zhaoning Zhang

#This Project is developed for company's want to do Barclay credit rating for their Portfolio 
#in which each bond has three credit rating: Fitch, S&P, Moody.

#CREATE DATABASE downgrade;

USE downgrade;

CREATE TABLE corporate(
ID_CUSIP VARCHAR(50) NOT NULL,
RTG_FITCH_LT_ISSUER_DEFAULT VARCHAR(50) NULL,
RTG_MDY_ISSUER VARCHAR(50) NULL,
RTG_SP_LT_LC_ISSUER_CREDIT VARCHAR(50) NULL,
TIME_STAMP DATE NULL
);


ALTER TABLE corporate ADD COLUMN FITCH_SCORE DOUBLE NULL AFTER TIME_STAMP;
ALTER TABLE corporate ADD COLUMN SP_SCORE DOUBLE NULL AFTER FITCH_SCORE;
ALTER TABLE corporate ADD COLUMN MOODY_SCORE DOUBLE NULL AFTER SP_SCORE;

SET SQL_SAFE_UPDATES = 0;
UPDATE corporate SET FITCH_SCORE=(SELECT
CASE
WHEN LEFT(RTG_FITCH_LT_ISSUER_DEFAULT, 3) = "AAA" THEN 150
WHEN LEFT(RTG_FITCH_LT_ISSUER_DEFAULT, 3) = "AA+" THEN 140
WHEN LEFT(RTG_FITCH_LT_ISSUER_DEFAULT, 3) = "AA-" THEN 120
WHEN LEFT(RTG_FITCH_LT_ISSUER_DEFAULT, 2) = "AA" THEN 130
WHEN LEFT(RTG_FITCH_LT_ISSUER_DEFAULT, 2) = "A+" THEN 110
WHEN LEFT(RTG_FITCH_LT_ISSUER_DEFAULT, 2) = "A-" THEN 90
WHEN LEFT(RTG_FITCH_LT_ISSUER_DEFAULT, 1) = "A" THEN 100
WHEN LEFT(RTG_FITCH_LT_ISSUER_DEFAULT, 4) = "BBB+" THEN 80
WHEN LEFT(RTG_FITCH_LT_ISSUER_DEFAULT, 4) = "BBB-" THEN 60
WHEN LEFT(RTG_FITCH_LT_ISSUER_DEFAULT, 3) = "BBB" THEN 70
WHEN LEFT(RTG_FITCH_LT_ISSUER_DEFAULT, 3) = "BB+" THEN 50
WHEN LEFT(RTG_FITCH_LT_ISSUER_DEFAULT, 3) = "BB-" THEN 30
WHEN LEFT(RTG_FITCH_LT_ISSUER_DEFAULT, 2) = "BB" THEN 40
WHEN LEFT(RTG_FITCH_LT_ISSUER_DEFAULT, 2) = "B+" THEN 20
WHEN LEFT(RTG_FITCH_LT_ISSUER_DEFAULT, 2) = "B" THEN 10
ELSE 0
END
);

UPDATE corporate SET SP_SCORE=(SELECT
CASE
WHEN LEFT(RTG_SP_LT_LC_ISSUER_CREDIT, 3) = "AAA" THEN 150
WHEN LEFT(RTG_SP_LT_LC_ISSUER_CREDIT, 3) = "AA+" THEN 140
WHEN LEFT(RTG_SP_LT_LC_ISSUER_CREDIT, 3) = "AA-" THEN 120
WHEN LEFT(RTG_SP_LT_LC_ISSUER_CREDIT, 2) = "AA" THEN 130
WHEN LEFT(RTG_SP_LT_LC_ISSUER_CREDIT, 2) = "A+" THEN 110
WHEN LEFT(RTG_SP_LT_LC_ISSUER_CREDIT, 2) = "A-" THEN 90
WHEN LEFT(RTG_SP_LT_LC_ISSUER_CREDIT, 1) = "A" THEN 100
WHEN LEFT(RTG_SP_LT_LC_ISSUER_CREDIT, 4) = "BBB+" THEN 80
WHEN LEFT(RTG_SP_LT_LC_ISSUER_CREDIT, 4) = "BBB-" THEN 60
WHEN LEFT(RTG_SP_LT_LC_ISSUER_CREDIT, 3) = "BBB" THEN 70
WHEN LEFT(RTG_SP_LT_LC_ISSUER_CREDIT, 3) = "BB+" THEN 50
WHEN LEFT(RTG_SP_LT_LC_ISSUER_CREDIT, 3) = "BB-" THEN 30
WHEN LEFT(RTG_SP_LT_LC_ISSUER_CREDIT, 2) = "BB" THEN 40
WHEN LEFT(RTG_SP_LT_LC_ISSUER_CREDIT, 2) = "B+" THEN 20
WHEN LEFT(RTG_SP_LT_LC_ISSUER_CREDIT, 2) = "B" THEN 10
ELSE 0
END
);

UPDATE corporate SET MOODY_SCORE=(SELECT
CASE
WHEN LEFT(RTG_MDY_ISSUER, 3) = "Aaa" THEN 150
WHEN LEFT(RTG_MDY_ISSUER, 3) = "Aa1" THEN 140
WHEN LEFT(RTG_MDY_ISSUER, 3) = "Aa2" THEN 130
WHEN LEFT(RTG_MDY_ISSUER, 3) = "Aa3" THEN 120
WHEN LEFT(RTG_MDY_ISSUER, 2) = "A1" THEN 110
WHEN LEFT(RTG_MDY_ISSUER, 2) = "A2" THEN 100
WHEN LEFT(RTG_MDY_ISSUER, 2) = "A3" THEN 90
WHEN LEFT(RTG_MDY_ISSUER, 4) = "Baa1" THEN 80
WHEN LEFT(RTG_MDY_ISSUER, 4) = "Baa2" THEN 70
WHEN LEFT(RTG_MDY_ISSUER, 4) = "Baa3" THEN 60
WHEN LEFT(RTG_MDY_ISSUER, 3) = "Ba1" THEN 50
WHEN LEFT(RTG_MDY_ISSUER, 3) = "Ba2" THEN 40
WHEN LEFT(RTG_MDY_ISSUER, 3) = "Ba3" THEN 30
WHEN LEFT(RTG_MDY_ISSUER, 2) = "B1" THEN 20
WHEN LEFT(RTG_MDY_ISSUER, 2) = "B2" THEN 10
ELSE 0
END
);

ALTER TABLE corporate ADD COLUMN RTG_FINAL DOUBLE NULL AFTER MOODY_SCORE;

UPDATE corporate SET RTG_FINAL = (SELECT (CASE
#Use Median when the three of them are all non-zero
    WHEN (SP_SCORE != 0 AND MOODY_SCORE != 0 AND FITCH_SCORE !=0) THEN
    (
    CASE
    WHEN SP_SCORE = GREATEST(SP_SCORE, MOODY_SCORE, FITCH_SCORE) THEN
    GREATEST(MOODY_SCORE, FITCH_SCORE)
    WHEN SP_SCORE = LEAST(SP_SCORE, MOODY_SCORE, FITCH_SCORE) THEN
    LEAST(MOODY_SCORE, FITCH_SCORE)
    ELSE
    SP_SCORE
    END
    )
    
    #Use the samller one when there are two score available
    WHEN (SP_SCORE =0 AND MOODY_SCORE !=0 AND FITCH_SCORE !=0) THEN
    LEAST(MOODY_SCORE, FITCH_SCORE)
    
    WHEN (SP_SCORE !=0 AND MOODY_SCORE =0 AND FITCH_SCORE !=0) THEN
    LEAST(SP_SCORE, FITCH_SCORE)
    
    WHEN (SP_SCORE !=0 AND MOODY_SCORE!=0 AND FITCH_SCORE =0) THEN
    LEAST(SP_SCORE, MOODY_SCORE)
    
    WHEN (SP_SCORE !=0 AND MOODY_SCORE =0 AND FITCH_SCORE =0) THEN
    SP_SCORE
    
    WHEN (SP_SCORE =0 AND MOODY_SCORE !=0 AND FITCH_SCORE =0) THEN
    MOODY_SCORE
    
    WHEN (SP_SCORE =0 AND MOODY_SCORE =0 AND FITCH_SCORE !=0) THEN
    FITCH_SCORE
     
    WHEN (SP_SCORE = 0 AND MOODY_SCORE = 0 AND FITCH_SCORE = 0) THEN
    0
    END));

SELECT a.ID_CUSIP, a.TIME_STAMP , a.RTG_FINAL
FROM corporate a , corporate b 
WHERE
a.ID_CUSIP = b.ID_CUSIP 
AND
DATEDIFF(a.TIME_STAMP,b.TIME_STAMP) = 1 
AND
a.RTG_FINAL < b.RTG_FINAL
;

