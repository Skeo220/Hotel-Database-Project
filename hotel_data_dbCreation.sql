-- Creating hotel_db
CREATE TABLE hotel_db (
	booking_id INT IDENTITY(1,1) PRIMARY KEY,
	hotel VARCHAR(255),
	is_canceled BIT,
	lead_time FLOAT,
	arrival_date_year INT,
	arrival_date_month INT,
	arrival_date_week_number INT,
	arrival_date_day_of_month INT,
	stays_in_weekend_nights FLOAT,
	stays_in_week_nights FLOAT,
	adults INT,
	children INT,
	babies INT,
	meal VARCHAR(255),
	country VARCHAR(255),
	market_segment VARCHAR(255),
	distribution_channel VARCHAR(255),
	is_repeated_guest BIT,
	previous_cancellations INT,
	previous_bookings_not_canceled INT,
	Reserved_room_type VARCHAR(255),
	assigned_room_type VARCHAR(255),
	booking_changes INT,
	deposit_type VARCHAR(255),
	agent VARCHAR(255),
	company VARCHAR(255),
	days_in_waiting_list INT,
	customer_type VARCHAR(255),
	adr FLOAT,
	required_car_parking_spaces INT,
	total_of_special_requests INT,
	reservation_status VARCHAR(255),
	reservation_status_date VARCHAR(255)
	);
-----------------------------------------------------------
-- Inserting data into hotel db. There were 3 different files for each years.
-- This query combines them all and inserts them into hotel_db
SELECT *
INTO Projects.dbo.hotel_db
FROM(
	SELECT *
	FROM Sandbox.dbo.[2020_hotel_data]
	UNION ALL 
	SELECT *
	FROM Sandbox.dbo.[2019_hotel_data]
	UNION ALL
	SELECT *
	FROM Sandbox.dbo.[2018_hotel_data]) as sub
--------------------------------------------------------
-- Checking the types of the columns
SELECT COlUMN_NAME,
DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'hotel_db'
and TABLE_SCHEMA = 'dbo'
------------------------------------------------------------------------------
-- Adding NUlls where there is missing data
UPDATE Projects.dbo.hotel_db
SET 
	agent = NULLIF(agent, 'NULL'),
	company = NULLIF(company, 'NULL')
-------------------------------------------------------------------------------
-- Changing reservation_status_data to a date type
ALTER TABLE Projects.dbo.hotel_db
ALTER COLUMN reservation_status_date DATE
--------------------------------------------------------------------------------
-- Creating a arrival_date_month_number. A numerical version of arrival_date_month
ALTER TABLE Projects.dbo.hotel_db
ADD arrival_date_month_number as
	case 
		when arrival_date_month like '%Jan%' then '1'
		when arrival_date_month like '%Feb%' then '2'
		when arrival_date_month like '%Mar%' then '3'
		when arrival_date_month like '%Apr%' then '4'
		when arrival_date_month like '%May%' then '5'
		when arrival_date_month like '%Jun%' then '6'
		when arrival_date_month like '%Jul%' then '7'
		when arrival_date_month like '%Aug%' then '8'
		when arrival_date_month like '%Sep%' then '9'
		when arrival_date_month like '%Oct%' then '10'
		when arrival_date_month like '%Nov%' then '11'
		when arrival_date_month like '%Dec%' then '12'
	END;
--------------------------------------------------------------------------------
-- Creating booking_id column for every individual bookings
ALTER TABLE Projects.dbo.hotel_db
ADD booking_id AS CONCAT(
	CASE WHEN hotel like '%Resort%' THEN 'RH'
		WHEN hotel like '%City%' THEN 'CH'
		END,
	CAST(ABS(CHECKSUM(NEWID())) % 100000 AS VARCHAR(5)));
---------------------------------------------------------------------------------
-- Creating market segment table
CREATE TABLE hotel_market_segment (
	market_segment VARCHAR(255),
	discount FLOAT);
-----------------------------------------------------------------------------------
-- Creating meal_cost table
CREATE TABLE meal_cost (
	market_segment VARCHAR(100),
	Cost FLOAT);
