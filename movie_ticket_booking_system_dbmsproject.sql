use dbms_project;
-- Movies table to store movie details
CREATE TABLE movies (
  movie_id INT PRIMARY KEY AUTO_INCREMENT,
  title VARCHAR(255) NOT NULL,
  description TEXT,
  duration INT NOT NULL COMMENT 'Duration in minutes',
  release_date DATE NOT NULL,
  genre VARCHAR(100),
  language VARCHAR(50),
  director VARCHAR(100),
  cast TEXT,
  poster_url VARCHAR(255),
  trailer_url VARCHAR(255),
  rating DECIMAL(2,1),
  status ENUM('Coming Soon', 'Now Showing', 'No Longer Showing') DEFAULT 'Coming Soon'
);

-- Theaters table to store theater information
CREATE TABLE theaters (
  theater_id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(100) NOT NULL,
  location VARCHAR(255) NOT NULL,
  address TEXT NOT NULL,
  contact_number VARCHAR(20),
  total_screens INT NOT NULL DEFAULT 1
);

-- Screens within theaters
CREATE TABLE screens (
  screen_id INT PRIMARY KEY AUTO_INCREMENT,
  theater_id INT NOT NULL,
  screen_number INT NOT NULL,
  seating_capacity INT NOT NULL,
  screen_type ENUM('Standard', 'IMAX', '3D', 'VIP', 'DBOX') DEFAULT 'Standard',
  FOREIGN KEY (theater_id) REFERENCES theaters(theater_id) ON DELETE CASCADE,
  UNIQUE KEY (theater_id, screen_number)
);

-- Seat configurations for each screen
CREATE TABLE seats (
  seat_id INT PRIMARY KEY AUTO_INCREMENT,
  screen_id INT NOT NULL,
  seat_row CHAR(2) NOT NULL,
  seat_number INT NOT NULL,
  seat_type ENUM('Regular', 'Premium', 'VIP', 'Wheelchair') DEFAULT 'Regular',
  status ENUM('Available', 'Maintenance') DEFAULT 'Available',
  FOREIGN KEY (screen_id) REFERENCES screens(screen_id) ON DELETE CASCADE,
  UNIQUE KEY (screen_id, seat_row, seat_number)
);

-- Show times for movies
CREATE TABLE shows (
  show_id INT PRIMARY KEY AUTO_INCREMENT,
  movie_id INT NOT NULL,
  screen_id INT NOT NULL,
  show_date DATE NOT NULL,
  start_time TIME NOT NULL,
  end_time TIME NOT NULL,
  is_full BOOLEAN DEFAULT FALSE,
  status ENUM('Scheduled', 'Cancelled', 'Completed') DEFAULT 'Scheduled',
  FOREIGN KEY (movie_id) REFERENCES movies(movie_id),
  FOREIGN KEY (screen_id) REFERENCES screens(screen_id),
  UNIQUE KEY (screen_id, show_date, start_time)
);

-- Pricing configurations
CREATE TABLE price_categories (
  category_id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(50) NOT NULL,
  description TEXT,
  theater_id INT,
  screen_type ENUM('Standard', 'IMAX', '3D', 'VIP', 'DBOX') DEFAULT NULL,
  seat_type ENUM('Regular', 'Premium', 'VIP', 'Wheelchair') DEFAULT NULL,
  day_of_week ENUM('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday') DEFAULT NULL,
  base_price DECIMAL(8,2) NOT NULL,
  is_active BOOLEAN DEFAULT TRUE,
  FOREIGN KEY (theater_id) REFERENCES theaters(theater_id) ON DELETE CASCADE
);

-- Users table
CREATE TABLE users (
  user_id INT PRIMARY KEY AUTO_INCREMENT,
  first_name VARCHAR(50) NOT NULL,
  last_name VARCHAR(50) NOT NULL,
  email VARCHAR(100) NOT NULL UNIQUE,
  phone_number VARCHAR(20),
  password_hash VARCHAR(255) NOT NULL,
  date_of_birth DATE,
  registration_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  last_login TIMESTAMP,
  verification_status BOOLEAN DEFAULT FALSE,
  status ENUM('Active', 'Inactive', 'Suspended') DEFAULT 'Active'
);

-- Bookings table
CREATE TABLE bookings (
  booking_id INT PRIMARY KEY AUTO_INCREMENT,
  user_id INT,
  show_id INT NOT NULL,
  booking_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  payment_status ENUM('Pending', 'Completed', 'Failed', 'Refunded') DEFAULT 'Pending',
  booking_status ENUM('Confirmed', 'Cancelled', 'Expired') DEFAULT 'Confirmed',
  total_amount DECIMAL(10,2) NOT NULL,
  discount_amount DECIMAL(8,2) DEFAULT 0.00,
  final_amount DECIMAL(10,2) NOT NULL,
  booking_reference VARCHAR(20) UNIQUE,
  FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE SET NULL,
  FOREIGN KEY (show_id) REFERENCES shows(show_id)
);

-- Booked seats
CREATE TABLE booking_seats (
  booking_seat_id INT PRIMARY KEY AUTO_INCREMENT,
  booking_id INT NOT NULL,
  seat_id INT NOT NULL,
  price DECIMAL(8,2) NOT NULL,
  FOREIGN KEY (booking_id) REFERENCES bookings(booking_id) ON DELETE CASCADE,
  FOREIGN KEY (seat_id) REFERENCES seats(seat_id),
  UNIQUE KEY (booking_id, seat_id)
);

-- Payments
CREATE TABLE payments (
  payment_id INT PRIMARY KEY AUTO_INCREMENT,
  booking_id INT NOT NULL,
  payment_method ENUM('Credit Card', 'Debit Card', 'Net Banking', 'UPI', 'Wallet', 'Cash') NOT NULL,
  transaction_id VARCHAR(100),
  payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  amount DECIMAL(10,2) NOT NULL,
  status ENUM('Initiated', 'Completed', 'Failed', 'Refunded') NOT NULL,
  gateway_response TEXT,
  FOREIGN KEY (booking_id) REFERENCES bookings(booking_id)
);

-- Promotions and discounts
CREATE TABLE promotions (
  promotion_id INT PRIMARY KEY AUTO_INCREMENT,
  code VARCHAR(20) UNIQUE,
  description TEXT,
  discount_type ENUM('Percentage', 'Fixed Amount') NOT NULL,
  discount_value DECIMAL(8,2) NOT NULL,
  start_date TIMESTAMP NOT NULL,
  end_date TIMESTAMP NOT NULL,
  min_purchase_amount DECIMAL(10,2) DEFAULT 0.00,
  max_discount_amount DECIMAL(8,2),
  usage_limit INT,
  current_usage INT DEFAULT 0,
  is_active BOOLEAN DEFAULT TRUE
);

-- Food and beverage items
CREATE TABLE concession_items (
  item_id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(100) NOT NULL,
  description TEXT,
  price DECIMAL(8,2) NOT NULL,
  category ENUM('Food', 'Beverage', 'Combo', 'Merchandise') NOT NULL,
  is_available BOOLEAN DEFAULT TRUE,
  image_url VARCHAR(255)
);

