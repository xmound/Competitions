DROP TABLE IF EXISTS transactions_2016;
CREATE TABLE transactions_2016 (
	parcelid bigint, 
	logerror double precision,
	transactiondate varchar
);

DROP TABLE IF EXISTS transactions_2017;
COPY transactions_2016
FROM '/Users/dai_li/Workspace/personal/Competitions/zillow/data/train_2016_v2.csv' DELIMITER ',' CSV HEADER;

CREATE TABLE transactions_2017 (
	parcelid bigint, 
	logerror double precision,
	transactiondate varchar
);
COPY transactions_2017
FROM '/Users/dai_li/Workspace/personal/Competitions/zillow/data/train_2017.csv' DELIMITER ',' CSV HEADER;

DROP TABLE IF EXISTS transactions;
CREATE TABLE transactions AS
SELECT * FROM transactions_2016
UNION ALL
SELECT * FROM transactions_2017;


DROP TABLE IF EXISTS tmp_additional_temporal_information;
CREATE TABLE tmp_additional_temporal_information AS
SELECT 
    t.parcelid
    , t.logerror
    , t.transactiondate
    , substring(transactiondate from 1 for 4) AS year
    , substring(transactiondate from 6 for 2) AS month
    , DATE_PART('dow',date(t.transactiondate)) AS day_of_week
    , substring(transactiondate from 1 for 7) AS year_and_month
FROM 
	transactions t
;

-- this table the logerror information by month
DROP TABLE IF EXISTS tmp_aggregated_logerror_information;
CREATE TABLE tmp_aggregated_logerror_information AS
SELECT
	month
	, AVG(logerror) avg_logerror
	, AVG(abs(logerror)) avg_abs_logerror
	, STDDEV(logerror) std_dev_logerror
	, STDDEV(abs(logerror)) std_dev_abs_logerror 
FROM
	tmp_additional_temporal_information
GROUP BY
	1
ORDER BY
	1 ASC
;

COPY tmp_aggregated_logerror_information TO '/Users/dai_li/Workspace/personal/Competitions/zillow/data/2nd_monthly_transactions_features.csv' DELIMITER ',' CSV HEADER;

-- DROP TABLE IF EXISTS tmp_aggregated_logerror_infomation_and_trend;
-- CREATE TABLE tmp_aggregated_logerror_infomation_and_trend AS
-- SELECT
-- 	year_and_month

-- 	, avg_logerror
-- 	, avg_abs_logerror
-- 	, std_dev_logerror
-- 	, std_dev_abs_logerror
	
-- 	, AVG(avg_logerror) OVER (ORDER BY year_and_month ASC ROWS BETWEEN 1 PRECEDING AND 1 PRECEDING) avg_logerror_last_1_month
-- 	, AVG(avg_logerror) OVER (ORDER BY year_and_month ASC ROWS BETWEEN 2 PRECEDING AND 1 PRECEDING) avg_logerror_last_2_month
-- 	, AVG(avg_logerror) OVER (ORDER BY year_and_month ASC ROWS BETWEEN 3 PRECEDING AND 1 PRECEDING) avg_logerror_last_3_month

-- 	, AVG(std_dev_logerror) OVER (ORDER BY year_and_month ASC ROWS BETWEEN 1 PRECEDING AND 1 PRECEDING) avg_std_dev_logerror_last_1_month
-- 	, AVG(std_dev_logerror) OVER (ORDER BY year_and_month ASC ROWS BETWEEN 2 PRECEDING AND 1 PRECEDING) avg_std_dev_logerror_last_2_month
-- 	, AVG(std_dev_logerror) OVER (ORDER BY year_and_month ASC ROWS BETWEEN 3 PRECEDING AND 1 PRECEDING) avg_std_dev_logerror_last_3_month

-- 	, AVG(std_dev_abs_logerror) OVER (ORDER BY year_and_month ASC ROWS BETWEEN 1 PRECEDING AND 1 PRECEDING) avg_std_dev_abs_logerror_last_1_month
-- 	, AVG(std_dev_abs_logerror) OVER (ORDER BY year_and_month ASC ROWS BETWEEN 2 PRECEDING AND 1 PRECEDING) avg_std_dev_abs_logerror_last_2_month
-- 	, AVG(std_dev_abs_logerror) OVER (ORDER BY year_and_month ASC ROWS BETWEEN 3 PRECEDING AND 1 PRECEDING) avg_std_dev_abs_logerror_last_3_month
-- FROM
-- 	tmp_aggregated_logerror_information
-- ;

-- COPY tmp_aggregated_logerror_infomation_and_trend TO '/Users/dai_li/Workspace/personal/Competitions/zillow/data/monthly_transactions_features.csv' DELIMITER ',' CSV HEADER;

-- -- this table generates additional features for transactions
-- DROP TABLE IF EXISTS transactions_additional_features;
-- CREATE TABLE transactions_additional_features as
-- SELECT 
-- 	t.parcelid
--     , t.logerror
--     , t.transactiondate
--     , t.year
--     , t.month
--     , t.day_of_week
--     , f.*
-- FROM 
-- 	tmp_additional_temporal_information t
-- JOIN
-- 	tmp_aggregated_logerror_infomation_and_trend f
-- ON
-- 	t.year_and_month = f.year_and_month		
-- ;

-- COPY transactions_additional_features TO '/Users/dai_li/Workspace/personal/Competitions/zillow/data/transactions_features.csv' DELIMITER ',' CSV HEADER;

