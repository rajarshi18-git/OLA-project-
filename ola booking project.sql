CREATE TABLE Bookings (
    Date TIMESTAMP,
    Time TIME,
    Booking_ID VARCHAR(20) PRIMARY KEY,
    Booking_Status VARCHAR(50),
    Customer_ID VARCHAR(20),
    Vehicle_Type VARCHAR(50),
    Pickup_Location VARCHAR(100),
    Drop_Location VARCHAR(100),
    V_TAT INT,
    C_TAT INT,
    Canceled_Rides_by_Customer VARCHAR(100),
    Canceled_Rides_by_Driver VARCHAR(100),
    Incomplete_Rides VARCHAR(10),
    Incomplete_Rides_Reason VARCHAR(255),
    Booking_Value INT,
    Payment_Method VARCHAR(50),
    Ride_Distance INT,
    Driver_Ratings DECIMAL(3,1),
    Customer_Rating DECIMAL(3,1),
    Vehicle_Images VARCHAR(255),
    Extra VARCHAR(255)  -- for "Unnamed: 20"
);

SELECT*FROM bookings;

COPY bookings
FROM 'D:\Bookings.csv'
DELIMITER ','
CSV HEADER
NULL 'null';

# questions and solutions
#1. retrivee all successful bookings .
Create view Successful_Bookings AS
SELECT * FROM bookings
WHERE Booking_Status='Success';
# optimized ans--
SELECT * FROM Successful_Bookings;

#2.Find the avg ride distance for each vehicle type.

Create view Avg_distance_for_each_type_vehicle AS
SELECT Vehicle_Type,AVG(Ride_Distance) AS avg_distance 
FROM  bookings
GROUP BY Vehicle_Type;
#optimized ans--
SELECT * FROM Avg_distance_for_each_type_vehicle;

#3.get the total number of canceled rides by customers.

create view canceled_rides_by_customer as 
select count(*) as total_count
from bookings
where Booking_Status ='Canceled by Customer'
#optimized  ans....
SELECT * FROM  canceled_rides_by_customer;

# 4.list of top 5 customers who booked the highest number of rides.
create view top5_customers as 
select Customer_ID,count(Booking_ID)as total_count
from bookings
group by Customer_ID
order by total_count DESC limit 5;
#optimized  ans....
SELECT * FROM  top5_customers;

# 5. get the number of rides canceled by personal and car related issues.
select count(*)
from bookings
where Canceled_Rides_by_Driver ='Personal & Car related issue'

#6.find the max and min driver ratings for prime and seadan bookings .
select 
max(Driver_Ratings)as max_rating,
min(Driver_Ratings)as min_rating
from bookings
where Vehicle_Type ='Prime Sedan';


#7.select all rides where payment was made by  UPI 
select *from  bookings
where Payment_Method='UPI';

#8.find the avg customer rating per vehical type.
select Vehicle_Type,avg(Customer_Rating)
from bookings
group by Vehicle_Type;

# 9. calculate total number of booking value of rides completed successfully.
create view total_successful_ride_value as 
select sum(Booking_Value)as total_successful_ride_value
from bookings
where Booking_Status ='Success';
# optmized query 
select * from total_successful_ride_value

'#10.Find the top 10 most frequent Pickup → Drop combinations.'
'#Top Pickup-Drop Pairs'
SELECT 
    Pickup_Location, Drop_Location,
    COUNT(*) AS total_rides,
    SUM(Booking_Value) AS total_revenue
FROM Bookings
GROUP BY Pickup_Location, Drop_Location
ORDER BY total_rides DESC
LIMIT 10;

'# 11.Find the top 5 pickup locations with the highest cancellation rate'
'#Cancellation Analysis'

SELECT 
    Pickup_Location,
    COUNT(*) AS total_bookings,
    SUM(CASE WHEN Booking_Status LIKE 'Canceled%' THEN 1 ELSE 0 END) AS canceled_bookings,
    ROUND(SUM(CASE WHEN Booking_Status LIKE 'Canceled%' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS cancel_rate_pct
FROM Bookings
GROUP BY Pickup_Location
HAVING COUNT(*) > 10   -- filter small locations if needed
ORDER BY cancel_rate_pct DESC
LIMIT 5;

'# Payment Preference by Area'
SELECT 
    Pickup_Location,
    Payment_Method,
    COUNT(*) AS method_count
FROM Bookings
WHERE Payment_Method IS NOT NULL
GROUP BY Pickup_Location, Payment_Method
ORDER BY method_count DESC 

'#High Value Customers'
'Find the customers (Customer_ID) whose total booking value > 5000.
For each, show their total rides, success rate, and average customer rating.'
SELECT 
    Customer_ID,
    SUM(Booking_Value) AS total_value,
    COUNT(*) AS total_rides,
    ROUND(SUM(CASE WHEN Booking_Status = 'Success' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS success_rate_pct,
    ROUND(AVG(Customer_Rating),2) AS avg_customer_rating
FROM Bookings
GROUP BY Customer_ID
HAVING SUM(Booking_Value)> 5000
ORDER BY total_value DESC;

    
'##Revenue Loss from Cancellations

#Estimate how much revenue was lost due to cancellations (Booking_Value of canceled rides).
Compare it with the revenue from successful rides (as a percentage).'
SELECT 
    SUM(CASE WHEN Booking_Status LIKE 'Canceled%' THEN Booking_Value  ELSE 0 END) AS lost_revenue,
    SUM(CASE WHEN Booking_Status = 'Success' THEN Booking_Value  ELSE 0 END) AS success_revenue,
    ROUND(SUM(CASE WHEN Booking_Status LIKE 'Canceled%' THEN Booking_Value ELSE 0 END) * 100.0 /
          SUM(CASE WHEN Booking_Status = 'Success' THEN Booking_Value ELSE 0 END), 2) AS loss_pct_vs_success
FROM Bookings;