-- Food orders
CREATE TABLE concession_orders (
  order_id INT PRIMARY KEY AUTO_INCREMENT,
  booking_id INT,
  user_id INT,
  order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  total_amount DECIMAL(10,2) NOT NULL,
  status ENUM('Placed', 'Preparing', 'Ready', 'Delivered', 'Cancelled') DEFAULT 'Placed',
  FOREIGN KEY (booking_id) REFERENCES bookings(booking_id) ON DELETE SET NULL,
  FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE SET NULL
);

-- Food order items
CREATE TABLE concession_order_items (
  order_item_id INT PRIMARY KEY AUTO_INCREMENT,
  order_id INT NOT NULL,
  item_id INT NOT NULL,
  quantity INT NOT NULL,
  unit_price DECIMAL(8,2) NOT NULL,
  FOREIGN KEY (order_id) REFERENCES concession_orders(order_id) ON DELETE CASCADE,
  FOREIGN KEY (item_id) REFERENCES concession_items(item_id)
);

-- Customer support tickets
CREATE TABLE support_tickets (
  ticket_id INT PRIMARY KEY AUTO_INCREMENT,
  user_id INT,
  subject VARCHAR(255) NOT NULL,
  description TEXT NOT NULL,
  booking_id INT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  status ENUM('Open', 'In Progress', 'Resolved', 'Closed') DEFAULT 'Open',
  priority ENUM('Low', 'Medium', 'High', 'Critical') DEFAULT 'Medium',
  FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE SET NULL,
  FOREIGN KEY (booking_id) REFERENCES bookings(booking_id) ON DELETE SET NULL
);

-- Support ticket responses
CREATE TABLE ticket_responses (
  response_id INT PRIMARY KEY AUTO_INCREMENT,
  ticket_id INT NOT NULL,
  responder_type ENUM('User', 'Staff') NOT NULL,
  responder_id INT,
  response_text TEXT NOT NULL,
  response_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (ticket_id) REFERENCES support_tickets(ticket_id) ON DELETE CASCADE
);

-- Staff members
CREATE TABLE staff (
  staff_id INT PRIMARY KEY AUTO_INCREMENT,
  first_name VARCHAR(50) NOT NULL,
  last_name VARCHAR(50) NOT NULL,
  email VARCHAR(100) NOT NULL UNIQUE,
  phone_number VARCHAR(20),
  password_hash VARCHAR(255) NOT NULL,
  role ENUM('Admin', 'Manager', 'Cashier', 'Support', 'Concession') NOT NULL,
  theater_id INT,
  is_active BOOLEAN DEFAULT TRUE,
  FOREIGN KEY (theater_id) REFERENCES theaters(theater_id) ON DELETE SET NULL
);

-- Reviews and ratings
CREATE TABLE reviews (
  review_id INT PRIMARY KEY AUTO_INCREMENT,
  movie_id INT NOT NULL,
  user_id INT NOT NULL,
  rating DECIMAL(2,1) NOT NULL CHECK (rating BETWEEN 0 AND 5),
  review_text TEXT,
  review_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  status ENUM('Pending', 'Approved', 'Rejected') DEFAULT 'Pending',
  FOREIGN KEY (movie_id) REFERENCES movies(movie_id) ON DELETE CASCADE,
  FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
  UNIQUE KEY (movie_id, user_id)
);

-- User preferences to provide personalized recommendations
CREATE TABLE user_preferences (
  preference_id INT PRIMARY KEY AUTO_INCREMENT,
  user_id INT NOT NULL,
  genre VARCHAR(100),
  preferred_theater_id INT,
  preferred_day ENUM('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'),
  preferred_time_slot ENUM('Morning', 'Afternoon', 'Evening', 'Night'),
  preferred_seat_type ENUM('Regular', 'Premium', 'VIP', 'Wheelchair'),
  FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
  FOREIGN KEY (preferred_theater_id) REFERENCES theaters(theater_id) ON DELETE SET NULL
);

-- Movie schedule for upcoming weeks
CREATE TABLE movie_schedules (
  schedule_id INT PRIMARY KEY AUTO_INCREMENT,
  movie_id INT NOT NULL,
  theater_id INT NOT NULL,
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  status ENUM('Planned', 'Published', 'Cancelled') DEFAULT 'Planned',
  FOREIGN KEY (movie_id) REFERENCES movies(movie_id),
  FOREIGN KEY (theater_id) REFERENCES theaters(theater_id)
);

-- Index creation for better performance
CREATE INDEX idx_movies_status ON movies(status);
CREATE INDEX idx_shows_date ON shows(show_date);
CREATE INDEX idx_bookings_date ON bookings(booking_date);
CREATE INDEX idx_payments_status ON payments(status);
CREATE INDEX idx_user_email ON users(email);
CREATE INDEX idx_promotions_code ON promotions(code);
CREATE INDEX idx_support_status ON support_tickets(status);

-- Insert Movies
INSERT INTO movies (title, description, duration, release_date, genre, language, director, cast, poster_url, trailer_url, rating, status) VALUES
('Inception', 'A thief who steals corporate secrets through the use of dream-sharing technology is given the inverse task of planting an idea into the mind of a C.E.O.', 148, '2010-07-16', 'Sci-Fi', 'English', 'Christopher Nolan', 'Leonardo DiCaprio, Joseph Gordon-Levitt, Ellen Page', 'https://example.com/inception.jpg', 'https://example.com/inception-trailer.mp4', 8.8, 'Now Showing'),
('The Shawshank Redemption', 'Two imprisoned men bond over a number of years, finding solace and eventual redemption through acts of common decency.', 142, '1994-09-23', 'Drama', 'English', 'Frank Darabont', 'Tim Robbins, Morgan Freeman', 'https://example.com/shawshank.jpg', 'https://example.com/shawshank-trailer.mp4', 9.3, 'Now Showing'),
('Parasite', 'Greed and class discrimination threaten the newly formed symbiotic relationship between the wealthy Park family and the destitute Kim clan.', 132, '2019-05-30', 'Thriller', 'Korean', 'Bong Joon Ho', 'Song Kang-ho, Lee Sun-kyun, Cho Yeo-jeong', 'https://example.com/parasite.jpg', 'https://example.com/parasite-trailer.mp4', 8.6, 'Now Showing'),
('Avatar: The Way of Water', 'Jake Sully lives with his newfound family formed on the planet of Pandora.', 192, '2022-12-16', 'Action, Adventure, Fantasy', 'English', 'James Cameron', 'Sam Worthington, Zoe Saldana', 'https://example.com/avatar2.jpg', 'https://example.com/avatar2-trailer.mp4', 7.8, 'Now Showing'),
('Dune: Part Two', 'Paul Atreides unites with Chani and the Fremen while seeking revenge against the conspirators who destroyed his family.', 166, '2024-03-01', 'Sci-Fi, Adventure', 'English', 'Denis Villeneuve', 'Timothée Chalamet, Zendaya', 'https://example.com/dune2.jpg', 'https://example.com/dune2-trailer.mp4', 8.5, 'Now Showing'),
('Oppenheimer', 'The story of American scientist J. Robert Oppenheimer and his role in the development of the atomic bomb.', 180, '2023-07-21', 'Biography, Drama', 'English', 'Christopher Nolan', 'Cillian Murphy, Emily Blunt', 'https://example.com/oppenheimer.jpg', 'https://example.com/oppenheimer-trailer.mp4', 8.4, 'Now Showing'),
('The Batman', 'When a sadistic serial killer begins murdering key political figures in Gotham, Batman is forced to investigate the city\'s hidden corruption.', 176, '2022-03-04', 'Action, Crime, Drama', 'English', 'Matt Reeves', 'Robert Pattinson, Zoë Kravitz', 'https://example.com/batman.jpg', 'https://example.com/batman-trailer.mp4', 7.9, 'Now Showing'),
('Joker: Folie à Deux', 'Follow-up to the 2019 film Joker.', 135, '2024-10-04', 'Crime, Drama, Thriller', 'English', 'Todd Phillips', 'Joaquin Phoenix, Lady Gaga', 'https://example.com/joker2.jpg', 'https://example.com/joker2-trailer.mp4', 7.5, 'Coming Soon'),
('Furiosa: A Mad Max Saga', 'The origin story of renegade warrior Furiosa before she teams up with Mad Max.', 150, '2024-05-24', 'Action, Adventure', 'English', 'George Miller', 'Anya Taylor-Joy, Chris Hemsworth', 'https://example.com/furiosa.jpg', 'https://example.com/furiosa-trailer.mp4', 8.0, 'Coming Soon'),
('A Quiet Place: Day One', 'Experience the day the world went quiet.', 120, '2024-06-28', 'Horror, Sci-Fi', 'English', 'Michael Sarnoski', 'Lupita Nyong\'o, Joseph Quinn', 'https://example.com/quietplace3.jpg', 'https://example.com/quietplace3-trailer.mp4', 7.7, 'Coming Soon');

