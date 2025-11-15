-- Flights Table
CREATE TABLE Flights (
    flight_id INTEGER PRIMARY KEY AUTOINCREMENT,
    flight_number TEXT,
    origin TEXT,
    destination TEXT,
    departure_date TEXT,
    departure_time TEXT,
    total_seats INTEGER
);

-- Passengers Table
CREATE TABLE Passengers (
    passenger_id INTEGER PRIMARY KEY AUTOINCREMENT,
    first_name TEXT,
    last_name TEXT,
    gender TEXT,
    age INTEGER,
    passport_number TEXT
);

-- Bookings Table (Composite PK: flight_id + passenger_id)
CREATE TABLE Bookings (
    flight_id INTEGER NOT NULL,
    passenger_id INTEGER NOT NULL,
    seat_class TEXT,
    booking_date TEXT,
    price_paid REAL,
    booking_status TEXT,
    PRIMARY KEY (flight_id, passenger_id),
    FOREIGN KEY (flight_id) REFERENCES Flights(flight_id),
    FOREIGN KEY (passenger_id) REFERENCES Passengers(passenger_id)
);

-- Payments Table
CREATE TABLE Payments (
    payment_id INTEGER PRIMARY KEY AUTOINCREMENT,
    flight_id INTEGER NOT NULL,
    passenger_id INTEGER NOT NULL,
    payment_method TEXT,
    payment_date TEXT,
    amount REAL,
    payment_status TEXT,
    FOREIGN KEY (flight_id, passenger_id) REFERENCES Bookings(flight_id, passenger_id)
);

------------------------------------------------------------------------------------------------------------------------------------------------------------

-- 1. Data Viewing

-- View first few rows of each table

SELECT * FROM Flights LIMIT 5;
SELECT * FROM Passengers LIMIT 5;
SELECT * FROM Bookings LIMIT 5;
SELECT * FROM Payments LIMIT 5;

--2. Data Preprocessing: Missing Values in Each Column

-- Missing value count per column (Flights)
SELECT
  SUM(flight_id IS NULL) AS miss_flight_id,
  SUM(flight_number IS NULL) AS miss_flight_number,
  SUM(origin IS NULL) AS miss_origin,
  SUM(destination IS NULL) AS miss_destination,
  SUM(departure_date IS NULL) AS miss_departure_date,
  SUM(departure_time IS NULL) AS miss_departure_time,
  SUM(total_seats IS NULL) AS miss_total_seats
FROM Flights;

-- Missing value count per column (Passengers)
SELECT
  SUM(passenger_id IS NULL) AS miss_passenger_id,
  SUM(first_name IS NULL) AS miss_first_name,
  SUM(last_name IS NULL) AS miss_last_name,
  SUM(gender IS NULL) AS miss_gender,
  SUM(age IS NULL) AS miss_age,
  SUM(passport_number IS NULL) AS miss_passport_number
FROM Passengers;

-- Missing value count per column (Bookings)
SELECT
  SUM(flight_id IS NULL) AS miss_flight_id,
  SUM(passenger_id IS NULL) AS miss_passenger_id,
  SUM(seat_class IS NULL) AS miss_seat_class,
  SUM(booking_date IS NULL) AS miss_booking_date,
  SUM(price_paid IS NULL) AS miss_price_paid,
  SUM(booking_status IS NULL) AS miss_booking_status
FROM Bookings;

-- Missing value count per column (Payments)
SELECT
  SUM(payment_id IS NULL) AS miss_payment_id,
  SUM(flight_id IS NULL) AS miss_flight_id,
  SUM(passenger_id IS NULL) AS miss_passenger_id,
  SUM(payment_method IS NULL) AS miss_payment_method,
  SUM(payment_date IS NULL) AS miss_payment_date,
  SUM(amount IS NULL) AS miss_amount,
  SUM(payment_status IS NULL) AS miss_payment_status
FROM Payments;

-------------------------------------------------------------------------------------------------------------------------------------
--3. Preprocessing: Replace NULLs
--Numeric: replace NULLs with 0; Text: replace NULLs with "unknown"

--for Bookings table:

UPDATE Bookings
SET
  seat_class = COALESCE(seat_class, 'unknown'),
  booking_status = COALESCE(booking_status, 'unknown'),
  booking_date = COALESCE(booking_date, 'unknown'),
  price_paid = COALESCE(price_paid, 0);


--In Passengers:

UPDATE Passengers
SET
  passport_number = COALESCE(passport_number, 'unknown');
---------------------------------------------------------------------------------------------------------------------------------------
  
 --4. Check That NULLs are Replaced

-- Confirm NULLs have been replaced in Bookings
SELECT * FROM Bookings WHERE seat_class IS NULL OR booking_status IS NULL OR booking_date IS NULL OR price_paid IS NULL;

-- Confirm NULLs have been replaced in Passengers
SELECT * FROM Passengers WHERE passport_number IS NULL;

-----------------------------------------------------------------------------------------------------------------------------------------

--5. In-depth Data Understanding & Relationships
--a. Aggregate: Average Payment Amount Per Flight

SELECT Flights.flight_number, AVG(Payments.amount) AS avg_payment, 
COUNT(Payments.payment_id) AS num_payments
FROM Payments
JOIN Flights ON Payments.flight_id = Flights.flight_id
GROUP BY Flights.flight_id
ORDER BY avg_payment DESC
LIMIT 5;


--b.Count By Seat Class (Including Unknowns)

SELECT seat_class, COUNT(*) AS booking_count
FROM Bookings
GROUP BY seat_class
ORDER BY booking_count DESC;


--c.Most Booked Flights (Flight Popularity)

SELECT Flights.flight_number, COUNT(Bookings.flight_id) AS total_bookings
FROM Bookings
JOIN Flights ON Bookings.flight_id = Flights.flight_id
GROUP BY Flights.flight_id, Flights.flight_number
ORDER BY total_bookings DESC
LIMIT 10;

--d.Distribution of Payment Methods

SELECT payment_method, COUNT(*) AS method_count
FROM Payments
GROUP BY payment_method
ORDER BY method_count DESC;


--e.Passengers Who Spend The Most

SELECT Passengers.first_name, Passengers.last_name, SUM(Payments.amount) AS total_spent
FROM Payments
JOIN Passengers ON Payments.passenger_id = Passengers.passenger_id
GROUP BY Passengers.passenger_id
ORDER BY total_spent DESC
LIMIT 10;
