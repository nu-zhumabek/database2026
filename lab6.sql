-- 1. All flights of a specific airline.
SELECT f.flight_no, a.airline_name, f.scheduled_departure, f.scheduled_arrival
FROM flights AS f
JOIN airline AS a ON a.airline_id = f.airline_id
WHERE a.airline_id = 1
ORDER BY f.scheduled_departure;

-- 2. Flights and their departure airport names.
SELECT f.flight_no, ap.airport_name AS departure_airport, f.scheduled_departure
FROM flights AS f
JOIN airport AS ap ON ap.airport_id = f.departure_airport_id
ORDER BY f.flight_no;

-- 3. Airlines with no flights scheduled in the next calendar month.
SELECT a.airline_id, a.airline_name
FROM airline AS a
LEFT JOIN flights AS f
  ON f.airline_id = a.airline_id
 AND f.scheduled_departure >= (DATE_TRUNC('month', CURRENT_DATE) + INTERVAL '1 month')::date
 AND f.scheduled_departure < (DATE_TRUNC('month', CURRENT_DATE) + INTERVAL '2 months')::date
WHERE f.flight_id IS NULL
ORDER BY a.airline_name;

-- 4. Passengers on a specific flight.
SELECT DISTINCT f.flight_no, p.passenger_id,
       CONCAT_WS(' ', p.first_name, p.last_name) AS passenger_full_name
FROM flights AS f
JOIN booking_flight AS bf ON bf.flight_id = f.flight_id
JOIN booking AS b ON b.booking_id = bf.booking_id
JOIN passengers AS p ON p.passenger_id = b.passenger_id
WHERE f.flight_id = 1
ORDER BY passenger_full_name;

-- 5. Average, total, maximum and minimum booking price for each flight.
SELECT f.flight_no,
       ROUND(AVG(b.price), 2) AS average_price,
       COALESCE(SUM(b.price), 0) AS total_price,
       MAX(b.price) AS maximum_price,
       MIN(b.price) AS minimum_price
FROM flights AS f
LEFT JOIN booking_flight AS bf ON bf.flight_id = f.flight_id
LEFT JOIN booking AS b ON b.booking_id = bf.booking_id
GROUP BY f.flight_id, f.flight_no
ORDER BY f.flight_no;

-- 6. Flights to a specified destination country.
SELECT f.flight_no, a.airline_name,
       ap.airport_name AS arrival_airport, ap.country AS destination_country
FROM flights AS f
JOIN airport AS ap ON ap.airport_id = f.arrival_airport_id
JOIN airline AS a ON a.airline_id = f.airline_id
WHERE ap.country = 'Kazakhstan'
ORDER BY f.flight_no;

-- 7. Minor passengers (under 18) and their destinations.
SELECT DISTINCT p.passenger_id,
       CONCAT_WS(' ', p.first_name, p.last_name) AS passenger_full_name,
       p.date_of_birth, f.flight_no,
       ap.airport_name AS arrival_airport,
       ap.city AS destination_city, ap.country AS destination_country
FROM passengers AS p
JOIN booking AS b ON b.passenger_id = p.passenger_id
JOIN booking_flight AS bf ON bf.booking_id = b.booking_id
JOIN flights AS f ON f.flight_id = bf.flight_id
JOIN airport AS ap ON ap.airport_id = f.arrival_airport_id
WHERE p.date_of_birth > (CURRENT_DATE - INTERVAL '18 years')::date
ORDER BY passenger_full_name, f.flight_no;

-- 8. Passenger name, passport and actual arrival date.
SELECT DISTINCT CONCAT_WS(' ', p.first_name, p.last_name) AS passenger_full_name,
       p.passport_number, f.flight_no,
       ap.airport_name AS destination_airport,
       f.actual_arrival AS actual_arrival_date
FROM passengers AS p
JOIN booking AS b ON b.passenger_id = p.passenger_id
JOIN booking_flight AS bf ON bf.booking_id = b.booking_id
JOIN flights AS f ON f.flight_id = bf.flight_id
JOIN airport AS ap ON ap.airport_id = f.arrival_airport_id
ORDER BY passenger_full_name, f.flight_no;

-- 9. Flights whose airline country equals the departure airport country, grouped by country.
SELECT ap.country AS airport_country, COUNT(*) AS matching_flights
FROM flights AS f
JOIN airline AS a ON a.airline_id = f.airline_id
JOIN airport AS ap ON ap.airport_id = f.departure_airport_id
WHERE a.airline_country = ap.country
GROUP BY ap.country
ORDER BY ap.country;

-- 10. Flight number, airline, departure and arrival airport.
SELECT f.flight_no, a.airline_name,
       dep.airport_name AS departure_airport,
       arr.airport_name AS arrival_airport
FROM flights AS f
JOIN airline AS a ON a.airline_id = f.airline_id
JOIN airport AS dep ON dep.airport_id = f.departure_airport_id
JOIN airport AS arr ON arr.airport_id = f.arrival_airport_id
ORDER BY f.flight_no;

-- 11. Passengers with bookings for flights of a specified airline.
SELECT DISTINCT CONCAT_WS(' ', p.first_name, p.last_name) AS passenger_full_name,
       f.flight_no, a.airline_name
FROM passengers AS p
JOIN booking AS b ON b.passenger_id = p.passenger_id
JOIN booking_flight AS bf ON bf.booking_id = b.booking_id
JOIN flights AS f ON f.flight_id = bf.flight_id
JOIN airline AS a ON a.airline_id = f.airline_id
WHERE a.airline_id = 1
ORDER BY passenger_full_name, f.flight_no;

-- 12. Booked passengers per flight, including flights with no bookings.
SELECT f.flight_no, ap.country AS destination_country,
       COUNT(DISTINCT b.passenger_id) AS booked_passengers
FROM flights AS f
JOIN airport AS ap ON ap.airport_id = f.arrival_airport_id
LEFT JOIN booking_flight AS bf ON bf.flight_id = f.flight_id
LEFT JOIN booking AS b ON b.booking_id = bf.booking_id
GROUP BY f.flight_id, f.flight_no, ap.country
ORDER BY f.flight_no;

-- 13. Passengers without any bookings.
SELECT p.passenger_id,
       CONCAT_WS(' ', p.first_name, p.last_name) AS passenger_full_name,
       p.passport_number
FROM passengers AS p
LEFT JOIN booking AS b ON b.passenger_id = p.passenger_id
WHERE b.booking_id IS NULL
ORDER BY p.passenger_id;

-- 14. Flight count per airline, including airlines without flights.
SELECT a.airline_id, a.airline_name,
       COUNT(f.flight_id) AS total_flights
FROM airline AS a
LEFT JOIN flights AS f ON f.airline_id = a.airline_id
GROUP BY a.airline_id, a.airline_name
ORDER BY a.airline_name;

-- 15. Flights departing from a specified country.
SELECT a.airline_name, f.flight_no,
       ap.city AS departure_airport_city,
       ap.airport_name AS departure_airport
FROM flights AS f
JOIN airline AS a ON a.airline_id = f.airline_id
JOIN airport AS ap ON ap.airport_id = f.departure_airport_id
WHERE ap.country = 'Kazakhstan'
ORDER BY a.airline_name, f.flight_no;