-- Insert Theaters
INSERT INTO theaters (name, location, address, contact_number, total_screens) VALUES
('CineStar Multiplex', 'Downtown', '123 Main Street, Downtown, City', '555-1234', 8),
('Grand Cinema', 'East Side', '456 Oak Avenue, East Side, City', '555-5678', 6),
('Royal Theaters', 'West End', '789 Pine Road, West End, City', '555-9012', 5),
('Lakeview Cinema', 'North District', '321 Lake Boulevard, North District, City', '555-3456', 4),
('Sunset Movie House', 'South Side', '654 Sunset Drive, South Side, City', '555-7890', 3);

-- Insert Screens for each theater
-- CineStar Multiplex screens
INSERT INTO screens (theater_id, screen_number, seating_capacity, screen_type) VALUES
(1, 1, 200, 'IMAX'),
(1, 2, 180, '3D'),
(1, 3, 150, 'Standard'),
(1, 4, 150, 'Standard'),
(1, 5, 120, 'Standard'),
(1, 6, 100, 'Standard'),
(1, 7, 80, 'VIP'),
(1, 8, 60, 'DBOX');

-- Grand Cinema screens
INSERT INTO screens (theater_id, screen_number, seating_capacity, screen_type) VALUES
(2, 1, 180, '3D'),
(2, 2, 160, 'Standard'),
(2, 3, 160, 'Standard'),
(2, 4, 140, 'Standard'),
(2, 5, 100, 'VIP'),
(2, 6, 70, 'DBOX');

-- Royal Theaters screens
INSERT INTO screens (theater_id, screen_number, seating_capacity, screen_type) VALUES
(3, 1, 170, 'IMAX'),
(3, 2, 150, 'Standard'),
(3, 3, 150, 'Standard'),
(3, 4, 120, 'Standard'),
(3, 5, 90, 'VIP');

-- Lakeview Cinema screens
INSERT INTO screens (theater_id, screen_number, seating_capacity, screen_type) VALUES
(4, 1, 160, '3D'),
(4, 2, 140, 'Standard'),
(4, 3, 140, 'Standard'),
(4, 4, 80, 'VIP');

-- Sunset Movie House screens
INSERT INTO screens (theater_id, screen_number, seating_capacity, screen_type) VALUES
(5, 1, 150, 'Standard'),
(5, 2, 130, 'Standard'),
(5, 3, 70, 'VIP');

-- Insert seats for screens (adding seats for first few screens as examples)
-- For Screen 1 at CineStar (IMAX)
INSERT INTO seats (screen_id, seat_row, seat_number, seat_type, status)
SELECT 1, 
       CHAR(65 + FLOOR((seat_id - 1) / 20)), 
       ((seat_id - 1) % 20) + 1, 
       CASE 
           WHEN FLOOR((seat_id - 1) / 20) < 2 THEN 'Regular'
           WHEN FLOOR((seat_id - 1) / 20) < 8 THEN 'Premium'
           ELSE 'VIP'
       END,
       'Available'
FROM (SELECT @row := @row + 1 AS seat_id
      FROM information_schema.columns, (SELECT @row := 0) r
      LIMIT 200) as t;

-- For Screen 2 at CineStar (3D)
INSERT INTO seats (screen_id, seat_row, seat_number, seat_type, status)
SELECT 2, 
       CHAR(65 + FLOOR((seat_id - 1) / 18)), 
       ((seat_id - 1) % 18) + 1, 
       CASE 
           WHEN FLOOR((seat_id - 1) / 18) < 2 THEN 'Regular'
           WHEN FLOOR((seat_id - 1) / 18) < 8 THEN 'Premium'
           ELSE 'VIP'
       END,
       'Available'
FROM (SELECT @row := @row + 1 AS seat_id
      FROM information_schema.columns, (SELECT @row := 0) r
      LIMIT 180) as t;
      
-- For Screen 1 at Grand Cinema (3D)
INSERT INTO seats (screen_id, seat_row, seat_number, seat_type, status)
SELECT 9, 
       CHAR(65 + FLOOR((seat_id - 1) / 18)), 
       ((seat_id - 1) % 18) + 1, 
       CASE 
           WHEN FLOOR((seat_id - 1) / 18) < 2 THEN 'Regular'
           WHEN FLOOR((seat_id - 1) / 18) < 8 THEN 'Premium'
           ELSE 'VIP'
       END,
       'Available'
FROM (SELECT @row := @row + 1 AS seat_id
      FROM information_schema.columns, (SELECT @row := 0) r
      LIMIT 180) as t;

-- Add wheelchair seats to each screen (as examples)
INSERT INTO seats (screen_id, seat_row, seat_number, seat_type, status) VALUES
(1, 'WC', 1, 'Wheelchair', 'Available'),
(1, 'WC', 2, 'Wheelchair', 'Available'),
(2, 'WC', 1, 'Wheelchair', 'Available'),
(9, 'WC', 1, 'Wheelchair', 'Available');

-- Insert Shows (movie screenings)
INSERT INTO shows (movie_id, screen_id, show_date, start_time, end_time, is_full, status) VALUES
-- Inception
(1, 1, '2024-04-14', '10:00:00', '12:30:00', false, 'Scheduled'),
(1, 1, '2024-04-14', '13:30:00', '16:00:00', false, 'Scheduled'),
(1, 1, '2024-04-14', '17:00:00', '19:30:00', false, 'Scheduled'),
(1, 1, '2024-04-14', '20:30:00', '23:00:00', false, 'Scheduled'),

-- The Shawshank Redemption
(2, 2, '2024-04-14', '11:00:00', '13:30:00', false, 'Scheduled'),
(2, 2, '2024-04-14', '14:30:00', '17:00:00', false, 'Scheduled'),
(2, 2, '2024-04-14', '18:00:00', '20:30:00', false, 'Scheduled'),
(2, 2, '2024-04-14', '21:30:00', '00:00:00', false, 'Scheduled'),

