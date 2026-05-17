-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: localhost
-- Generation Time: May 17, 2026 at 08:01 AM
-- Server version: 10.4.28-MariaDB
-- PHP Version: 8.2.4

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `valuevault`
--

-- --------------------------------------------------------

--
-- Table structure for table `bids`
--

CREATE TABLE `bids` (
  `id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `item_id` int(11) DEFAULT NULL,
  `bid_amount` decimal(10,2) NOT NULL,
  `status` enum('pending','accepted','rejected') DEFAULT 'pending',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `bids`
--

INSERT INTO `bids` (`id`, `user_id`, `item_id`, `bid_amount`, `status`, `created_at`) VALUES
(7, 4, 7, 13000.00, 'rejected', '2026-05-03 08:21:50'),
(8, 4, 8, 30200.00, 'accepted', '2026-05-05 15:32:06'),
(10, 4, 10, 55000.00, 'accepted', '2026-05-15 03:38:01'),
(11, 7, 7, 15000.00, 'accepted', '2026-05-15 03:46:00'),
(14, 7, 11, 500100.00, 'pending', '2026-05-15 07:07:07'),
(15, 4, 12, 20100.00, 'accepted', '2026-05-15 07:31:07');

-- --------------------------------------------------------

--
-- Table structure for table `items`
--

CREATE TABLE `items` (
  `id` int(11) NOT NULL,
  `title` varchar(200) NOT NULL,
  `description` text DEFAULT NULL,
  `starting_price` decimal(10,2) NOT NULL,
  `current_bid` decimal(10,2) DEFAULT 0.00,
  `image_url` varchar(255) DEFAULT NULL,
  `status` enum('active','ended') DEFAULT 'active',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `items`
--

INSERT INTO `items` (`id`, `title`, `description`, `starting_price`, `current_bid`, `image_url`, `status`, `created_at`) VALUES
(5, 'the official site logo', 'the first site logo sold form the online shop', 10000.00, 20000.00, '1777716377734.png', 'ended', '2026-05-02 10:06:17'),
(7, 'king crown', 'the crown of the king', 12000.00, 15000.00, '1777793384015.webp', 'ended', '2026-05-03 07:29:44'),
(8, 'Kettle Clock', 'A kettle clock from 17th century.;', 20000.00, 30200.00, '1777994857900.webp', 'ended', '2026-05-05 15:27:37'),
(10, 'Vintage Iphone', 'Vintage iphone form late era, very rare (unopened).', 45000.00, 55000.00, '1777995046491.jpg', 'ended', '2026-05-05 15:30:46'),
(11, 'A really cool horse', 'Its a really cool looking horse', 500000.00, 500100.00, '1778817192630.jpg', 'active', '2026-05-15 03:53:12'),
(12, 'Glass glass sculptures', 'Cool glass sculptures, great for house decoration', 20000.00, 20100.00, '1778817299617.jpg', 'ended', '2026-05-15 03:54:59');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password` varchar(255) NOT NULL,
  `role` enum('admin','user') DEFAULT 'user',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `security_question` varchar(255) DEFAULT NULL,
  `security_answer` varchar(255) DEFAULT NULL,
  `failed_attempts` int(11) NOT NULL DEFAULT 0,
  `lockout_until` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `name`, `email`, `password`, `role`, `created_at`, `security_question`, `security_answer`, `failed_attempts`, `lockout_until`) VALUES
(1, 'Admin', 'admin@valuevault.com', '240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9', 'admin', '2026-05-02 05:19:21', NULL, NULL, 0, NULL),
(4, 'kangaroo dhulla', 'kangaroo@gmail.com', '7b24729ddee97d838838f185b90d4ef0e071e69226f3cced5f675a2c5f07fec0', 'user', '2026-05-03 07:55:28', 'What was your childhood nickname?', 'bf86fab4af14dc6ff4bf1982641ccb39faf48e4b3d91bc0c083705822c168c3c', 0, NULL),
(6, 'test user', 'user@test.com', 'ecd71870d1963316a97e3ac3408c9835ad8cf0f3c1bc703527c30265534f75ae', 'user', '2026-05-15 03:04:09', 'What is the name of your first pet?', '9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08', 6, '2026-05-15 09:55:09'),
(7, 'john', 'john@gmail.com', 'b4b597c714a8f49103da4dab0266af0ee0ae4f8575250a84855c3d76941cd422', 'user', '2026-05-15 03:45:31', 'What is the name of your first pet?', 'd25137d6a70981fcae5e58ce0ecb61827b3f7bfc5d3e545a0b73d0365603445b', 0, NULL);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `bids`
--
ALTER TABLE `bids`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `item_id` (`item_id`);

--
-- Indexes for table `items`
--
ALTER TABLE `items`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `bids`
--
ALTER TABLE `bids`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT for table `items`
--
ALTER TABLE `items`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `bids`
--
ALTER TABLE `bids`
  ADD CONSTRAINT `bids_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `bids_ibfk_2` FOREIGN KEY (`item_id`) REFERENCES `items` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
