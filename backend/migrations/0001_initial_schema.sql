-- ===========================================================
-- Migration: 0001_initial_schema
-- Description: Consolidated initial schema for Astana Karya
-- Generated automatically from original migrations (0001-0105)
-- ===========================================================

SET FOREIGN_KEY_CHECKS = 0;

CREATE TABLE `consultation_messages` (
  `id_consultation_message` bigint unsigned NOT NULL AUTO_INCREMENT,
  `consultation_id` bigint unsigned NOT NULL,
  `sender_user_id` bigint unsigned NOT NULL,
  `sender_name` varchar(100) NOT NULL,
  `sender_role` enum('staf','admin','pembeli') NOT NULL,
  `message_type` varchar(20) NOT NULL DEFAULT 'text',
  `message` text NOT NULL,
  `media_path` varchar(255) DEFAULT NULL,
  `media_name` varchar(160) DEFAULT NULL,
  `media_mime` varchar(80) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `read_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id_consultation_message`),
  KEY `consultation_messages_consultation_id_idx` (`consultation_id`),
  KEY `consultation_messages_sender_user_id_idx` (`sender_user_id`),
  CONSTRAINT `consultation_messages_consultation_id_foreign` FOREIGN KEY (`consultation_id`) REFERENCES `property_consultation_requests` (`id_property_consultation_request`) ON DELETE CASCADE,
  CONSTRAINT `consultation_messages_sender_user_id_foreign` FOREIGN KEY (`sender_user_id`) REFERENCES `users` (`id_user`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `invoices` (
  `id_invoice` bigint unsigned NOT NULL AUTO_INCREMENT,
  `invoice_number` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `purchase_id` bigint unsigned NOT NULL,
  `buyer_id` bigint unsigned NOT NULL,
  `property_id` bigint unsigned NOT NULL,
  `property_name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `property_price` decimal(15,2) NOT NULL,
  `payment_method` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `payment_proof_url` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `payment_status` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT 'pending',
  `issued_at` timestamp NULL DEFAULT NULL,
  `due_date` date DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_invoice`),
  UNIQUE KEY `invoice_number` (`invoice_number`),
  UNIQUE KEY `purchase_id` (`purchase_id`),
  KEY `idx_invoice_number` (`invoice_number`),
  KEY `idx_purchase_id` (`purchase_id`),
  KEY `idx_buyer_id` (`buyer_id`),
  KEY `idx_property_id` (`property_id`),
  KEY `idx_issued_at` (`issued_at`),
  CONSTRAINT `fk_invoice_buyer_id` FOREIGN KEY (`buyer_id`) REFERENCES `users` (`id_user`) ON DELETE CASCADE,
  CONSTRAINT `fk_invoice_property_id` FOREIGN KEY (`property_id`) REFERENCES `properties` (`id_property`) ON DELETE CASCADE,
  CONSTRAINT `fk_invoice_purchase_id` FOREIGN KEY (`purchase_id`) REFERENCES `property_purchases` (`id_purchase`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `notifications` (
  `id_notification` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint unsigned NOT NULL,
  `title` varchar(160) NOT NULL,
  `message` text NOT NULL,
  `type` varchar(40) NOT NULL DEFAULT 'info',
  `action_url` varchar(255) DEFAULT NULL,
  `image_url` varchar(255) DEFAULT NULL,
  `read_at` datetime DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_notification`),
  KEY `notifications_user_id_created_at_index` (`user_id`,`created_at`),
  KEY `notifications_user_id_read_at_index` (`user_id`,`read_at`),
  CONSTRAINT `notifications_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id_user`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `password_reset_requests` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint unsigned NOT NULL,
  `code_hash` varchar(255) NOT NULL,
  `expires_at` datetime NOT NULL,
  `verified_at` datetime DEFAULT NULL,
  `consumed_at` datetime DEFAULT NULL,
  `attempt_count` int NOT NULL DEFAULT '0',
  `last_sent_at` datetime NOT NULL,
  `reset_session_token_hash` varchar(255) DEFAULT NULL,
  `reset_session_expires_at` datetime DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `password_reset_requests_user_id_index` (`user_id`),
  KEY `password_reset_requests_expires_at_index` (`expires_at`),
  CONSTRAINT `password_reset_requests_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id_user`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `properties` (
  `id_property` bigint unsigned NOT NULL AUTO_INCREMENT,
  `title` varchar(150) NOT NULL,
  `category` varchar(50) NOT NULL,
  `location` varchar(150) NOT NULL,
  `price` bigint unsigned NOT NULL,
  `status` varchar(30) NOT NULL DEFAULT 'Tersedia',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_property`),
  KEY `properties_status_index` (`status`)
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `property_consultation_requests` (
  `id_property_consultation_request` bigint unsigned NOT NULL AUTO_INCREMENT,
  `buyer_user_id` bigint unsigned NOT NULL,
  `property_id` bigint unsigned DEFAULT NULL,
  `topic` varchar(100) NOT NULL,
  `preferred_contact_method` varchar(40) NOT NULL DEFAULT 'WhatsApp',
  `message` text NOT NULL,
  `status` varchar(20) NOT NULL DEFAULT 'pending',
  `staff_notes` text,
  `processed_by_user_id` bigint unsigned DEFAULT NULL,
  `processed_at` datetime DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_property_consultation_request`),
  KEY `property_consultation_requests_status_index` (`status`),
  KEY `property_consultation_requests_buyer_user_id_index` (`buyer_user_id`),
  KEY `property_consultation_requests_property_id_index` (`property_id`),
  KEY `property_consultation_requests_processed_by_user_id_index` (`processed_by_user_id`),
  CONSTRAINT `property_consultation_requests_buyer_user_id_foreign` FOREIGN KEY (`buyer_user_id`) REFERENCES `users` (`id_user`) ON DELETE CASCADE,
  CONSTRAINT `property_consultation_requests_processed_by_user_id_foreign` FOREIGN KEY (`processed_by_user_id`) REFERENCES `users` (`id_user`) ON DELETE SET NULL,
  CONSTRAINT `property_consultation_requests_property_id_foreign` FOREIGN KEY (`property_id`) REFERENCES `properties` (`id_property`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `property_gallery_images` (
  `id_property_gallery_image` bigint unsigned NOT NULL AUTO_INCREMENT,
  `property_id` bigint unsigned NOT NULL,
  `image_url` varchar(255) NOT NULL,
  `title` varchar(120) NOT NULL,
  `subtitle` varchar(255) DEFAULT NULL,
  `detail_primary` varchar(180) DEFAULT NULL,
  `detail_secondary` varchar(180) DEFAULT NULL,
  `sort_order` smallint unsigned NOT NULL DEFAULT '1',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_property_gallery_image`),
  UNIQUE KEY `property_gallery_images_property_order_unique` (`property_id`,`sort_order`),
  KEY `property_gallery_images_property_id_index` (`property_id`),
  CONSTRAINT `property_gallery_images_property_id_foreign` FOREIGN KEY (`property_id`) REFERENCES `properties` (`id_property`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=110 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `property_images` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `property_id` bigint unsigned NOT NULL,
  `image_url` varchar(255) NOT NULL,
  `display_order` smallint unsigned NOT NULL DEFAULT '1',
  `is_primary` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `property_images_property_id_index` (`property_id`),
  CONSTRAINT `property_images_property_id_foreign` FOREIGN KEY (`property_id`) REFERENCES `properties` (`id_property`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `property_purchases` (
  `id_purchase` bigint unsigned NOT NULL AUTO_INCREMENT,
  `buyer_user_id` bigint unsigned NOT NULL,
  `property_id` bigint unsigned NOT NULL,
  `payment_method` varchar(30) NOT NULL,
  `payment_account_number` varchar(50) DEFAULT NULL,
  `payment_account_name` varchar(150) DEFAULT NULL,
  `payment_amount` bigint unsigned DEFAULT NULL,
  `payment_due_at` datetime DEFAULT NULL,
  `cancelled_at` datetime DEFAULT NULL,
  `buyer_name_snapshot` varchar(150) NOT NULL,
  `buyer_phone_snapshot` varchar(20) DEFAULT NULL,
  `buyer_address_snapshot` text,
  `notes` text,
  `status` varchar(30) NOT NULL DEFAULT 'pending_payment',
  `payment_proof_path` varchar(500) DEFAULT NULL,
  `payment_proof_uploaded_at` datetime DEFAULT NULL,
  `processed_by_user_id` bigint unsigned DEFAULT NULL,
  `processed_by_name` varchar(150) DEFAULT NULL,
  `rejection_reason` varchar(500) DEFAULT NULL,
  `processed_at` datetime DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_purchase`),
  KEY `pp_buyer_user_id_index` (`buyer_user_id`),
  KEY `pp_property_id_index` (`property_id`),
  KEY `pp_status_index` (`status`),
  KEY `pp_processed_by_user_id_index` (`processed_by_user_id`),
  KEY `pp_payment_due_at_index` (`payment_due_at`),
  CONSTRAINT `pp_buyer_user_id_foreign` FOREIGN KEY (`buyer_user_id`) REFERENCES `users` (`id_user`) ON DELETE CASCADE,
  CONSTRAINT `pp_processed_by_user_id_foreign` FOREIGN KEY (`processed_by_user_id`) REFERENCES `users` (`id_user`) ON DELETE SET NULL,
  CONSTRAINT `pp_property_id_foreign` FOREIGN KEY (`property_id`) REFERENCES `properties` (`id_property`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `survey_requests` (
  `id_survey` bigint unsigned NOT NULL AUTO_INCREMENT,
  `buyer_user_id` bigint unsigned NOT NULL,
  `property_id` bigint unsigned NOT NULL,
  `requested_date` date NOT NULL,
  `requested_time` time DEFAULT NULL,
  `notes` text,
  `status` varchar(20) NOT NULL DEFAULT 'pending',
  `approved_schedule_date` date DEFAULT NULL,
  `approved_schedule_time` time DEFAULT NULL,
  `rejection_reason` varchar(255) DEFAULT NULL,
  `processed_by_user_id` bigint unsigned DEFAULT NULL,
  `processed_at` datetime DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_survey`),
  KEY `survey_requests_status_index` (`status`),
  KEY `survey_requests_buyer_user_id_index` (`buyer_user_id`),
  KEY `survey_requests_property_id_index` (`property_id`),
  KEY `survey_requests_processed_by_user_id_index` (`processed_by_user_id`),
  CONSTRAINT `survey_requests_buyer_user_id_foreign` FOREIGN KEY (`buyer_user_id`) REFERENCES `users` (`id_user`) ON DELETE CASCADE,
  CONSTRAINT `survey_requests_processed_by_user_id_foreign` FOREIGN KEY (`processed_by_user_id`) REFERENCES `users` (`id_user`) ON DELETE SET NULL,
  CONSTRAINT `survey_requests_property_id_foreign` FOREIGN KEY (`property_id`) REFERENCES `properties` (`id_property`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `todo_lists` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint unsigned NOT NULL,
  `title` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `status` enum('pending','completed') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `due_date` date DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_todo_user_id` (`user_id`),
  KEY `idx_todo_status` (`status`),
  KEY `idx_todo_due_date` (`due_date`),
  CONSTRAINT `fk_todo_lists_user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id_user`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `user_buyer_profiles` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint unsigned NOT NULL,
  `whatsapp` varchar(20) DEFAULT NULL,
  `contact_note` varchar(255) DEFAULT NULL,
  `recipient_name` varchar(100) DEFAULT NULL,
  `address_line` varchar(255) DEFAULT NULL,
  `province` varchar(100) DEFAULT NULL,
  `city` varchar(100) DEFAULT NULL,
  `district` varchar(100) DEFAULT NULL,
  `subdistrict` varchar(100) DEFAULT NULL,
  `postal_code` varchar(10) DEFAULT NULL,
  `landmark` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_buyer_profiles_user_id_unique` (`user_id`),
  CONSTRAINT `user_buyer_profiles_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id_user`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `user_property_preferences` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint unsigned NOT NULL,
  `preferred_categories` text NOT NULL,
  `preferred_location` varchar(150) DEFAULT NULL,
  `min_price` bigint unsigned DEFAULT NULL,
  `max_price` bigint unsigned DEFAULT NULL,
  `min_bedrooms` tinyint unsigned DEFAULT NULL,
  `min_bathrooms` tinyint unsigned DEFAULT NULL,
  `min_building_area` int unsigned DEFAULT NULL,
  `min_land_area` int unsigned DEFAULT NULL,
  `notes` text,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_property_preferences_user_id_unique` (`user_id`),
  CONSTRAINT `user_property_preferences_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id_user`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `users` (
  `id_user` bigint unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `email` varchar(191) NOT NULL,
  `phone` varchar(20) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `role` enum('staf','admin','pembeli') NOT NULL DEFAULT 'pembeli',
  `profile_photo_path` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id_user`),
  UNIQUE KEY `users_email_unique` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SET FOREIGN_KEY_CHECKS = 1;