-- Parasite
(3, 3, '2024-04-14', '10:30:00', '12:45:00', false, 'Scheduled'),
(3, 3, '2024-04-14', '13:45:00', '16:00:00', false, 'Scheduled'),
(3, 3, '2024-04-14', '17:00:00', '19:15:00', false, 'Scheduled'),
(3, 3, '2024-04-14', '20:15:00', '22:30:00', false, 'Scheduled'),

-- Avatar: The Way of Water
(4, 9, '2024-04-14', '09:30:00', '12:45:00', false, 'Scheduled'),
(4, 9, '2024-04-14', '14:00:00', '17:15:00', false, 'Scheduled'),
(4, 9, '2024-04-14', '18:30:00', '21:45:00', false, 'Scheduled'),

-- Dune: Part Two
(5, 13, '2024-04-14', '10:00:00', '12:50:00', false, 'Scheduled'),
(5, 13, '2024-04-14', '14:00:00', '16:50:00', false, 'Scheduled'),
(5, 13, '2024-04-14', '18:00:00', '20:50:00', false, 'Scheduled'),
(5, 13, '2024-04-14', '21:30:00', '00:20:00', false, 'Scheduled'),

-- Shows for the next day (April 15, 2024)
(1, 1, '2024-04-15', '10:00:00', '12:30:00', false, 'Scheduled'),
(2, 2, '2024-04-15', '11:00:00', '13:30:00', false, 'Scheduled'),
(3, 3, '2024-04-15', '10:30:00', '12:45:00', false, 'Scheduled'),
(4, 9, '2024-04-15', '09:30:00', '12:45:00', false, 'Scheduled'),
(5, 13, '2024-04-15', '10:00:00', '12:50:00', false, 'Scheduled');

-- Insert Price Categories
INSERT INTO price_categories (name, description, theater_id, screen_type, seat_type, day_of_week, base_price, is_active) VALUES
('IMAX Standard', 'Standard pricing for IMAX screens', NULL, 'IMAX', 'Regular', NULL, 16.99, true),
('IMAX Premium', 'Premium seats in IMAX screens', NULL, 'IMAX', 'Premium', NULL, 19.99, true),
('IMAX VIP', 'VIP experience in IMAX screens', NULL, 'IMAX', 'VIP', NULL, 24.99, true),
('3D Standard', 'Standard pricing for 3D screens', NULL, '3D', 'Regular', NULL, 14.99, true),
('3D Premium', 'Premium seats in 3D screens', NULL, '3D', 'Premium', NULL, 17.99, true),
('3D VIP', 'VIP experience in 3D screens', NULL, '3D', 'VIP', NULL, 22.99, true),
('Standard Regular', 'Regular seats in standard screens', NULL, 'Standard', 'Regular', NULL, 12.99, true),
('Standard Premium', 'Premium seats in standard screens', NULL, 'Standard', 'Premium', NULL, 14.99, true),
('Standard VIP', 'VIP seating in standard screens', NULL, 'Standard', 'VIP', NULL, 18.99, true),
('DBOX Experience', 'Motion seats experience', NULL, 'DBOX', NULL, NULL, 22.99, true),
('Tuesday Discount', 'Special discount for all shows on Tuesdays', NULL, NULL, NULL, 'Tuesday', 9.99, true),
('Matinee Pricing', 'Special pricing for morning shows before 12 PM', NULL, NULL, NULL, NULL, 10.99, true),
('Weekend Premium', 'Additional charge for weekend shows', NULL, NULL, NULL, 'Saturday', 2.00, true),
('Weekend Premium', 'Additional charge for weekend shows', NULL, NULL, NULL, 'Sunday', 2.00, true);

-- Insert Users
INSERT INTO users (first_name, last_name, email, phone_number, password_hash, date_of_birth, registration_date, last_login, verification_status, status) VALUES
('John', 'Smith', 'john.smith@example.com', '555-123-4567', 'hashed_password_1', '1985-06-15', '2023-01-10 14:30:00', '2024-04-13 09:15:00', true, 'Active'),
('Sarah', 'Johnson', 'sarah.j@example.com', '555-234-5678', 'hashed_password_2', '1990-03-22', '2023-02-05 11:45:00', '2024-04-12 18:20:00', true, 'Active'),
('Michael', 'Brown', 'michael.b@example.com', '555-345-6789', 'hashed_password_3', '1978-11-08', '2023-03-12 16:20:00', '2024-04-10 20:05:00', true, 'Active'),
('Emily', 'Davis', 'emily.d@example.com', '555-456-7890', 'hashed_password_4', '1995-08-30', '2023-04-18 09:10:00', '2024-04-11 14:30:00', true, 'Active'),
('David', 'Wilson', 'david.w@example.com', '555-567-8901', 'hashed_password_5', '1982-12-03', '2023-05-22 13:15:00', '2024-04-09 19:45:00', true, 'Active'),
('Jessica', 'Taylor', 'jessica.t@example.com', '555-678-9012', 'hashed_password_6', '1992-05-17', '2023-06-14 10:30:00', '2024-04-08 17:10:00', true, 'Active'),
('Daniel', 'Anderson', 'daniel.a@example.com', '555-789-0123', 'hashed_password_7', '1975-09-26', '2023-07-08 15:45:00', '2024-04-07 12:25:00', true, 'Active'),
('Jennifer', 'Martinez', 'jennifer.m@example.com', '555-890-1234', 'hashed_password_8', '1988-02-14', '2023-08-19 12:00:00', '2024-04-13 10:35:00', true, 'Active'),
('Christopher', 'Garcia', 'chris.g@example.com', '555-901-2345', 'hashed_password_9', '1993-07-11', '2023-09-25 17:20:00', '2024-04-12 21:15:00', true, 'Active'),
('Amanda', 'Rodriguez', 'amanda.r@example.com', '555-012-3456', 'hashed_password_10', '1980-10-04', '2023-10-30 14:10:00', '2024-04-11 16:50:00', true, 'Active');

-- Insert Bookings
INSERT INTO bookings (user_id, show_id, booking_date, payment_status, booking_status, total_amount, discount_amount, final_amount, booking_reference) VALUES
(1, 1, '2024-04-10 10:15:00', 'Completed', 'Confirmed', 33.98, 0.00, 33.98, 'BK24041001'),
(2, 5, '2024-04-10 11:30:00', 'Completed', 'Confirmed', 29.98, 0.00, 29.98, 'BK24041002'),
(3, 9, '2024-04-10 12:45:00', 'Completed', 'Confirmed', 25.98, 0.00, 25.98, 'BK24041003'),
(4, 13, '2024-04-10 14:00:00', 'Completed', 'Confirmed', 35.98, 3.00, 32.98, 'BK24041004'),
(5, 17, '2024-04-11 09:15:00', 'Completed', 'Confirmed', 27.98, 0.00, 27.98, 'BK24041101'),
(6, 2, '2024-04-11 10:30:00', 'Completed', 'Confirmed', 39.98, 0.00, 39.98, 'BK24041102'),
(7, 6, '2024-04-11 11:45:00', 'Completed', 'Confirmed', 35.98, 0.00, 35.98, 'BK24041103'),
(8, 10, '2024-04-12 13:00:00', 'Completed', 'Confirmed', 25.98, 0.00, 25.98, 'BK24041201'),
(9, 14, '2024-04-12 14:15:00', 'Completed', 'Confirmed', 45.96, 5.00, 40.96, 'BK24041202'),
(10, 18, '2024-04-12 15:30:00', 'Completed', 'Confirmed', 31.98, 0.00, 31.98, 'BK24041203'),
(1, 3, '2024-04-13 09:45:00', 'Pending', 'Confirmed', 49.98, 0.00, 49.98, 'BK24041301'),
(2, 7, '2024-04-13 11:00:00', 'Pending', 'Confirmed', 35.98, 0.00, 35.98, 'BK24041302');

