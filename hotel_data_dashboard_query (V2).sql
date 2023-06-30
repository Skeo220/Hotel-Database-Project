-------------------------------------------------------------------------------------
-- This is how to calculate the actual revenue
-- creating the temp table
SELECT booking_id,
	hotel,
	isnull(company, 'N/A') company,
	reserved_room_type,
	assigned_room_type,
	distribution_channel,
	h.market_segment,
	country,
	reservation_status,
	customer_type,
	deposit_type,
	(stays_in_week_nights+stays_in_weekend_nights) length_of_stay,
	adr,
	Discount,
	Cost meal_cost,
	reservation_status_date,
	arrival_date_year,
	arrival_date_month,
    CASE 
        WHEN reservation_status = 'Check-Out' THEN 1
		WHEN deposit_type = 'Non Refund' THEN 1
        ELSE 0
    END AS count_as_revenue
INTO #temp1
FROM Projects.dbo.hotel_db h
LEFT JOIN Projects.dbo.hotel_db_meal_cost c
ON h.meal = c.meal
LEFT JOIN Projects.dbo.hotel_db_market_segment m
ON h.market_segment = m.market_segment;

-- Using the temp table to calculate actual revenue
SELECT hotel,
	company, 
	reserved_room_type,
	assigned_room_type,
	customer_type,
	distribution_channel,
	market_segment,
	country,
	reservation_status,
	deposit_type,
	arrival_date_year,
	arrival_date_month,
	reservation_status_year,
	ROUND(SUM(total_due),2) as revenue
FROM (
	SELECT booking_id,
		company, 
		reserved_room_type,
		assigned_room_type,
		distribution_channel,
		market_segment,
		customer_type,
		country,
		reservation_status,
		deposit_type,
		hotel,
		year(reservation_status_date) reservation_status_year,
		arrival_date_year,
		arrival_date_month,
		((length_of_stay * adr * (1-Discount)) + (length_of_stay * meal_cost)) total_due,
		count_as_revenue
	FROM #temp1) sub
WHERE count_as_revenue = 1
GROUP BY hotel,
	company, 
	reserved_room_type,
	assigned_room_type,
	distribution_channel,
	customer_type,
	market_segment,
	country,
	reservation_status,
	deposit_type,
	arrival_date_year,
	arrival_date_month,
	reservation_status_year;
--------------------------------------------------------------------------------------
-- Projected Revenue
SELECT hotel,
	arrival_date_year,
	arrival_date_month,
	reservation_status_year,
	ROUND(SUM(total_due),2) AS projected_revenue
FROM (
	SELECT hotel, 
		year(reservation_status_date) reservation_status_year, 
		arrival_date_month, 
		arrival_date_year,
		((length_of_stay * adr * (1-Discount)) + (length_of_stay * meal_cost)) total_due
	FROM #temp1 ) AS sub
group by hotel,
	arrival_date_year,
	arrival_date_month,
	reservation_status_year;

--------------------------------------------------------------------
-- loss revenue summary
SELECT hotel,
	arrival_date_year,
	arrival_date_month,
	reservation_status_year,
	ROUND(SUM(total_due),2) AS projected_revenue,
	revenue_lost_reason
FROM (
	SELECT hotel, 
		year(reservation_status_date) reservation_status_year, 
		arrival_date_month, 
		arrival_date_year,
		((length_of_stay * adr * (1-Discount)) + (length_of_stay * meal_cost)) total_due,
		CONCAT(reservation_status,', ',deposit_type) AS revenue_lost_reason
	FROM #temp1 
	WHERE count_as_revenue = 0) as sub
group by hotel,
	arrival_date_year,
	arrival_date_month,
	reservation_status_year,
	revenue_lost_reason;
	
-------------------------------------------------------------------------------------
-- All reservations details
SELECT hotel, 
	country, 
	reservation_status,
	year(reservation_status_date) reservation_year,
	arrival_date_year,
	arrival_date_month,
	market_segment,
	distribution_channel,
	reserved_room_type,
	assigned_room_type,
	isnull(company, 'N/A') company,
	customer_type,
	deposit_type,
	meal,
	COUNT(*) reservations,
	sum(adults) adults,
	sum(children) children,
	sum(babies) babies,
	sum(stays_in_week_nights) week_nights,
	sum(stays_in_weekend_nights) weekend_nights,
	sum(required_car_parking_spaces) required_parking,
	sum(total_of_special_requests) special_requests,
	sum(is_repeated_guest) repeat_guests,
	sum(previous_cancellations) canceled,
	sum(previous_bookings_not_canceled) not_canceled,
	sum(booking_changes) booking_changes
FROM Projects.dbo.hotel_db
group by hotel,
	country,
	arrival_date_year,
	arrival_date_month,
	reservation_status,
	market_segment,
	reserved_room_type,
	assigned_room_type,
	distribution_channel,
	deposit_type,
	meal,
	reservation_status,
	isnull(company, 'N/A'),
	customer_type,
	year(reservation_status_date);
-------------------------------------------------------------------
-- detail view of 2020 reservations
SELECT TOP 1000
	booking_id,
	hotel,
	arrival_date,
	adults, 
	babies,
	children,
	length_of_stay,
	country,
	((length_of_stay * adr * (1-Discount)) + (length_of_stay * meal_cost)) total_due,
	adr,
	meal,
	meal_cost,
	market_segment,
	discount,
	customer_type,
	total_of_special_requests, 
	required_car_parking_spaces,
	reservation_status, 
	reservation_status_date
FROM (
	SELECT booking_id,
		hotel, 
		CONCAT(arrival_date_month_number,'/',arrival_date_day_of_month,'/',arrival_date_year) arrival_date,
		adults, 
		children,
		babies, 
		(stays_in_week_nights+stays_in_weekend_nights) length_of_stay,
		country,
		adr,
		h.meal,
		c.Cost meal_cost,
		h.market_segment,
		Discount,
		customer_type, 
		total_of_special_requests,
		required_car_parking_spaces,
		reservation_status_date,
		reservation_status
	FROM Projects.dbo.hotel_db h
	LEFT JOIN Projects.dbo.hotel_db_meal_cost c
	ON h.meal = c.meal
	LEFT JOIN Projects.dbo.hotel_db_market_segment m
	ON h.market_segment = m.market_segment
	WHERE arrival_date_year = 2020 
	and reservation_status != 'Canceled') AS sub
Order by arrival_date desc;
 