-- Insert Booking Seats (for the first few bookings)
-- For booking 1 (User 1 booked 2 seats for Inception IMAX showing)
INSERT INTO booking_seats (booking_id, seat_id, price) VALUES
(1, 1, 16.99), -- Row A, Seat 1
(1, 2, 16.99); -- Row A, Seat 2

-- For booking 2 (User 2 booked 2 seats for The Shawshank Redemption 3D showing)
INSERT INTO booking_seats (booking_id, seat_id, price) VALUES
(2, 201, 14.99), -- Row A, Seat 1
(2, 202, 14.99); -- Row A, Seat 2

-- For booking 3 (User 3 booked 2 seats for Parasite Standard showing)
INSERT INTO booking_seats (booking_id, seat_id, price) VALUES
(3, 385, 12.99), -- Example seatconcession_order_itemsconcession_order_items
(3, 386, 12.99); -- Example seat

-- Insert Payments
INSERT INTO payments (booking_id, payment_method, transaction_id, payment_date, amount, status, gateway_response) VALUES
(1, 'Credit Card', 'TXN12345678', '2024-04-10 10:20:00', 33.98, 'Completed', '{"status": "approved", "auth_code": "A12345"}'),
(2, 'Debit Card', 'TXN23456789', '2024-04-10 11:35:00', 29.98, 'Completed', '{"status": "approved", "auth_code": "B23456"}'),
(3, 'Credit Card', 'TXN34567890', '2024-04-10 12:50:00', 25.98, 'Completed', '{"status": "approved", "auth_code": "C34567"}'),
(4, 'UPI', 'TXN45678901', '2024-04-10 14:05:00', 32.98, 'Completed', '{"status": "approved", "auth_code": "D45678"}'),
(5, 'Credit Card', 'TXN56789012', '2024-04-11 09:20:00', 27.98, 'Completed', '{"status": "approved", "auth_code": "E56789"}'),
(6, 'Net Banking', 'TXN67890123', '2024-04-11 10:35:00', 39.98, 'Completed', '{"status": "approved", "auth_code": "F67890"}'),
(7, 'Debit Card', 'TXN78901234', '2024-04-11 11:50:00', 35.98, 'Completed', '{"status": "approved", "auth_code": "G78901"}'),
(8, 'Credit Card', 'TXN89012345', '2024-04-12 13:05:00', 25.98, 'Completed', '{"status": "approved", "auth_code": "H89012"}'),
(9, 'Wallet', 'TXN90123456', '2024-04-12 14:20:00', 40.96, 'Completed', '{"status": "approved", "auth_code": "I90123"}'),
(10, 'Credit Card', 'TXN01234567', '2024-04-12 15:35:00', 31.98, 'Completed', '{"status": "approved", "auth_code": "J01234"}');

-- Insert Promotions
INSERT INTO promotions (code, description, discount_type, discount_value, start_date, end_date, min_purchase_amount, max_discount_amount, usage_limit, current_usage, is_active) VALUES
('WELCOME10', 'Welcome discount for new users', 'Percentage', 10.00, '2024-01-01 00:00:00', '2024-12-31 23:59:59', 0.00, 50.00, 1000, 345, true),
('SUMMER25', 'Summer special discount', 'Percentage', 25.00, '2024-06-01 00:00:00', '2024-08-31 23:59:59', 30.00, 100.00, 500, 0, true),
('FLAT5', 'Flat discount on all bookings', 'Fixed Amount', 5.00, '2024-04-01 00:00:00', '2024-04-30 23:59:59', 20.00, NULL, 2000, 683, true),
('WEEKEND15', 'Weekend special offer', 'Percentage', 15.00, '2024-01-01 00:00:00', '2024-12-31 23:59:59', 40.00, 75.00, NULL, 1209, true),
('FAMILY20', 'Family pack discount', 'Percentage', 20.00, '2024-01-01 00:00:00', '2024-12-31 23:59:59', 60.00, 120.00, 1000, 542, true);

-- Insert Concession Items
INSERT INTO concession_items (name, description, price, category, is_available, image_url) VALUES
('Large Popcorn', 'Freshly popped buttery popcorn in a large container', 8.99, 'Food', true, 'https://example.com/large-popcorn.jpg'),
('Medium Popcorn', 'Freshly popped buttery popcorn in a medium container', 6.99, 'Food', true, 'https://example.com/medium-popcorn.jpg'),
('Small Popcorn', 'Freshly popped buttery popcorn in a small container', 4.99, 'Food', true, 'https://example.com/small-popcorn.jpg'),
('Large Soda', 'Refreshing soda of your choice in a large cup', 5.99, 'Beverage', true, 'https://example.com/large-soda.jpg'),
('Medium Soda', 'Refreshing soda of your choice in a medium cup', 4.99, 'Beverage', true, 'https://example.com/medium-soda.jpg'),
('Small Soda', 'Refreshing soda of your choice in a small cup', 3.99, 'Beverage', true, 'https://example.com/small-soda.jpg'),
('Nachos with Cheese', 'Crispy nachos with warm cheese dip', 7.99, 'Food', true, 'https://example.com/nachos.jpg'),
('Hot Dog', 'Juicy hot dog with condiments', 5.99, 'Food', true, 'https://example.com/hotdog.jpg'),
('Candy Pack', 'Assorted chocolate and candy', 4.49, 'Food', true, 'https://example.com/candy.jpg'),
('Movie Combo 1', 'Large popcorn, large soda, and candy', 16.99, 'Combo', true, 'https://example.com/combo1.jpg'),
('Movie Combo 2', 'Medium popcorn, medium soda, and nachos', 15.99, 'Combo', true, 'https://example.com/combo2.jpg'),
('Family Pack', '2 large popcorns, 4 large sodas, and 2 candy packs', 29.99, 'Combo', true, 'https://example.com/family-pack.jpg'),
('Cinema T-Shirt', 'Official cinema branded t-shirt', 19.99, 'Merchandise', true, 'https://example.com/tshirt.jpg'),
('Movie Poster', 'Collectible movie poster', 14.99, 'Merchandise', true, 'https://example.com/poster.jpg');

-- Insert Concession Orders
INSERT INTO concession_orders (booking_id, user_id, order_date, total_amount, status) VALUES
(1, 1, '2024-04-10 10:25:00', 24.97, 'Delivered'),
(2, 2, '2024-04-10 11:40:00', 16.99, 'Delivered'),
(3, 3, '2024-04-10 12:55:00', 15.98, 'Delivered'),
(6, 6, '2024-04-11 10:40:00', 29.99, 'Delivered'),
(8, 8, '2024-04-12 13:10:00', 15.99, 'Delivered');

-- Insert Concession Order Items
INSERT INTO concession_order_items (order_id, item_id, quantity, unit_price) VALUES
(1, 1, 1, 8.99),  -- Large Popcorn
(1, 4, 2, 5.99),  -- 2 Large Sodas
(1, 9, 1, 4.49),  -- Candy Pack
(2, 10, 1, 16.99), -- Movie Combo 1
(3, 2, 1, 6.99),  -- Medium Popcorn
(3, 5, 1, 4.99),  -- Medium Soda
(3, 7, 1, 7.99),  -- Nachos with Cheese
(4, 12, 1, 29.99), -- Family Pack
(5, 11, 1, 15.99); -- Movie Combo 2

-- Insert Support Tickets
INSERT INTO support_tickets (user_id, subject, description, booking_id, created_at, status, priority) VALUES
(4, 'Refund Request', 'I was charged twice for my booking. Please refund one transaction.', 4, '2024-04-10 16:30:00', 'Open', 'High'),
(7, 'Seat Change', 'I would like to change my seats for the upcoming show if possible.', 7, '2024-04-11 14:15:00', 'In Progress', 'Medium'),
(9, 'Missing Concession Order', 'I paid for nachos but didn\'t receive them.', 5, '2024-04-12 16:45:00', 'Resolved', 'Medium');

-- Insert Ticket Responses
INSERT INTO ticket_responses (ticket_id, responder_type, responder_id, response_text, response_time) VALUES
(1, 'Staff', 1, 'We have verified your payment records and found the duplicate charge. A refund has been initiated and will reflect in your account within 3-5 business days.', '2024-04-10 17:15:00'),
(1, 'User', 4, 'Thank you for the quick response. I will wait for the refund.', '2024-04-10 18:30:00'),
(2, 'Staff', 2, 'We can assist with changing your seats. Which seats would you prefer for your show?', '2024-04-11 14:45:00'),
(2, 'User', 7, 'I would prefer seats in row F if available.', '2024-04-11 15:20:00'),
(2, 'Staff', 2, 'We have changed your seats to F10 and F11. Your updated tickets have been sent to your email.', '2024-04-11 16:00:00'),
(3, 'Staff', 3, 'We apologize for the inconvenience. We will provide a complimentary nachos during your next visit.', '2024-04-12 17:15:00'),
(3, 'User', 9, 'Thank you for resolving this issue.', '2024-04-12 18:00:00');

-- Insert Staff Members
INSERT INTO staff (first_name, last_name, email, phone_number, password_hash, role, theater_id, is_active) VALUES
('Robert', 'Anderson', 'robert.a@cinemadb.com', '555-111-2222', 'staff_hash_1', 'Admin', NULL, true),
('Lisa', 'Thompson', 'lisa.t@cinemadb.com', '555-222-3333', 'staff_hash_2', 'Manager', 1, true),
('Kevin', 'Garcia', 'kevin.g@cinemadb.com', '555-333-4444', 'staff_hash_3', 'Support', 2, true),
('Michelle', 'Brown', 'michelle.b@cinemadb.com', '555-444-5555', 'staff_hash_4', 'Cashier', 1, true),
('Jason', 'Martinez', 'jason.m@cinemadb.com', '555-555-6666', 'staff_hash_5', 'Concession', 1, true),
('Laura', 'Wilson', 'laura.w@cinemadb.com', '555-666-7777', 'staff_hash_6', 'Manager', 2, true),
('Carlos', 'Rodriguez', 'carlos.r@cinemadb.com', '555-777-8888', 'staff_hash_7', 'Cashier', 3, true),
('Sophia', 'Lee', 'sophia.l@cinemadb.com', '555-888-9999', 'staff_hash_8', 'Support', NULL, true);

-- Insert Reviews and Ratings
INSERT INTO reviews (movie_id, user_id, rating, review_text, review_date, status) VALUES
(1, 1, 4.5, 'Mind-bending and visually stunning. Christopher Nolan at his best.', '2024-04-01 10:20:00', 'Approved'),
(1, 3, 5.0, 'One of the greatest movies ever made. The concept and execution are perfect.', '2024-04-02 14:30:00', 'Approved'),
(1, 5, 4.0, 'Great film but can be confusing at times. Requires multiple viewings.', '2024-04-03 16:45:00', 'Approved'),
(2, 2, 5.0, 'A timeless classic. Morgan Freeman\'s narration is perfection.', '2024-04-01 11:15:00', 'Approved'),
(2, 4, 4.5, 'Powerful story of hope and redemption. Deserves all the acclaim it gets.', '2024-04-03 09:45:00', 'Approved'),
(3, 6, 4.0, 'Brilliant social commentary with unexpected twists and turns.', '2024-04-02 19:20:00', 'Approved'),
(3, 8, 5.0, 'A masterpiece that deserved the Oscar. Unforgettable and thought-provoking.', '2024-04-04 12:30:00', 'Approved'),
(4, 7, 4.0, 'Visually breathtaking with amazing special effects. Story is good but not great.', '2024-04-05 16:10:00', 'Approved'),
(4, 9, 3.5, 'Beautiful to look at but a bit too long. Could have been more concise.', '2024-04-06 20:15:00', 'Approved'),
(5, 10, 4.5, 'Spectacular sci-fi epic with great performances. Denis Villeneuve has done justice to the book.', '2024-04-07 14:25:00', 'Approved'),
(5, 1, 5.0, 'Perfect continuation of the Dune saga. The visuals and sound design are incredible.', '2024-04-08 10:30:00', 'Approved'),
(6, 2, 5.0, 'Cillian Murphy delivers the performance of a lifetime. Nolan\'s direction is impeccable.', '2024-04-03 11:40:00', 'Approved'),
(7, 3, 4.0, 'Dark and atmospheric take on Batman. Robert Pattinson is surprisingly good.', '2024-04-04 15:50:00', 'Approved');

-- Insert User Preferences
INSERT INTO user_preferences (user_id, genre, preferred_theater_id, preferred_day, preferred_time_slot, preferred_seat_type) VALUES
(1, 'Sci-Fi', 1, 'Saturday', 'Evening', 'Premium'),
(2, 'Drama', 2, 'Friday', 'Night', 'VIP'),
(3, 'Thriller', 1, 'Sunday', 'Afternoon', 'Premium'),
(4, 'Action', 3, 'Saturday', 'Evening', 'Regular'),
(5, 'Adventure', 1, 'Wednesday', 'Night', 'Premium'),
(6, 'Fantasy', 2, 'Thursday', 'Evening', 'VIP'),
(7, 'Sci-Fi', 3, 'Tuesday', 'Afternoon', 'Regular'),
(8, 'Biography', 4, 'Monday', 'Evening', 'Premium'),
(9, 'Horror', 1, 'Friday', 'Night', 'Regular'),
(10, 'Drama', 2, 'Saturday', 'Evening', 'VIP');

-- Insert Movie Schedules
INSERT INTO movie_schedules (movie_id, theater_id, start_date, end_date, status) VALUES
(1, 1, '2024-04-01', '2024-04-30', 'Published'),
(1, 2, '2024-04-01', '2024-04-30', 'Published'),
(2, 1, '2024-04-01', '2024-04-30', 'Published'),
(2, 3, '2024-04-01', '2024-04-30', 'Published'),
(3, 2, '2024-04-01', '2024-04-30', 'Published'),
(3, 4, '2024-04-01', '2024-04-30', 'Published'),
(4, 1, '2024-04-01', '2024-04-30', 'Published'),
(4, 2, '2024-04-01', '2024-04-30', 'Published'),
(5, 3, '2024-04-01', '2024-04-30', 'Published'),
(5, 5, '2024-04-01', '2024-04-30', 'Published'),
(6, 1, '2024-04-01', '2024-04-30', 'Published'),
(6, 4, '2024-04-01', '2024-04-30', 'Published'),
(7, 2, '2024-04-01', '2024-04-30', 'Published'),
(7, 5, '2024-04-01', '2024-04-30', 'Published'),
(8, 1, '2024-05-01', '2024-05-31', 'Planned'),
(9, 1, '2024-05-25', '2024-06-25', 'Planned'),
(10, 1, '2024-06-28', '2024-07-28', 'Planned');

-- New table for movie cast members (1NF improvement)
CREATE TABLE movie_cast (
  cast_id INT PRIMARY KEY AUTO_INCREMENT,
  movie_id INT NOT NULL,
  actor_name VARCHAR(100) NOT NULL,
  character_name VARCHAR(100),
  is_lead_role BOOLEAN DEFAULT FALSE,
  FOREIGN KEY (movie_id) REFERENCES movies(movie_id) ON DELETE CASCADE,
  UNIQUE KEY (movie_id, actor_name)
);
-- Base pricing table (2NF improvement)
CREATE TABLE base_prices (
  base_price_id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(50) NOT NULL,
  description TEXT,
  base_amount DECIMAL(8,2) NOT NULL,
  theater_id INT,
  is_active BOOLEAN DEFAULT TRUE,
  FOREIGN KEY (theater_id) REFERENCES theaters(theater_id) ON DELETE CASCADE
);

-- Price modifiers table (2NF improvement)
CREATE TABLE price_modifiers (
  modifier_id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(50) NOT NULL,
  screen_type ENUM('Standard', 'IMAX', '3D', 'VIP', 'DBOX') DEFAULT NULL,
  seat_type ENUM('Regular', 'Premium', 'VIP', 'Wheelchair') DEFAULT NULL,
  day_of_week ENUM('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday') DEFAULT NULL,
  modifier_type ENUM('Percentage', 'Fixed Amount') NOT NULL,
  modifier_value DECIMAL(8,2) NOT NULL,
  is_active BOOLEAN DEFAULT TRUE
);
-- Bookings table (3NF improvement - removed final_amount)
CREATE TABLE bookings_without_derived_attribute (
  booking_id INT PRIMARY KEY AUTO_INCREMENT,
  user_id INT,
  show_id INT NOT NULL,
  booking_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  payment_status ENUM('Pending', 'Completed', 'Failed', 'Refunded') DEFAULT 'Pending',
  booking_status ENUM('Confirmed', 'Cancelled', 'Expired') DEFAULT 'Confirmed',
  total_amount DECIMAL(10,2) NOT NULL,
  discount_amount DECIMAL(8,2) DEFAULT 0.00,
  booking_reference VARCHAR(20) UNIQUE,
  FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE SET NULL,
  FOREIGN KEY (show_id) REFERENCES shows(show_id)
);
-- Insert Movie Cast (new table for 1NF improvement)
INSERT INTO movie_cast (movie_id, actor_name, character_name, is_lead_role) VALUES
-- Inception cast
(1, 'Leonardo DiCaprio', 'Dom Cobb', TRUE),
(1, 'Joseph Gordon-Levitt', 'Arthur', TRUE),
(1, 'Ellen Page', 'Ariadne', TRUE),
(1, 'Tom Hardy', 'Eames', FALSE),
(1, 'Ken Watanabe', 'Saito', FALSE),

-- Shawshank Redemption cast
(2, 'Tim Robbins', 'Andy Dufresne', TRUE),
(2, 'Morgan Freeman', 'Ellis Boyd "Red" Redding', TRUE),
(2, 'Bob Gunton', 'Warden Norton', FALSE),
(2, 'William Sadler', 'Heywood', FALSE),

-- Parasite cast
(3, 'Song Kang-ho', 'Kim Ki-taek', TRUE),
(3, 'Lee Sun-kyun', 'Park Dong-ik', TRUE),
(3, 'Cho Yeo-jeong', 'Choi Yeon-gyo', TRUE),
(3, 'Park So-dam', 'Kim Ki-jung', FALSE),

-- More cast entries for other movies
(4, 'Sam Worthington', 'Jake Sully', TRUE),
(4, 'Zoe Saldana', 'Neytiri', TRUE),
(4, 'Sigourney Weaver', 'Dr. Grace Augustine', FALSE),

(5, 'Timothée Chalamet', 'Paul Atreides', TRUE),
(5, 'Zendaya', 'Chani', TRUE),
(5, 'Rebecca Ferguson', 'Lady Jessica', FALSE),
(5, 'Josh Brolin', 'Gurney Halleck', FALSE),

(6, 'Cillian Murphy', 'J. Robert Oppenheimer', TRUE),
(6, 'Emily Blunt', 'Katherine Oppenheimer', TRUE),
(6, 'Matt Damon', 'Leslie Groves', FALSE),
(6, 'Robert Downey Jr.', 'Lewis Strauss', FALSE),

(7, 'Robert Pattinson', 'Bruce Wayne / Batman', TRUE),
(7, 'Zoë Kravitz', 'Selina Kyle / Catwoman', TRUE),
(7, 'Paul Dano', 'The Riddler', FALSE),
(7, 'Colin Farrell', 'Oswald Cobblepot / Penguin', FALSE);

-- Insert Base Prices (new table for 2NF improvement)
INSERT INTO base_prices (name, description, base_amount, theater_id, is_active) VALUES
('Standard Base Price', 'Standard base ticket price', 12.99, NULL, true),
('CineStar Premium', 'Base price for CineStar Multiplex', 14.99, 1, true),
('Grand Cinema Base', 'Base price for Grand Cinema', 13.99, 2, true),
('Royal Theaters Base', 'Base price for Royal Theaters', 14.50, 3, true),
('Lakeview Base', 'Base price for Lakeview Cinema', 12.50, 4, true),
('Sunset Base', 'Base price for Sunset Movie House', 11.99, 5, true),
('Matinee Base', 'Base price for morning shows', 10.99, NULL, true),
('Weekend Base', 'Base price for weekend shows', 14.99, NULL, true);

-- Insert Price Modifiers (new table for 2NF improvement)
INSERT INTO price_modifiers (name, screen_type, seat_type, day_of_week, modifier_type, modifier_value, is_active) VALUES
('IMAX Premium', 'IMAX', NULL, NULL, 'Percentage', 25.00, true),
('3D Addition', '3D', NULL, NULL, 'Fixed Amount', 2.00, true),
('VIP Seat Premium', NULL, 'VIP', NULL, 'Percentage', 30.00, true),
('Premium Seat Addition', NULL, 'Premium', NULL, 'Fixed Amount', 2.00, true),
('Tuesday Discount', NULL, NULL, 'Tuesday', 'Percentage', -15.00, true),
('Weekend Surcharge', NULL, NULL, 'Saturday', 'Percentage', 10.00, true),
('Weekend Surcharge', NULL, NULL, 'Sunday', 'Percentage', 10.00, true),
('DBOX Experience', 'DBOX', NULL, NULL, 'Fixed Amount', 5.00, true),
('Wheelchair Accessible Discount', NULL, 'Wheelchair', NULL, 'Percentage', -10.00, true),
('Standard Screen Discount', 'Standard', NULL, NULL, 'Percentage', -5.00, true);

-- Insert Bookings (modified for 3NF - no final_amount column)
INSERT INTO bookings_without_derived_attribute (user_id, show_id, booking_date, payment_status, booking_status, total_amount, discount_amount, booking_reference) VALUES
(1, 1, '2024-04-10 10:15:00', 'Completed', 'Confirmed', 33.98, 0.00, 'BK24041001'),
(2, 5, '2024-04-10 11:30:00', 'Completed', 'Confirmed', 29.98, 0.00, 'BK24041002'),
(3, 9, '2024-04-10 12:45:00', 'Completed', 'Confirmed', 25.98, 0.00, 'BK24041003'),
(4, 13, '2024-04-10 14:00:00', 'Completed', 'Confirmed', 35.98, 3.00, 'BK24041004'),
(5, 17, '2024-04-11 09:15:00', 'Completed', 'Confirmed', 27.98, 0.00, 'BK24041101'),
(6, 2, '2024-04-11 10:30:00', 'Completed', 'Confirmed', 39.98, 0.00, 'BK24041102'),
(7, 6, '2024-04-11 11:45:00', 'Completed', 'Confirmed', 35.98, 0.00, 'BK24041103'),
(8, 10, '2024-04-12 13:00:00', 'Completed', 'Confirmed', 25.98, 0.00, 'BK24041201'),
(9, 14, '2024-04-12 14:15:00', 'Completed', 'Confirmed', 45.96, 5.00, 'BK24041202'),
(10, 18, '2024-04-12 15:30:00', 'Completed', 'Confirmed', 31.98, 0.00, 'BK24041203'),
(1, 3, '2024-04-13 09:45:00', 'Pending', 'Confirmed', 49.98, 0.00, 'BK24041301'),
(2, 7, '2024-04-13 11:00:00', 'Pending', 'Confirmed', 35.98, 0.00, 'BK24041302');

SELECT m.title, m.genre, m.status, COALESCE(AVG(r.rating), 0) as average_rating
FROM movies m
LEFT JOIN reviews r ON m.movie_id = r.movie_id
WHERE m.status = 'Now Showing'
GROUP BY m.movie_id, m.title, m.genre, m.status
ORDER BY average_rating DESC;
SELECT m.title, COUNT(b.booking_id) as booking_count
FROM movies m
INNER JOIN shows s ON m.movie_id = s.movie_id
INNER JOIN bookings b ON s.show_id = b.show_id
GROUP BY m.movie_id, m.title
ORDER BY booking_count DESC
LIMIT 5;

SELECT t.name as theater_name, t.location, COUNT(s.screen_id) as screen_count
FROM theaters t
INNER JOIN screens s ON t.theater_id = s.theater_id
GROUP BY t.theater_id, t.name, t.location
ORDER BY screen_count DESC;

DELIMITER //
CREATE PROCEDURE create_simple_booking(
    IN user_id_param INT,
    IN show_id_param INT,
    IN seat_id_param INT,
    IN price_param DECIMAL(8,2)
)
BEGIN
    DECLARE new_booking_id INT;
    DECLARE booking_ref VARCHAR(20);
    
    -- Generate a random booking reference
    SET booking_ref = CONCAT('BK', DATE_FORMAT(NOW(), '%y%m%d'), LPAD(FLOOR(RAND() * 1000), 3, '0'));
    
    -- Insert booking
    INSERT INTO bookings (user_id, show_id, booking_date, payment_status, booking_status, total_amount,final_amount, booking_reference)
    VALUES (user_id_param, show_id_param, NOW(), 'Pending', 'Confirmed', price_param,price_param, booking_ref);
    
    -- Get the new booking ID
    SET new_booking_id = LAST_INSERT_ID();
    
    -- Insert booking seat
    INSERT INTO booking_seats (booking_id, seat_id, price)
    VALUES (new_booking_id, seat_id_param, price_param);
    
    -- Return the booking reference
    SELECT booking_ref AS booking_reference;
END //
DELIMITER ;
CALL create_simple_booking(1, 2, 5, 250.00);

DELIMITER //
CREATE PROCEDURE update_movie_status()
BEGIN
    -- Update movie status based on release date
    UPDATE movies 
    SET status = 'Now Showing' 
    WHERE release_date <= CURDATE() 
    AND status = 'Coming Soon';
    
    UPDATE movies 
    SET status = 'No Longer Showing' 
    WHERE movie_id NOT IN (SELECT DISTINCT movie_id FROM shows WHERE show_date >= CURDATE())
    AND status = 'Now Showing';
    
    SELECT 'Movie statuses updated successfully' AS message;
END //
DELIMITER ;
CALL update_movie_status();
DELIMITER //
CREATE TRIGGER update_show_end_time
BEFORE UPDATE ON shows
FOR EACH ROW
BEGIN
    DECLARE movie_runtime INT;
    
    -- Get movie duration
    SELECT duration INTO movie_runtime 
    FROM movies 
    WHERE movie_id = NEW.movie_id;
    
    -- If start time has changed, update end time
    IF OLD.start_time <> NEW.start_time THEN
        SET NEW.end_time = ADDTIME(NEW.start_time, SEC_TO_TIME(movie_runtime * 60));
    END IF;
END //
DELIMITER ;

DELIMITER //
CREATE TABLE IF NOT EXISTS user_status_logs (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    old_status VARCHAR(20),
    new_status VARCHAR(20),
    change_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

CREATE TRIGGER log_user_status_change
AFTER UPDATE ON users
FOR EACH ROW
BEGIN
    IF OLD.status <> NEW.status THEN
        INSERT INTO user_status_logs (user_id, old_status, new_status)
        VALUES (NEW.user_id, OLD.status, NEW.status);
    END IF;
END //

DELIMITER ;

DELIMITER //
CREATE FUNCTION get_theater_daily_revenue(theater_id_param INT, revenue_date DATE)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE total_revenue DECIMAL(10,2) DEFAULT 0;

    -- Sum up ticket sales revenue
    SELECT COALESCE(SUM(b.total_amount), 0) INTO total_revenue
    FROM bookings b
    JOIN shows s ON b.show_id = s.show_id
    JOIN screens scr ON s.screen_id = scr.screen_id
    WHERE scr.theater_id = theater_id_param
    AND DATE(b.booking_date) = revenue_date
    AND b.payment_status = 'Completed';

    -- Add concession sales revenue
    SELECT total_revenue + COALESCE(SUM(co.total_amount), 0) INTO total_revenue
    FROM concession_orders co
    JOIN bookings b ON co.booking_id = b.booking_id
    JOIN shows s ON b.show_id = s.show_id
    JOIN screens scr ON s.screen_id = scr.screen_id
    WHERE scr.theater_id = theater_id_param
    AND DATE(co.order_date) = revenue_date;

    RETURN total_revenue;
END //

DELIMITER ;
SELECT get_theater_daily_revenue(2, '2025-04-14') AS daily_revenue;





















































