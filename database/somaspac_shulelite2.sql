-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Oct 23, 2026 at 12:21 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `somaspac_shulelite2`
--

-- --------------------------------------------------------

--
-- Table structure for table `academic_classes`
--

CREATE TABLE `academic_classes` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(80) NOT NULL,
  `created_by` bigint(20) UNSIGNED DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `academic_class_subjects`
--

CREATE TABLE `academic_class_subjects` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `class_id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(100) NOT NULL,
  `created_by` bigint(20) UNSIGNED DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `ai_provider_settings`
--

CREATE TABLE `ai_provider_settings` (
  `id` tinyint(3) UNSIGNED NOT NULL,
  `provider` varchar(40) NOT NULL DEFAULT 'openrouter',
  `model` varchar(160) NOT NULL DEFAULT 'openai/gpt-4o-mini',
  `api_key_ciphertext` text NOT NULL,
  `updated_by` bigint(20) UNSIGNED NOT NULL,
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `ai_question_import_batches`
--

CREATE TABLE `ai_question_import_batches` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `school_id` bigint(20) UNSIGNED NOT NULL,
  `created_by` bigint(20) UNSIGNED NOT NULL,
  `import_key` char(64) NOT NULL,
  `question_ids` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`question_ids`)),
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `audit_logs`
--

CREATE TABLE `audit_logs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `actor_id` bigint(20) UNSIGNED DEFAULT NULL,
  `action` varchar(100) NOT NULL,
  `entity_type` varchar(80) NOT NULL,
  `entity_id` bigint(20) UNSIGNED DEFAULT NULL,
  `details` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`details`)),
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `audit_logs`
--

INSERT INTO `audit_logs` (`id`, `actor_id`, `action`, `entity_type`, `entity_id`, `details`, `created_at`) VALUES
(1, 3, 'create', 'school', 1, '{\"name\":\"Nyamata Academy\",\"director_id\":5,\"director_created\":false}', '2026-10-22 12:49:38'),
(2, 1, 'create', 'school_subscription_discount', 1, '{\"school_id\":1,\"school\":\"Nyamata Academy\",\"before\":false,\"after\":{\"discount_percent\":20,\"reason\":\"\",\"active\":true}}', '2026-10-23 10:20:25');

-- --------------------------------------------------------

--
-- Table structure for table `class_timetable_entries`
--

CREATE TABLE `class_timetable_entries` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `school_id` bigint(20) UNSIGNED NOT NULL,
  `class_id` bigint(20) UNSIGNED NOT NULL,
  `stream_id` bigint(20) UNSIGNED DEFAULT NULL,
  `subject_id` bigint(20) UNSIGNED NOT NULL,
  `teacher_id` bigint(20) UNSIGNED NOT NULL,
  `day_of_week` tinyint(3) UNSIGNED NOT NULL,
  `starts_at` time NOT NULL,
  `ends_at` time NOT NULL,
  `room` varchar(80) DEFAULT NULL,
  `status` enum('draft','published','archived') NOT NULL DEFAULT 'draft',
  `created_by` bigint(20) UNSIGNED NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ;

-- --------------------------------------------------------

--
-- Table structure for table `departments`
--

CREATE TABLE `departments` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `school_id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(120) NOT NULL,
  `department_type` enum('general','academic') NOT NULL DEFAULT 'general',
  `head_user_id` bigint(20) UNSIGNED DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `department_reports`
--

CREATE TABLE `department_reports` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `school_id` bigint(20) UNSIGNED NOT NULL,
  `department_id` bigint(20) UNSIGNED NOT NULL,
  `author_id` bigint(20) UNSIGNED NOT NULL,
  `report_type` enum('weekly','monthly','termly') NOT NULL,
  `period_start` date NOT NULL,
  `period_end` date NOT NULL,
  `narrative` text DEFAULT NULL,
  `recommendations` text DEFAULT NULL,
  `activity_snapshot` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`activity_snapshot`)),
  `status` enum('draft','submitted','approved','returned') NOT NULL DEFAULT 'draft',
  `review_feedback` text DEFAULT NULL,
  `reviewed_by` bigint(20) UNSIGNED DEFAULT NULL,
  `reviewed_at` datetime DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ;

-- --------------------------------------------------------

--
-- Table structure for table `department_subjects`
--

CREATE TABLE `department_subjects` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `school_id` bigint(20) UNSIGNED NOT NULL,
  `department_id` bigint(20) UNSIGNED NOT NULL,
  `class_subject_id` bigint(20) UNSIGNED NOT NULL,
  `created_by` bigint(20) UNSIGNED NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `employee_attendance`
--

CREATE TABLE `employee_attendance` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `school_id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `attendance_date` date NOT NULL,
  `check_in_at` datetime NOT NULL,
  `check_out_at` datetime DEFAULT NULL,
  `check_in_by` bigint(20) UNSIGNED NOT NULL,
  `check_out_by` bigint(20) UNSIGNED DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `employee_contracts`
--

CREATE TABLE `employee_contracts` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `school_id` bigint(20) UNSIGNED NOT NULL,
  `start_date` date NOT NULL,
  `end_date` date NOT NULL,
  `terms` text DEFAULT NULL,
  `status` enum('active','ended','renewed') NOT NULL DEFAULT 'active',
  `renewed_from_id` bigint(20) UNSIGNED DEFAULT NULL,
  `created_by` bigint(20) UNSIGNED NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `employee_documents`
--

CREATE TABLE `employee_documents` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `school_id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `category` enum('contract','qualification','identity','other') NOT NULL DEFAULT 'other',
  `original_name` varchar(255) NOT NULL,
  `stored_name` char(64) NOT NULL,
  `mime_type` varchar(80) NOT NULL,
  `byte_size` int(10) UNSIGNED NOT NULL,
  `uploaded_by` bigint(20) UNSIGNED NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `employee_profiles`
--

CREATE TABLE `employee_profiles` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `school_id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `employee_number` varchar(60) DEFAULT NULL,
  `job_title` varchar(140) DEFAULT NULL,
  `department` varchar(120) DEFAULT NULL,
  `employment_type` enum('full_time','part_time','casual','volunteer','contract') DEFAULT NULL,
  `created_by` bigint(20) UNSIGNED NOT NULL,
  `updated_by` bigint(20) UNSIGNED NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `exam_paper_questions`
--

CREATE TABLE `exam_paper_questions` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `exam_id` bigint(20) UNSIGNED NOT NULL,
  `question_id` bigint(20) UNSIGNED NOT NULL,
  `section_name` varchar(120) NOT NULL DEFAULT 'Section A',
  `sequence_no` smallint(5) UNSIGNED NOT NULL,
  `marks` decimal(6,2) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ;

-- --------------------------------------------------------

--
-- Table structure for table `fee_assessments`
--

CREATE TABLE `fee_assessments` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `school_id` bigint(20) UNSIGNED NOT NULL,
  `structure_id` bigint(20) UNSIGNED NOT NULL,
  `item_id` bigint(20) UNSIGNED NOT NULL,
  `pupil_id` bigint(20) UNSIGNED NOT NULL,
  `ledger_entry_id` bigint(20) UNSIGNED NOT NULL,
  `applied_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `fee_reconciliation_batches`
--

CREATE TABLE `fee_reconciliation_batches` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `school_id` bigint(20) UNSIGNED NOT NULL,
  `statement_name` varchar(180) NOT NULL,
  `statement_date` date NOT NULL,
  `status` enum('reviewing','completed') NOT NULL DEFAULT 'reviewing',
  `row_count` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `matched_count` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `created_by` bigint(20) UNSIGNED NOT NULL,
  `completed_by` bigint(20) UNSIGNED DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `completed_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `fee_reconciliation_lines`
--

CREATE TABLE `fee_reconciliation_lines` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `batch_id` bigint(20) UNSIGNED NOT NULL,
  `school_id` bigint(20) UNSIGNED NOT NULL,
  `line_number` int(10) UNSIGNED NOT NULL,
  `transaction_date` date NOT NULL,
  `amount` decimal(12,2) NOT NULL,
  `reference` varchar(100) NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `matched_ledger_id` bigint(20) UNSIGNED DEFAULT NULL,
  `match_status` enum('matched','unmatched','amount_mismatch','duplicate_reference','ignored') NOT NULL DEFAULT 'unmatched',
  `review_note` varchar(255) DEFAULT NULL
) ;

-- --------------------------------------------------------

--
-- Table structure for table `fee_structures`
--

CREATE TABLE `fee_structures` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `school_id` bigint(20) UNSIGNED NOT NULL,
  `class_id` bigint(20) UNSIGNED NOT NULL,
  `academic_year` smallint(5) UNSIGNED NOT NULL,
  `term` varchar(40) NOT NULL,
  `title` varchar(180) NOT NULL,
  `status` enum('draft','published','archived') NOT NULL DEFAULT 'draft',
  `created_by` bigint(20) UNSIGNED NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `fee_structure_items`
--

CREATE TABLE `fee_structure_items` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `structure_id` bigint(20) UNSIGNED NOT NULL,
  `school_id` bigint(20) UNSIGNED NOT NULL,
  `sequence_no` smallint(5) UNSIGNED NOT NULL,
  `description` varchar(180) NOT NULL,
  `amount` decimal(12,2) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ;

-- --------------------------------------------------------

--
-- Table structure for table `holiday_packages`
--

CREATE TABLE `holiday_packages` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `school_id` bigint(20) UNSIGNED NOT NULL,
  `class_id` bigint(20) UNSIGNED NOT NULL,
  `subject_id` bigint(20) UNSIGNED NOT NULL,
  `title` varchar(180) NOT NULL,
  `holiday_period` varchar(100) NOT NULL,
  `introduction` text DEFAULT NULL,
  `available_from` date DEFAULT NULL,
  `available_until` date DEFAULT NULL,
  `status` enum('draft','submitted','approved','returned','published','archived') NOT NULL DEFAULT 'draft',
  `created_by` bigint(20) UNSIGNED NOT NULL,
  `reviewed_by` bigint(20) UNSIGNED DEFAULT NULL,
  `reviewed_at` timestamp NULL DEFAULT NULL,
  `review_feedback` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `holiday_package_items`
--

CREATE TABLE `holiday_package_items` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `package_id` bigint(20) UNSIGNED NOT NULL,
  `school_id` bigint(20) UNSIGNED NOT NULL,
  `sequence_no` smallint(5) UNSIGNED NOT NULL,
  `item_type` enum('material','exercise','activity') NOT NULL,
  `title` varchar(180) NOT NULL,
  `instructions` text DEFAULT NULL,
  `content` mediumtext DEFAULT NULL,
  `learning_note_id` bigint(20) UNSIGNED DEFAULT NULL,
  `question_id` bigint(20) UNSIGNED DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `holiday_package_progress`
--

CREATE TABLE `holiday_package_progress` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `package_id` bigint(20) UNSIGNED NOT NULL,
  `school_id` bigint(20) UNSIGNED NOT NULL,
  `pupil_id` bigint(20) UNSIGNED NOT NULL,
  `status` enum('assigned','in_progress','completed') NOT NULL DEFAULT 'assigned',
  `pupil_response` mediumtext DEFAULT NULL,
  `teacher_feedback` text DEFAULT NULL,
  `feedback_by` bigint(20) UNSIGNED DEFAULT NULL,
  `feedback_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `homework_assignments`
--

CREATE TABLE `homework_assignments` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `school_id` bigint(20) UNSIGNED NOT NULL,
  `teacher_id` bigint(20) UNSIGNED NOT NULL,
  `class_level` varchar(80) NOT NULL,
  `subject` varchar(100) NOT NULL,
  `title` varchar(180) NOT NULL,
  `instructions` text NOT NULL,
  `due_date` date DEFAULT NULL,
  `learning_note_id` bigint(20) UNSIGNED DEFAULT NULL,
  `status` enum('draft','published','archived') NOT NULL DEFAULT 'draft',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `inventory_categories`
--

CREATE TABLE `inventory_categories` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `school_id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(100) NOT NULL,
  `status` enum('active','inactive') NOT NULL DEFAULT 'active',
  `created_by` bigint(20) UNSIGNED NOT NULL,
  `updated_by` bigint(20) UNSIGNED NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `inventory_items`
--

CREATE TABLE `inventory_items` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `school_id` bigint(20) UNSIGNED NOT NULL,
  `category_id` bigint(20) UNSIGNED DEFAULT NULL,
  `item_name` varchar(160) NOT NULL,
  `quantity` decimal(10,2) NOT NULL DEFAULT 0.00,
  `last_unit_cost` decimal(12,2) DEFAULT NULL,
  `reorder_threshold` decimal(10,2) DEFAULT NULL,
  `unit` varchar(30) NOT NULL DEFAULT 'item',
  `updated_by` bigint(20) UNSIGNED NOT NULL,
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `inventory_movements`
--

CREATE TABLE `inventory_movements` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `school_id` bigint(20) UNSIGNED NOT NULL,
  `item_id` bigint(20) UNSIGNED NOT NULL,
  `supplier_id` bigint(20) UNSIGNED DEFAULT NULL,
  `request_id` bigint(20) UNSIGNED DEFAULT NULL,
  `movement_type` enum('received','issued','adjusted') NOT NULL,
  `quantity` decimal(10,2) NOT NULL,
  `unit_cost` decimal(12,2) DEFAULT NULL,
  `balance_before` decimal(10,2) DEFAULT NULL,
  `balance_after` decimal(10,2) DEFAULT NULL,
  `note` varchar(255) DEFAULT NULL,
  `recorded_by` bigint(20) UNSIGNED NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `inventory_requests`
--

CREATE TABLE `inventory_requests` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `school_id` bigint(20) UNSIGNED NOT NULL,
  `item_id` bigint(20) UNSIGNED NOT NULL,
  `quantity` decimal(10,2) NOT NULL,
  `request_note` varchar(255) DEFAULT NULL,
  `status` enum('pending','approved','rejected','issued','cancelled') NOT NULL DEFAULT 'pending',
  `review_note` varchar(255) DEFAULT NULL,
  `requested_by` bigint(20) UNSIGNED NOT NULL,
  `reviewed_by` bigint(20) UNSIGNED DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `reviewed_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `inventory_stocktakes`
--

CREATE TABLE `inventory_stocktakes` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `school_id` bigint(20) UNSIGNED NOT NULL,
  `reference` varchar(80) NOT NULL,
  `status` enum('draft','submitted','applied','rejected') NOT NULL DEFAULT 'draft',
  `note` varchar(1000) DEFAULT NULL,
  `review_note` varchar(1000) DEFAULT NULL,
  `created_by` bigint(20) UNSIGNED NOT NULL,
  `reviewed_by` bigint(20) UNSIGNED DEFAULT NULL,
  `reviewed_at` timestamp NULL DEFAULT NULL,
  `applied_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `inventory_stocktake_lines`
--

CREATE TABLE `inventory_stocktake_lines` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `stocktake_id` bigint(20) UNSIGNED NOT NULL,
  `school_id` bigint(20) UNSIGNED NOT NULL,
  `item_id` bigint(20) UNSIGNED NOT NULL,
  `snapshot_quantity` decimal(10,2) NOT NULL,
  `counted_quantity` decimal(10,2) DEFAULT NULL,
  `line_note` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ;

-- --------------------------------------------------------

--
-- Table structure for table `inventory_suppliers`
--

CREATE TABLE `inventory_suppliers` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `school_id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(160) NOT NULL,
  `contact_name` varchar(140) DEFAULT NULL,
  `phone` varchar(40) DEFAULT NULL,
  `email` varchar(190) DEFAULT NULL,
  `status` enum('active','inactive') NOT NULL DEFAULT 'active',
  `created_by` bigint(20) UNSIGNED NOT NULL,
  `updated_by` bigint(20) UNSIGNED NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `learning_notes`
--

CREATE TABLE `learning_notes` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `note_type` enum('central','teacher') NOT NULL,
  `title` varchar(180) NOT NULL,
  `class_level` varchar(80) NOT NULL,
  `subject` varchar(100) DEFAULT NULL,
  `topic` varchar(180) DEFAULT NULL,
  `content` mediumtext NOT NULL,
  `source` varchar(180) DEFAULT NULL,
  `author_id` bigint(20) UNSIGNED NOT NULL,
  `school_id` bigint(20) UNSIGNED DEFAULT NULL,
  `status` enum('published','draft') NOT NULL DEFAULT 'published',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `learning_note_terms`
--

CREATE TABLE `learning_note_terms` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `term_type` enum('class','subject') NOT NULL,
  `name` varchar(100) NOT NULL,
  `created_by` bigint(20) UNSIGNED NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `lesson_plans`
--

CREATE TABLE `lesson_plans` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `school_id` bigint(20) UNSIGNED NOT NULL,
  `scheme_id` bigint(20) UNSIGNED NOT NULL,
  `stream_id` bigint(20) UNSIGNED DEFAULT NULL,
  `topic_id` bigint(20) UNSIGNED NOT NULL,
  `teacher_id` bigint(20) UNSIGNED NOT NULL,
  `scheduled_for` date DEFAULT NULL,
  `title` varchar(180) NOT NULL,
  `objectives` text NOT NULL,
  `introduction` text DEFAULT NULL,
  `activities` text NOT NULL,
  `materials` text DEFAULT NULL,
  `differentiation` text DEFAULT NULL,
  `assessment` text DEFAULT NULL,
  `reflection` text DEFAULT NULL,
  `status` enum('draft','submitted','approved','returned','completed') NOT NULL DEFAULT 'draft',
  `reviewed_by` bigint(20) UNSIGNED DEFAULT NULL,
  `reviewed_at` timestamp NULL DEFAULT NULL,
  `review_feedback` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `lesson_plan_resources`
--

CREATE TABLE `lesson_plan_resources` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `school_id` bigint(20) UNSIGNED NOT NULL,
  `lesson_plan_id` bigint(20) UNSIGNED NOT NULL,
  `learning_note_id` bigint(20) UNSIGNED NOT NULL,
  `created_by` bigint(20) UNSIGNED NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `parent_conversations`
--

CREATE TABLE `parent_conversations` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `school_id` bigint(20) UNSIGNED NOT NULL,
  `pupil_id` bigint(20) UNSIGNED NOT NULL,
  `guardian_user_id` bigint(20) UNSIGNED NOT NULL,
  `staff_user_id` bigint(20) UNSIGNED NOT NULL,
  `status` enum('open','closed') NOT NULL DEFAULT 'open',
  `last_message_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `parent_messages`
--

CREATE TABLE `parent_messages` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `conversation_id` bigint(20) UNSIGNED NOT NULL,
  `school_id` bigint(20) UNSIGNED NOT NULL,
  `sender_user_id` bigint(20) UNSIGNED NOT NULL,
  `client_request_id` char(36) NOT NULL,
  `message_body` text NOT NULL,
  `read_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `pupils`
--

CREATE TABLE `pupils` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `school_id` bigint(20) UNSIGNED NOT NULL,
  `admission_number` varchar(60) NOT NULL,
  `first_name` varchar(80) NOT NULL,
  `middle_name` varchar(80) DEFAULT NULL,
  `last_name` varchar(80) NOT NULL,
  `date_of_birth` date DEFAULT NULL,
  `class_level` varchar(80) NOT NULL,
  `stream` varchar(80) DEFAULT NULL,
  `scholar_type` enum('day','boarding') NOT NULL DEFAULT 'day',
  `guardian_name` varchar(140) DEFAULT NULL,
  `guardian_phone` varchar(30) DEFAULT NULL,
  `status` enum('active','transferred','graduated') NOT NULL DEFAULT 'active',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `pupil_accounts`
--

CREATE TABLE `pupil_accounts` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `school_id` bigint(20) UNSIGNED NOT NULL,
  `pupil_id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `active` tinyint(1) NOT NULL DEFAULT 1,
  `linked_by` bigint(20) UNSIGNED NOT NULL,
  `revoked_by` bigint(20) UNSIGNED DEFAULT NULL,
  `revoked_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `pupil_attendance`
--

CREATE TABLE `pupil_attendance` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `pupil_id` bigint(20) UNSIGNED NOT NULL,
  `school_id` bigint(20) UNSIGNED NOT NULL,
  `attendance_date` date NOT NULL,
  `attendance_status` enum('present','absent','late','excused') NOT NULL,
  `recorded_by` bigint(20) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `pupil_class_history`
--

CREATE TABLE `pupil_class_history` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `pupil_id` bigint(20) UNSIGNED NOT NULL,
  `school_id` bigint(20) UNSIGNED NOT NULL,
  `class_level` varchar(80) NOT NULL,
  `academic_year` smallint(5) UNSIGNED NOT NULL,
  `changed_by` bigint(20) UNSIGNED NOT NULL,
  `changed_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `pupil_guardians`
--

CREATE TABLE `pupil_guardians` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `school_id` bigint(20) UNSIGNED NOT NULL,
  `pupil_id` bigint(20) UNSIGNED NOT NULL,
  `guardian_user_id` bigint(20) UNSIGNED NOT NULL,
  `relationship` varchar(50) NOT NULL DEFAULT 'Guardian',
  `is_primary` tinyint(1) NOT NULL DEFAULT 0,
  `receives_notifications` tinyint(1) NOT NULL DEFAULT 1,
  `linked_by` bigint(20) UNSIGNED NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `pupil_homework_submissions`
--

CREATE TABLE `pupil_homework_submissions` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `assignment_id` bigint(20) UNSIGNED NOT NULL,
  `school_id` bigint(20) UNSIGNED NOT NULL,
  `pupil_id` bigint(20) UNSIGNED NOT NULL,
  `response` text NOT NULL,
  `status` enum('submitted','reviewed') NOT NULL DEFAULT 'submitted',
  `submitted_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `feedback` text DEFAULT NULL,
  `reviewed_by` bigint(20) UNSIGNED DEFAULT NULL,
  `reviewed_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `pupil_report_cards`
--

CREATE TABLE `pupil_report_cards` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `school_id` bigint(20) UNSIGNED NOT NULL,
  `pupil_id` bigint(20) UNSIGNED NOT NULL,
  `academic_year` smallint(5) UNSIGNED NOT NULL,
  `term` varchar(40) NOT NULL,
  `teacher_comment` text DEFAULT NULL,
  `teacher_comment_by` bigint(20) UNSIGNED DEFAULT NULL,
  `teacher_comment_at` timestamp NULL DEFAULT NULL,
  `headteacher_comment` text DEFAULT NULL,
  `headteacher_comment_by` bigint(20) UNSIGNED DEFAULT NULL,
  `headteacher_comment_at` timestamp NULL DEFAULT NULL,
  `status` enum('draft','published') NOT NULL DEFAULT 'draft',
  `published_by` bigint(20) UNSIGNED DEFAULT NULL,
  `published_at` timestamp NULL DEFAULT NULL,
  `created_by` bigint(20) UNSIGNED NOT NULL,
  `updated_by` bigint(20) UNSIGNED NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `pupil_results`
--

CREATE TABLE `pupil_results` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `pupil_id` bigint(20) UNSIGNED NOT NULL,
  `school_id` bigint(20) UNSIGNED NOT NULL,
  `class_level` varchar(80) NOT NULL,
  `stream` varchar(80) DEFAULT NULL,
  `subject` varchar(100) NOT NULL,
  `exam_name` varchar(120) NOT NULL,
  `assessment` varchar(120) NOT NULL,
  `academic_year` smallint(5) UNSIGNED NOT NULL,
  `score` decimal(6,2) NOT NULL,
  `max_score` decimal(6,2) NOT NULL,
  `entered_by` bigint(20) UNSIGNED NOT NULL,
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `pupil_status_history`
--

CREATE TABLE `pupil_status_history` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `pupil_id` bigint(20) UNSIGNED NOT NULL,
  `school_id` bigint(20) UNSIGNED NOT NULL,
  `previous_status` enum('active','transferred','graduated') NOT NULL,
  `new_status` enum('active','transferred','graduated') NOT NULL,
  `effective_date` date NOT NULL,
  `note` varchar(500) DEFAULT NULL,
  `changed_by` bigint(20) UNSIGNED NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `question_bank`
--

CREATE TABLE `question_bank` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `school_id` bigint(20) UNSIGNED NOT NULL,
  `class_id` bigint(20) UNSIGNED NOT NULL,
  `subject_id` bigint(20) UNSIGNED NOT NULL,
  `scheme_topic_id` bigint(20) UNSIGNED DEFAULT NULL,
  `topic` varchar(180) NOT NULL,
  `subtopic` varchar(180) DEFAULT NULL,
  `question_type` enum('multiple_choice','short_answer','structured','essay') NOT NULL,
  `difficulty` enum('easy','moderate','challenging') NOT NULL DEFAULT 'moderate',
  `prompt` longtext NOT NULL,
  `options_json` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`options_json`)),
  `model_answer` longtext DEFAULT NULL,
  `marking_guidance` text DEFAULT NULL,
  `learning_objectives` text DEFAULT NULL,
  `marks` decimal(6,2) NOT NULL DEFAULT 1.00,
  `source` enum('manual','ai') NOT NULL DEFAULT 'manual',
  `status` enum('draft','submitted','approved','returned','published','archived') NOT NULL DEFAULT 'draft',
  `created_by` bigint(20) UNSIGNED NOT NULL,
  `reviewed_by` bigint(20) UNSIGNED DEFAULT NULL,
  `reviewed_at` timestamp NULL DEFAULT NULL,
  `review_feedback` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ;

-- --------------------------------------------------------

--
-- Table structure for table `result_correction_requests`
--

CREATE TABLE `result_correction_requests` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `school_id` bigint(20) UNSIGNED NOT NULL,
  `exam_id` bigint(20) UNSIGNED NOT NULL,
  `pupil_result_id` bigint(20) UNSIGNED NOT NULL,
  `original_score` decimal(6,2) NOT NULL,
  `requested_score` decimal(6,2) NOT NULL,
  `reason` varchar(2000) NOT NULL,
  `status` enum('pending','approved','rejected') NOT NULL DEFAULT 'pending',
  `requested_by` bigint(20) UNSIGNED NOT NULL,
  `reviewed_by` bigint(20) UNSIGNED DEFAULT NULL,
  `review_note` varchar(2000) DEFAULT NULL,
  `reviewed_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ;

-- --------------------------------------------------------

--
-- Table structure for table `result_delegations`
--

CREATE TABLE `result_delegations` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `school_id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `class_level` varchar(80) DEFAULT NULL,
  `academic_year` smallint(5) UNSIGNED NOT NULL,
  `granted_by` bigint(20) UNSIGNED NOT NULL,
  `active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `schemes_of_work`
--

CREATE TABLE `schemes_of_work` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `school_id` bigint(20) UNSIGNED NOT NULL,
  `class_id` bigint(20) UNSIGNED NOT NULL,
  `subject_id` bigint(20) UNSIGNED NOT NULL,
  `academic_year` smallint(5) UNSIGNED NOT NULL,
  `term` varchar(40) NOT NULL,
  `curriculum` varchar(120) DEFAULT NULL,
  `title` varchar(180) NOT NULL,
  `status` enum('draft','submitted','approved','returned','archived') NOT NULL DEFAULT 'draft',
  `version` smallint(5) UNSIGNED NOT NULL DEFAULT 1,
  `parent_scheme_id` bigint(20) UNSIGNED DEFAULT NULL,
  `created_by` bigint(20) UNSIGNED NOT NULL,
  `reviewed_by` bigint(20) UNSIGNED DEFAULT NULL,
  `reviewed_at` timestamp NULL DEFAULT NULL,
  `review_feedback` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `scheme_topics`
--

CREATE TABLE `scheme_topics` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `scheme_id` bigint(20) UNSIGNED NOT NULL,
  `sequence_no` smallint(5) UNSIGNED NOT NULL,
  `week_number` tinyint(3) UNSIGNED DEFAULT NULL,
  `topic` varchar(180) NOT NULL,
  `subtopic` varchar(180) DEFAULT NULL,
  `learning_objectives` text NOT NULL,
  `teaching_activities` text DEFAULT NULL,
  `resources` text DEFAULT NULL,
  `assessment_methods` text DEFAULT NULL,
  `periods_planned` tinyint(3) UNSIGNED NOT NULL DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `schools`
--

CREATE TABLE `schools` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(180) NOT NULL,
  `location` varchar(180) DEFAULT NULL,
  `phone` varchar(30) DEFAULT NULL,
  `status` enum('active','pending','inactive') NOT NULL DEFAULT 'active',
  `created_by` bigint(20) UNSIGNED DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `schools`
--

INSERT INTO `schools` (`id`, `name`, `location`, `phone`, `status`, `created_by`, `created_at`) VALUES
(1, 'Nyamata Academy', 'Mwanagati', '0712233445', 'active', 3, '2026-10-22 12:49:38');

-- --------------------------------------------------------

--
-- Table structure for table `school_announcements`
--

CREATE TABLE `school_announcements` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `school_id` bigint(20) UNSIGNED NOT NULL,
  `title` varchar(180) NOT NULL,
  `body` mediumtext NOT NULL,
  `audience` enum('all','parents','pupils','staff') NOT NULL DEFAULT 'all',
  `status` enum('draft','published','archived') NOT NULL DEFAULT 'draft',
  `expires_at` date DEFAULT NULL,
  `created_by` bigint(20) UNSIGNED NOT NULL,
  `published_by` bigint(20) UNSIGNED DEFAULT NULL,
  `published_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `school_classes`
--

CREATE TABLE `school_classes` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `school_id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(80) NOT NULL,
  `core_class_id` bigint(20) UNSIGNED DEFAULT NULL,
  `created_by` bigint(20) UNSIGNED DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `school_class_subjects`
--

CREATE TABLE `school_class_subjects` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `class_id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(100) NOT NULL,
  `core_subject_id` bigint(20) UNSIGNED DEFAULT NULL,
  `created_by` bigint(20) UNSIGNED DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `school_edit_permissions`
--

CREATE TABLE `school_edit_permissions` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `school_id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `granted_by` bigint(20) UNSIGNED NOT NULL,
  `active` tinyint(1) NOT NULL DEFAULT 1,
  `granted_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `revoked_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `school_edit_requests`
--

CREATE TABLE `school_edit_requests` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `school_id` bigint(20) UNSIGNED NOT NULL,
  `requested_by` bigint(20) UNSIGNED NOT NULL,
  `original_name` varchar(180) NOT NULL,
  `original_location` varchar(180) DEFAULT NULL,
  `original_phone` varchar(30) DEFAULT NULL,
  `proposed_name` varchar(180) NOT NULL,
  `proposed_location` varchar(180) DEFAULT NULL,
  `proposed_phone` varchar(30) DEFAULT NULL,
  `status` enum('pending','approved','denied','reverted') NOT NULL DEFAULT 'pending',
  `reviewed_by` bigint(20) UNSIGNED DEFAULT NULL,
  `reviewed_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `school_exams`
--

CREATE TABLE `school_exams` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `school_id` bigint(20) UNSIGNED NOT NULL,
  `class_id` bigint(20) UNSIGNED DEFAULT NULL,
  `subject_id` bigint(20) UNSIGNED DEFAULT NULL,
  `name` varchar(120) NOT NULL,
  `academic_year` smallint(5) UNSIGNED NOT NULL,
  `term` varchar(40) DEFAULT NULL,
  `exam_date` date DEFAULT NULL,
  `duration_minutes` smallint(5) UNSIGNED DEFAULT NULL,
  `instructions` text DEFAULT NULL,
  `total_marks` decimal(7,2) NOT NULL DEFAULT 0.00,
  `status` enum('draft','submitted','approved','returned','scheduled','results_open','results_published','archived') NOT NULL DEFAULT 'results_open',
  `created_by` bigint(20) UNSIGNED NOT NULL,
  `reviewed_by` bigint(20) UNSIGNED DEFAULT NULL,
  `reviewed_at` timestamp NULL DEFAULT NULL,
  `review_feedback` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `school_fee_ledger`
--

CREATE TABLE `school_fee_ledger` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `school_id` bigint(20) UNSIGNED NOT NULL,
  `pupil_id` bigint(20) UNSIGNED NOT NULL,
  `entry_type` enum('charge','payment','charge_reversal','payment_reversal','discount','discount_reversal') NOT NULL,
  `academic_year` smallint(5) UNSIGNED NOT NULL,
  `term` varchar(40) NOT NULL,
  `description` varchar(180) NOT NULL,
  `amount` decimal(12,2) NOT NULL,
  `payment_method` varchar(40) DEFAULT NULL,
  `reference` varchar(100) DEFAULT NULL,
  `reversal_of` bigint(20) UNSIGNED DEFAULT NULL,
  `reversal_reason` varchar(255) DEFAULT NULL,
  `recorded_by` bigint(20) UNSIGNED NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `school_grading_bands`
--

CREATE TABLE `school_grading_bands` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `scale_id` bigint(20) UNSIGNED NOT NULL,
  `label` varchar(40) NOT NULL,
  `minimum_percent` decimal(5,2) NOT NULL,
  `maximum_percent` decimal(5,2) NOT NULL,
  `comment` varchar(180) DEFAULT NULL,
  `sort_order` smallint(5) UNSIGNED NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `school_grading_scales`
--

CREATE TABLE `school_grading_scales` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `school_id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(120) NOT NULL,
  `academic_year` smallint(5) UNSIGNED NOT NULL,
  `class_id` bigint(20) UNSIGNED DEFAULT NULL,
  `status` enum('draft','published','archived') NOT NULL DEFAULT 'draft',
  `created_by` bigint(20) UNSIGNED NOT NULL,
  `published_by` bigint(20) UNSIGNED DEFAULT NULL,
  `published_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `school_memberships`
--

CREATE TABLE `school_memberships` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `school_id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `scope` enum('member','manager') NOT NULL DEFAULT 'member',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `school_memberships`
--

INSERT INTO `school_memberships` (`id`, `school_id`, `user_id`, `scope`, `created_at`) VALUES
(1, 1, 5, 'manager', '2026-10-22 12:49:38'),
(2, 1, 3, 'manager', '2026-10-22 12:49:38');

-- --------------------------------------------------------

--
-- Table structure for table `school_setup_permissions`
--

CREATE TABLE `school_setup_permissions` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `school_id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `granted_by` bigint(20) UNSIGNED NOT NULL,
  `active` tinyint(1) NOT NULL DEFAULT 1,
  `granted_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `revoked_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `school_sms_outbox`
--

CREATE TABLE `school_sms_outbox` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `school_id` bigint(20) UNSIGNED NOT NULL,
  `pupil_id` bigint(20) UNSIGNED DEFAULT NULL,
  `recipient_user_id` bigint(20) UNSIGNED DEFAULT NULL,
  `recipient_phone` varchar(30) NOT NULL,
  `event_type` enum('fee_payment','attendance_alert','exam_publication','school_announcement','fee_reminder','contract_expiry') NOT NULL,
  `source_type` varchar(60) NOT NULL,
  `source_id` bigint(20) UNSIGNED NOT NULL,
  `message_body` varchar(500) NOT NULL,
  `status` enum('queued','sending','accepted','delivered','failed','undelivered','cancelled') NOT NULL DEFAULT 'queued',
  `attempts` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `next_attempt_at` timestamp NULL DEFAULT NULL,
  `provider_message_id` varchar(190) DEFAULT NULL,
  `http_status` smallint(5) UNSIGNED DEFAULT NULL,
  `delivery_status` varchar(40) DEFAULT NULL,
  `delivery_checked_at` timestamp NULL DEFAULT NULL,
  `last_error` varchar(1000) DEFAULT NULL,
  `created_by` bigint(20) UNSIGNED DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `school_sms_templates`
--

CREATE TABLE `school_sms_templates` (
  `school_id` bigint(20) UNSIGNED NOT NULL,
  `event_type` enum('fee_payment','attendance_alert','exam_publication','school_announcement','fee_reminder','contract_expiry') NOT NULL,
  `message_body` varchar(500) NOT NULL,
  `updated_by` bigint(20) UNSIGNED NOT NULL,
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `school_streams`
--

CREATE TABLE `school_streams` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `class_id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(80) NOT NULL,
  `created_by` bigint(20) UNSIGNED DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `school_subjects`
--

CREATE TABLE `school_subjects` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `school_id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(100) NOT NULL,
  `created_by` bigint(20) UNSIGNED DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `school_subscription_discounts`
--

CREATE TABLE `school_subscription_discounts` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `school_id` bigint(20) UNSIGNED NOT NULL,
  `discount_percent` decimal(5,2) NOT NULL DEFAULT 0.00,
  `reason` varchar(255) DEFAULT NULL,
  `active` tinyint(1) NOT NULL DEFAULT 1,
  `updated_by` bigint(20) UNSIGNED NOT NULL,
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `school_subscription_discounts`
--

INSERT INTO `school_subscription_discounts` (`id`, `school_id`, `discount_percent`, `reason`, `active`, `updated_by`, `updated_at`) VALUES
(1, 1, 20.00, NULL, 1, 1, '2026-10-23 10:20:25');

-- --------------------------------------------------------

--
-- Table structure for table `sms_delivery_logs`
--

CREATE TABLE `sms_delivery_logs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `school_id` bigint(20) UNSIGNED DEFAULT NULL,
  `director_user_id` bigint(20) UNSIGNED DEFAULT NULL,
  `actor_id` bigint(20) UNSIGNED DEFAULT NULL,
  `recipient` varchar(20) NOT NULL,
  `endpoint` varchar(500) NOT NULL,
  `http_status` smallint(5) UNSIGNED DEFAULT NULL,
  `status` enum('accepted','failed') NOT NULL,
  `provider_message_id` varchar(190) DEFAULT NULL,
  `delivery_status` varchar(40) DEFAULT NULL,
  `status_checked_at` timestamp NULL DEFAULT NULL,
  `status_check_diagnostic` text DEFAULT NULL,
  `diagnostic` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `staff_leave_requests`
--

CREATE TABLE `staff_leave_requests` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `school_id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `leave_type` enum('annual','sick','maternity','paternity','compassionate','other') NOT NULL,
  `start_date` date NOT NULL,
  `end_date` date NOT NULL,
  `reason` varchar(2000) DEFAULT NULL,
  `status` enum('pending','approved','rejected','cancelled') NOT NULL DEFAULT 'pending',
  `review_note` varchar(1000) DEFAULT NULL,
  `reviewed_by` bigint(20) UNSIGNED DEFAULT NULL,
  `reviewed_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `subscriptions`
--

CREATE TABLE `subscriptions` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `school_id` bigint(20) UNSIGNED NOT NULL,
  `price_id` bigint(20) UNSIGNED NOT NULL,
  `starts_on` date NOT NULL,
  `ends_on` date NOT NULL,
  `academic_year` smallint(5) UNSIGNED NOT NULL,
  `pupil_count` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `unit_price` decimal(12,2) NOT NULL DEFAULT 0.00,
  `discount_percent` decimal(5,2) NOT NULL DEFAULT 0.00,
  `total_amount` decimal(14,2) NOT NULL DEFAULT 0.00,
  `status` enum('active','pending','expired','cancelled') NOT NULL DEFAULT 'pending',
  `created_by` bigint(20) UNSIGNED NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `subscription_prices`
--

CREATE TABLE `subscription_prices` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(100) NOT NULL,
  `amount` decimal(12,2) NOT NULL,
  `currency` char(3) NOT NULL DEFAULT 'KES',
  `billing_period` enum('monthly','termly','yearly') NOT NULL DEFAULT 'yearly',
  `active` tinyint(1) NOT NULL DEFAULT 1,
  `created_by` bigint(20) UNSIGNED DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `subscription_price_permissions`
--

CREATE TABLE `subscription_price_permissions` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `granted_by` bigint(20) UNSIGNED NOT NULL,
  `active` tinyint(1) NOT NULL DEFAULT 1,
  `granted_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `revoked_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `teacher_assignments`
--

CREATE TABLE `teacher_assignments` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `school_id` bigint(20) UNSIGNED NOT NULL,
  `class_level` varchar(80) NOT NULL,
  `subject` varchar(100) NOT NULL,
  `active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `teacher_reports`
--

CREATE TABLE `teacher_reports` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `school_id` bigint(20) UNSIGNED NOT NULL,
  `teacher_id` bigint(20) UNSIGNED NOT NULL,
  `report_type` enum('daily','weekly','monthly','termly') NOT NULL,
  `period_start` date NOT NULL,
  `period_end` date NOT NULL,
  `narrative` text DEFAULT NULL,
  `challenges` text DEFAULT NULL,
  `interventions` text DEFAULT NULL,
  `recommendations` text DEFAULT NULL,
  `activity_snapshot` mediumtext DEFAULT NULL,
  `status` enum('draft','submitted','approved','returned') NOT NULL DEFAULT 'draft',
  `reviewed_by` bigint(20) UNSIGNED DEFAULT NULL,
  `reviewed_at` timestamp NULL DEFAULT NULL,
  `review_feedback` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `teaching_records`
--

CREATE TABLE `teaching_records` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `school_id` bigint(20) UNSIGNED NOT NULL,
  `lesson_plan_id` bigint(20) UNSIGNED NOT NULL,
  `teacher_id` bigint(20) UNSIGNED NOT NULL,
  `taught_on` date NOT NULL,
  `periods_delivered` tinyint(3) UNSIGNED NOT NULL DEFAULT 1,
  `coverage_note` text DEFAULT NULL,
  `challenges` text DEFAULT NULL,
  `intervention` text DEFAULT NULL,
  `confirmed_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(140) NOT NULL,
  `phone` varchar(30) DEFAULT NULL,
  `email` varchar(190) DEFAULT NULL,
  `username` varchar(60) DEFAULT NULL,
  `password_hash` varchar(255) NOT NULL,
  `must_change_password` tinyint(1) NOT NULL DEFAULT 0,
  `role` enum('system_admin','sub_admin','admin','director','sub_director','headteacher','head_academic','department_head','assistant_academic','examination_officer','teacher','driver','hr','storekeeper','bursar','parent','pupil') NOT NULL,
  `status` enum('active','disabled') NOT NULL DEFAULT 'active',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `name`, `phone`, `email`, `username`, `password_hash`, `must_change_password`, `role`, `status`, `created_at`) VALUES
(1, 'Johnson Antipas Berege', NULL, 'admin@shulelite.local', 'berege', '$2y$10$U2RUWunoYLWl.MJc5LwmfeswscXqaUWh4o4/.6Hdv8SvSCTOKtvUu', 0, 'system_admin', 'active', '2026-10-21 06:23:37'),
(2, 'Hanifa Rajabu', NULL, 'rajab@gmail.com', 'nipher', '$2y$10$L56ey.UlOktfI5giZEZ5f.X9YNf656xbXioNx8FdXJi5DDChNev4u', 0, 'sub_admin', 'active', '2026-10-21 06:40:24'),
(3, 'Aylan Johnson Berege', NULL, NULL, 'admin', '$2y$10$3HPSWWFbu0f57T04kM3ezOkY8jRpXRjVcx7RZCMUDTsbuLvv69do6', 0, 'admin', 'active', '2026-10-21 06:41:35'),
(5, 'Sikubwabo Ngendabanka', '0788798558', NULL, 'ngenda', '$2y$10$WkrWvMstGDZd1jnDDiQAxOKPrq4zS.K97xnqls508LrZoDc0BJdlq', 0, 'director', 'active', '2026-10-21 09:03:15'),
(6, 'Renard Gurusi', NULL, NULL, 'gurusi', '$2y$10$gjx9tfLKstNmkQnnhtdQdu2P17gBn8trDK7xBiHQD7yEct.D6/fKK', 0, 'headteacher', 'active', '2026-10-21 11:41:24');

-- --------------------------------------------------------

--
-- Table structure for table `vehicles`
--

CREATE TABLE `vehicles` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `school_id` bigint(20) UNSIGNED NOT NULL,
  `registration` varchar(30) NOT NULL,
  `route_name` varchar(140) NOT NULL,
  `driver_user_id` bigint(20) UNSIGNED DEFAULT NULL,
  `active` tinyint(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `academic_classes`
--
ALTER TABLE `academic_classes`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `name` (`name`),
  ADD KEY `fk_academic_class_creator` (`created_by`);

--
-- Indexes for table `academic_class_subjects`
--
ALTER TABLE `academic_class_subjects`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_academic_class_subject` (`class_id`,`name`),
  ADD KEY `fk_academic_subject_creator` (`created_by`);

--
-- Indexes for table `ai_provider_settings`
--
ALTER TABLE `ai_provider_settings`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_ai_provider_settings_user` (`updated_by`);

--
-- Indexes for table `ai_question_import_batches`
--
ALTER TABLE `ai_question_import_batches`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_ai_question_import_key` (`school_id`,`created_by`,`import_key`),
  ADD KEY `idx_ai_question_import_actor` (`school_id`,`created_by`,`created_at`),
  ADD KEY `fk_ai_question_import_creator` (`created_by`);

--
-- Indexes for table `audit_logs`
--
ALTER TABLE `audit_logs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_audit_entity` (`entity_type`,`entity_id`),
  ADD KEY `fk_audit_actor` (`actor_id`);

--
-- Indexes for table `class_timetable_entries`
--
ALTER TABLE `class_timetable_entries`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_timetable_class_day` (`school_id`,`class_id`,`day_of_week`,`status`,`starts_at`),
  ADD KEY `idx_timetable_teacher_day` (`school_id`,`teacher_id`,`day_of_week`,`status`,`starts_at`),
  ADD KEY `fk_timetable_class` (`class_id`,`school_id`),
  ADD KEY `fk_timetable_stream` (`stream_id`),
  ADD KEY `fk_timetable_subject` (`subject_id`),
  ADD KEY `fk_timetable_teacher` (`teacher_id`),
  ADD KEY `fk_timetable_creator` (`created_by`);

--
-- Indexes for table `departments`
--
ALTER TABLE `departments`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_department_name` (`school_id`,`name`,`department_type`),
  ADD KEY `fk_department_head` (`head_user_id`);

--
-- Indexes for table `department_reports`
--
ALTER TABLE `department_reports`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_department_reports_scope` (`school_id`,`department_id`,`status`,`period_start`),
  ADD KEY `idx_department_reports_author` (`school_id`,`author_id`,`status`),
  ADD KEY `fk_department_report_department` (`department_id`),
  ADD KEY `fk_department_report_author` (`author_id`),
  ADD KEY `fk_department_report_reviewer` (`reviewed_by`);

--
-- Indexes for table `department_subjects`
--
ALTER TABLE `department_subjects`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_department_subject_school` (`school_id`,`class_subject_id`),
  ADD KEY `idx_department_subject_scope` (`school_id`,`department_id`),
  ADD KEY `fk_department_subject_department` (`department_id`),
  ADD KEY `fk_department_subject_subject` (`class_subject_id`),
  ADD KEY `fk_department_subject_creator` (`created_by`);

--
-- Indexes for table `employee_attendance`
--
ALTER TABLE `employee_attendance`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_employee_attendance_day` (`school_id`,`user_id`,`attendance_date`),
  ADD KEY `idx_employee_attendance_date` (`school_id`,`attendance_date`),
  ADD KEY `fk_employee_attendance_user` (`user_id`),
  ADD KEY `fk_employee_attendance_checkin` (`check_in_by`),
  ADD KEY `fk_employee_attendance_checkout` (`check_out_by`);

--
-- Indexes for table `employee_contracts`
--
ALTER TABLE `employee_contracts`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_contract_renewal_source` (`renewed_from_id`),
  ADD KEY `idx_contract_end` (`school_id`,`end_date`,`status`),
  ADD KEY `fk_contract_user` (`user_id`),
  ADD KEY `fk_contract_creator` (`created_by`);

--
-- Indexes for table `employee_documents`
--
ALTER TABLE `employee_documents`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_employee_document_file` (`stored_name`),
  ADD KEY `idx_employee_document_user` (`school_id`,`user_id`,`created_at`),
  ADD KEY `fk_employee_document_user` (`user_id`),
  ADD KEY `fk_employee_document_uploader` (`uploaded_by`);

--
-- Indexes for table `employee_profiles`
--
ALTER TABLE `employee_profiles`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_employee_profile_user` (`school_id`,`user_id`),
  ADD UNIQUE KEY `uq_employee_number_school` (`school_id`,`employee_number`),
  ADD KEY `idx_employee_profile_department` (`school_id`,`department`),
  ADD KEY `fk_employee_profile_user` (`user_id`),
  ADD KEY `fk_employee_profile_creator` (`created_by`),
  ADD KEY `fk_employee_profile_updater` (`updated_by`);

--
-- Indexes for table `exam_paper_questions`
--
ALTER TABLE `exam_paper_questions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_exam_question` (`exam_id`,`question_id`),
  ADD UNIQUE KEY `uq_exam_question_order` (`exam_id`,`section_name`,`sequence_no`),
  ADD KEY `fk_exam_question_bank` (`question_id`);

--
-- Indexes for table `fee_assessments`
--
ALTER TABLE `fee_assessments`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_fee_assessment_pupil_item` (`item_id`,`pupil_id`),
  ADD UNIQUE KEY `uq_fee_assessment_ledger` (`ledger_entry_id`),
  ADD KEY `idx_fee_assessment_scope` (`school_id`,`structure_id`,`pupil_id`),
  ADD KEY `fk_fee_assessment_structure` (`structure_id`,`school_id`),
  ADD KEY `fk_fee_assessment_item` (`item_id`,`structure_id`,`school_id`),
  ADD KEY `fk_fee_assessment_pupil` (`pupil_id`,`school_id`),
  ADD KEY `fk_fee_assessment_ledger` (`ledger_entry_id`,`school_id`,`pupil_id`);

--
-- Indexes for table `fee_reconciliation_batches`
--
ALTER TABLE `fee_reconciliation_batches`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_fee_reconciliation_scope` (`id`,`school_id`),
  ADD KEY `idx_fee_reconciliation_school` (`school_id`,`status`,`statement_date`),
  ADD KEY `fk_fee_reconciliation_creator` (`created_by`),
  ADD KEY `fk_fee_reconciliation_completer` (`completed_by`);

--
-- Indexes for table `fee_reconciliation_lines`
--
ALTER TABLE `fee_reconciliation_lines`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_fee_reconciliation_line` (`batch_id`,`line_number`),
  ADD UNIQUE KEY `uq_fee_reconciliation_ledger` (`school_id`,`matched_ledger_id`),
  ADD KEY `idx_fee_reconciliation_match` (`school_id`,`reference`,`amount`),
  ADD KEY `fk_fee_reconciliation_batch` (`batch_id`,`school_id`);

--
-- Indexes for table `fee_structures`
--
ALTER TABLE `fee_structures`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_fee_structure_title` (`school_id`,`class_id`,`academic_year`,`term`,`title`),
  ADD UNIQUE KEY `uq_fee_structure_school` (`id`,`school_id`),
  ADD KEY `idx_fee_structure_class` (`school_id`,`class_id`,`academic_year`,`term`,`status`),
  ADD KEY `fk_fee_structure_class` (`class_id`,`school_id`),
  ADD KEY `fk_fee_structure_creator` (`created_by`);

--
-- Indexes for table `fee_structure_items`
--
ALTER TABLE `fee_structure_items`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_fee_item_sequence` (`structure_id`,`sequence_no`),
  ADD UNIQUE KEY `uq_fee_item_scope` (`id`,`structure_id`,`school_id`),
  ADD KEY `fk_fee_item_structure` (`structure_id`,`school_id`);

--
-- Indexes for table `holiday_packages`
--
ALTER TABLE `holiday_packages`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_holiday_package_scope` (`id`,`school_id`),
  ADD KEY `idx_holiday_package_class` (`school_id`,`class_id`,`status`,`available_from`,`available_until`),
  ADD KEY `fk_holiday_package_class` (`class_id`),
  ADD KEY `fk_holiday_package_subject` (`subject_id`),
  ADD KEY `fk_holiday_package_creator` (`created_by`),
  ADD KEY `fk_holiday_package_reviewer` (`reviewed_by`);

--
-- Indexes for table `holiday_package_items`
--
ALTER TABLE `holiday_package_items`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_holiday_item_order` (`package_id`,`sequence_no`),
  ADD KEY `idx_holiday_item_package` (`school_id`,`package_id`),
  ADD KEY `fk_holiday_item_package` (`package_id`,`school_id`),
  ADD KEY `fk_holiday_item_note` (`learning_note_id`),
  ADD KEY `fk_holiday_item_question` (`question_id`);

--
-- Indexes for table `holiday_package_progress`
--
ALTER TABLE `holiday_package_progress`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_holiday_package_progress` (`package_id`,`pupil_id`),
  ADD KEY `idx_holiday_progress_pupil` (`school_id`,`pupil_id`,`status`),
  ADD KEY `fk_holiday_progress_package` (`package_id`,`school_id`),
  ADD KEY `fk_holiday_progress_pupil` (`pupil_id`,`school_id`),
  ADD KEY `fk_holiday_progress_feedback` (`feedback_by`);

--
-- Indexes for table `homework_assignments`
--
ALTER TABLE `homework_assignments`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_homework_assignment_scope` (`id`,`school_id`),
  ADD KEY `idx_homework_class_status_due` (`school_id`,`class_level`,`status`,`due_date`),
  ADD KEY `fk_homework_teacher` (`teacher_id`),
  ADD KEY `fk_homework_note` (`learning_note_id`);

--
-- Indexes for table `inventory_categories`
--
ALTER TABLE `inventory_categories`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_inventory_category_name` (`school_id`,`name`),
  ADD UNIQUE KEY `uq_inventory_category_scope` (`id`,`school_id`),
  ADD KEY `idx_inventory_category_status` (`school_id`,`status`,`name`),
  ADD KEY `fk_inventory_category_creator` (`created_by`),
  ADD KEY `fk_inventory_category_updater` (`updated_by`);

--
-- Indexes for table `inventory_items`
--
ALTER TABLE `inventory_items`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_inventory` (`school_id`,`item_name`),
  ADD UNIQUE KEY `uq_inventory_item_scope` (`id`,`school_id`),
  ADD KEY `fk_inventory_user` (`updated_by`),
  ADD KEY `idx_inventory_category` (`school_id`,`category_id`),
  ADD KEY `fk_inventory_category` (`category_id`,`school_id`);

--
-- Indexes for table `inventory_movements`
--
ALTER TABLE `inventory_movements`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_inventory_request_issue` (`request_id`),
  ADD KEY `idx_inventory_movement_item` (`item_id`,`created_at`),
  ADD KEY `fk_inventory_movement_user` (`recorded_by`),
  ADD KEY `idx_inventory_movement_supplier` (`school_id`,`supplier_id`,`created_at`),
  ADD KEY `fk_inventory_movement_supplier` (`supplier_id`);

--
-- Indexes for table `inventory_requests`
--
ALTER TABLE `inventory_requests`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_inventory_request_queue` (`school_id`,`status`,`created_at`),
  ADD KEY `fk_inventory_request_item` (`item_id`),
  ADD KEY `fk_inventory_requester` (`requested_by`),
  ADD KEY `fk_inventory_reviewer` (`reviewed_by`);

--
-- Indexes for table `inventory_stocktakes`
--
ALTER TABLE `inventory_stocktakes`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_inventory_stocktake_reference` (`school_id`,`reference`),
  ADD UNIQUE KEY `uq_inventory_stocktake_scope` (`id`,`school_id`),
  ADD KEY `idx_inventory_stocktake_queue` (`school_id`,`status`,`created_at`),
  ADD KEY `fk_inventory_stocktake_creator` (`created_by`),
  ADD KEY `fk_inventory_stocktake_reviewer` (`reviewed_by`);

--
-- Indexes for table `inventory_stocktake_lines`
--
ALTER TABLE `inventory_stocktake_lines`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_inventory_stocktake_item` (`stocktake_id`,`item_id`),
  ADD KEY `idx_inventory_stocktake_line_scope` (`school_id`,`stocktake_id`),
  ADD KEY `fk_inventory_stocktake_line_session` (`stocktake_id`,`school_id`),
  ADD KEY `fk_inventory_stocktake_line_item` (`item_id`,`school_id`);

--
-- Indexes for table `inventory_suppliers`
--
ALTER TABLE `inventory_suppliers`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_inventory_supplier_name` (`school_id`,`name`),
  ADD KEY `idx_inventory_supplier_status` (`school_id`,`status`,`name`),
  ADD KEY `fk_inventory_supplier_creator` (`created_by`),
  ADD KEY `fk_inventory_supplier_updater` (`updated_by`);

--
-- Indexes for table `learning_notes`
--
ALTER TABLE `learning_notes`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_notes_class_subject` (`class_level`,`subject`,`status`),
  ADD KEY `fk_note_author` (`author_id`),
  ADD KEY `fk_note_school` (`school_id`);

--
-- Indexes for table `learning_note_terms`
--
ALTER TABLE `learning_note_terms`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_learning_note_term` (`term_type`,`name`),
  ADD KEY `fk_learning_note_term_user` (`created_by`);

--
-- Indexes for table `lesson_plans`
--
ALTER TABLE `lesson_plans`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_lesson_id_school` (`id`,`school_id`),
  ADD KEY `idx_lesson_teacher_status` (`school_id`,`teacher_id`,`status`,`scheduled_for`),
  ADD KEY `fk_lesson_scheme` (`scheme_id`),
  ADD KEY `fk_lesson_topic` (`topic_id`),
  ADD KEY `fk_lesson_teacher` (`teacher_id`),
  ADD KEY `fk_lesson_reviewer` (`reviewed_by`),
  ADD KEY `idx_lesson_stream_date` (`school_id`,`stream_id`,`scheduled_for`),
  ADD KEY `fk_lesson_stream` (`stream_id`);

--
-- Indexes for table `lesson_plan_resources`
--
ALTER TABLE `lesson_plan_resources`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_lesson_library_resource` (`lesson_plan_id`,`learning_note_id`),
  ADD KEY `idx_lesson_resource_school` (`school_id`,`lesson_plan_id`),
  ADD KEY `fk_lesson_resource_lesson` (`lesson_plan_id`,`school_id`),
  ADD KEY `fk_lesson_resource_note` (`learning_note_id`),
  ADD KEY `fk_lesson_resource_creator` (`created_by`);

--
-- Indexes for table `parent_conversations`
--
ALTER TABLE `parent_conversations`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_parent_conversation_parties` (`school_id`,`pupil_id`,`guardian_user_id`,`staff_user_id`),
  ADD UNIQUE KEY `uq_parent_conversation_scope` (`id`,`school_id`),
  ADD KEY `idx_parent_conversation_guardian` (`guardian_user_id`,`school_id`,`updated_at`),
  ADD KEY `idx_parent_conversation_staff` (`staff_user_id`,`school_id`,`updated_at`),
  ADD KEY `fk_parent_conversation_pupil` (`pupil_id`,`school_id`);

--
-- Indexes for table `parent_messages`
--
ALTER TABLE `parent_messages`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_parent_message_request` (`school_id`,`sender_user_id`,`client_request_id`),
  ADD KEY `idx_parent_message_thread` (`conversation_id`,`created_at`,`id`),
  ADD KEY `idx_parent_message_unread` (`school_id`,`sender_user_id`,`read_at`,`created_at`),
  ADD KEY `fk_parent_message_conversation` (`conversation_id`,`school_id`),
  ADD KEY `fk_parent_message_sender` (`sender_user_id`);

--
-- Indexes for table `pupils`
--
ALTER TABLE `pupils`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_pupil_admission` (`school_id`,`admission_number`),
  ADD UNIQUE KEY `uq_pupil_school_id` (`id`,`school_id`),
  ADD KEY `idx_pupil_search` (`school_id`,`last_name`,`first_name`);

--
-- Indexes for table `pupil_accounts`
--
ALTER TABLE `pupil_accounts`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_pupil_account_child` (`pupil_id`),
  ADD UNIQUE KEY `uq_pupil_account_user` (`user_id`),
  ADD KEY `idx_pupil_account_scope` (`school_id`,`active`),
  ADD KEY `fk_pupil_account_child` (`pupil_id`,`school_id`),
  ADD KEY `fk_pupil_account_linker` (`linked_by`),
  ADD KEY `fk_pupil_account_revoker` (`revoked_by`);

--
-- Indexes for table `pupil_attendance`
--
ALTER TABLE `pupil_attendance`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_pupil_attendance` (`pupil_id`,`attendance_date`),
  ADD KEY `fk_attendance_school` (`school_id`),
  ADD KEY `fk_attendance_user` (`recorded_by`);

--
-- Indexes for table `pupil_class_history`
--
ALTER TABLE `pupil_class_history`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_class_history_pupil` (`pupil_id`),
  ADD KEY `fk_class_history_school` (`school_id`),
  ADD KEY `fk_class_history_user` (`changed_by`);

--
-- Indexes for table `pupil_guardians`
--
ALTER TABLE `pupil_guardians`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_pupil_guardian` (`school_id`,`pupil_id`,`guardian_user_id`),
  ADD KEY `idx_guardian_children` (`guardian_user_id`,`school_id`),
  ADD KEY `fk_pupil_guardian_child` (`pupil_id`,`school_id`),
  ADD KEY `fk_pupil_guardian_linker` (`linked_by`);

--
-- Indexes for table `pupil_homework_submissions`
--
ALTER TABLE `pupil_homework_submissions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_homework_pupil_submission` (`assignment_id`,`pupil_id`),
  ADD KEY `idx_homework_submission_scope` (`school_id`,`assignment_id`,`status`),
  ADD KEY `fk_homework_submission_assignment` (`assignment_id`,`school_id`),
  ADD KEY `fk_homework_submission_pupil` (`pupil_id`,`school_id`),
  ADD KEY `fk_homework_submission_reviewer` (`reviewed_by`);

--
-- Indexes for table `pupil_report_cards`
--
ALTER TABLE `pupil_report_cards`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_report_card_period` (`school_id`,`pupil_id`,`academic_year`,`term`),
  ADD KEY `idx_report_card_school_status` (`school_id`,`status`,`academic_year`,`term`),
  ADD KEY `fk_report_card_pupil` (`pupil_id`,`school_id`),
  ADD KEY `fk_report_card_teacher` (`teacher_comment_by`),
  ADD KEY `fk_report_card_headteacher` (`headteacher_comment_by`),
  ADD KEY `fk_report_card_publisher` (`published_by`),
  ADD KEY `fk_report_card_creator` (`created_by`),
  ADD KEY `fk_report_card_updater` (`updated_by`);

--
-- Indexes for table `pupil_results`
--
ALTER TABLE `pupil_results`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_result_class` (`school_id`,`class_level`,`stream`,`subject`,`academic_year`),
  ADD KEY `fk_result_pupil` (`pupil_id`),
  ADD KEY `fk_result_user` (`entered_by`);

--
-- Indexes for table `pupil_status_history`
--
ALTER TABLE `pupil_status_history`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_pupil_status_history` (`school_id`,`pupil_id`,`effective_date`),
  ADD KEY `fk_pupil_status_history_pupil` (`pupil_id`,`school_id`),
  ADD KEY `fk_pupil_status_history_actor` (`changed_by`);

--
-- Indexes for table `question_bank`
--
ALTER TABLE `question_bank`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_question_bank_scope` (`school_id`,`class_id`,`subject_id`,`status`,`topic`),
  ADD KEY `idx_question_bank_creator` (`school_id`,`created_by`,`status`,`updated_at`),
  ADD KEY `fk_question_class` (`class_id`),
  ADD KEY `fk_question_subject` (`subject_id`),
  ADD KEY `fk_question_scheme_topic` (`scheme_topic_id`),
  ADD KEY `fk_question_creator` (`created_by`),
  ADD KEY `fk_question_reviewer` (`reviewed_by`);

--
-- Indexes for table `result_correction_requests`
--
ALTER TABLE `result_correction_requests`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_result_correction_exam` (`school_id`,`exam_id`,`status`,`created_at`),
  ADD KEY `idx_result_correction_result` (`school_id`,`pupil_result_id`,`status`),
  ADD KEY `fk_result_correction_exam` (`exam_id`),
  ADD KEY `fk_result_correction_result` (`pupil_result_id`),
  ADD KEY `fk_result_correction_requester` (`requested_by`),
  ADD KEY `fk_result_correction_reviewer` (`reviewed_by`);

--
-- Indexes for table `result_delegations`
--
ALTER TABLE `result_delegations`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_delegation_school` (`school_id`),
  ADD KEY `fk_delegation_user` (`user_id`),
  ADD KEY `fk_delegation_grantor` (`granted_by`);

--
-- Indexes for table `schemes_of_work`
--
ALTER TABLE `schemes_of_work`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_scheme_scope` (`school_id`,`class_id`,`subject_id`,`academic_year`,`term`,`status`),
  ADD KEY `fk_scheme_class` (`class_id`),
  ADD KEY `fk_scheme_subject` (`subject_id`),
  ADD KEY `fk_scheme_parent` (`parent_scheme_id`),
  ADD KEY `fk_scheme_creator` (`created_by`),
  ADD KEY `fk_scheme_reviewer` (`reviewed_by`);

--
-- Indexes for table `scheme_topics`
--
ALTER TABLE `scheme_topics`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_scheme_topic_order` (`scheme_id`,`sequence_no`);

--
-- Indexes for table `schools`
--
ALTER TABLE `schools`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_school_creator` (`created_by`);

--
-- Indexes for table `school_announcements`
--
ALTER TABLE `school_announcements`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_announcement_audience` (`school_id`,`status`,`audience`,`published_at`,`expires_at`),
  ADD KEY `fk_announcement_creator` (`created_by`),
  ADD KEY `fk_announcement_publisher` (`published_by`);

--
-- Indexes for table `school_classes`
--
ALTER TABLE `school_classes`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_school_class` (`school_id`,`name`),
  ADD UNIQUE KEY `uq_school_class_id_scope` (`id`,`school_id`),
  ADD UNIQUE KEY `uq_school_core_class` (`school_id`,`core_class_id`),
  ADD KEY `fk_class_creator` (`created_by`),
  ADD KEY `fk_school_class_core` (`core_class_id`);

--
-- Indexes for table `school_class_subjects`
--
ALTER TABLE `school_class_subjects`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_class_subject` (`class_id`,`name`),
  ADD UNIQUE KEY `uq_school_core_subject` (`class_id`,`core_subject_id`),
  ADD KEY `fk_class_subject_creator` (`created_by`),
  ADD KEY `fk_school_class_core_subject` (`core_subject_id`);

--
-- Indexes for table `school_edit_permissions`
--
ALTER TABLE `school_edit_permissions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_school_edit_permission` (`school_id`,`user_id`),
  ADD KEY `fk_school_edit_permission_user` (`user_id`),
  ADD KEY `fk_school_edit_permission_grantor` (`granted_by`);

--
-- Indexes for table `school_edit_requests`
--
ALTER TABLE `school_edit_requests`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_school_edit_request_user` (`requested_by`),
  ADD KEY `fk_school_edit_request_reviewer` (`reviewed_by`),
  ADD KEY `idx_school_edit_request_review` (`school_id`,`status`,`created_at`);

--
-- Indexes for table `school_exams`
--
ALTER TABLE `school_exams`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_school_exam_context` (`school_id`,`name`,`academic_year`,`class_id`,`subject_id`),
  ADD KEY `fk_exam_class` (`class_id`),
  ADD KEY `fk_exam_creator` (`created_by`),
  ADD KEY `idx_school_exam_status` (`school_id`,`status`,`exam_date`),
  ADD KEY `fk_exam_subject` (`subject_id`),
  ADD KEY `fk_exam_reviewer` (`reviewed_by`);

--
-- Indexes for table `school_fee_ledger`
--
ALTER TABLE `school_fee_ledger`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_fee_ledger_id_scope` (`id`,`school_id`,`pupil_id`),
  ADD UNIQUE KEY `uq_fee_reversal` (`reversal_of`),
  ADD KEY `idx_fee_ledger_pupil` (`school_id`,`pupil_id`,`academic_year`,`term`,`created_at`),
  ADD KEY `fk_fee_ledger_pupil` (`pupil_id`),
  ADD KEY `fk_fee_ledger_user` (`recorded_by`);

--
-- Indexes for table `school_grading_bands`
--
ALTER TABLE `school_grading_bands`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_grading_band_label` (`scale_id`,`label`),
  ADD KEY `idx_grading_band_order` (`scale_id`,`sort_order`,`minimum_percent`);

--
-- Indexes for table `school_grading_scales`
--
ALTER TABLE `school_grading_scales`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_grading_scale_scope` (`school_id`,`academic_year`,`class_id`,`name`),
  ADD KEY `idx_grading_scale_lookup` (`school_id`,`academic_year`,`class_id`,`status`),
  ADD KEY `fk_grading_scale_class` (`class_id`,`school_id`),
  ADD KEY `fk_grading_scale_creator` (`created_by`),
  ADD KEY `fk_grading_scale_publisher` (`published_by`);

--
-- Indexes for table `school_memberships`
--
ALTER TABLE `school_memberships`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_school_member` (`school_id`,`user_id`),
  ADD KEY `fk_member_user` (`user_id`);

--
-- Indexes for table `school_setup_permissions`
--
ALTER TABLE `school_setup_permissions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_school_setup_permission` (`school_id`,`user_id`),
  ADD KEY `fk_school_setup_permission_user` (`user_id`),
  ADD KEY `fk_school_setup_permission_grantor` (`granted_by`);

--
-- Indexes for table `school_sms_outbox`
--
ALTER TABLE `school_sms_outbox`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_school_sms_event_recipient` (`school_id`,`event_type`,`source_type`,`source_id`,`recipient_user_id`),
  ADD KEY `idx_school_sms_outbox_work` (`status`,`next_attempt_at`,`id`),
  ADD KEY `idx_school_sms_delivery_check` (`status`,`delivery_checked_at`,`id`),
  ADD KEY `idx_school_sms_school_created` (`school_id`,`created_at`),
  ADD KEY `fk_school_sms_outbox_pupil` (`pupil_id`),
  ADD KEY `fk_school_sms_outbox_recipient` (`recipient_user_id`),
  ADD KEY `fk_school_sms_outbox_creator` (`created_by`);

--
-- Indexes for table `school_sms_templates`
--
ALTER TABLE `school_sms_templates`
  ADD PRIMARY KEY (`school_id`,`event_type`),
  ADD KEY `fk_school_sms_template_updater` (`updated_by`);

--
-- Indexes for table `school_streams`
--
ALTER TABLE `school_streams`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_class_stream` (`class_id`,`name`),
  ADD KEY `fk_stream_creator` (`created_by`);

--
-- Indexes for table `school_subjects`
--
ALTER TABLE `school_subjects`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_school_subject` (`school_id`,`name`),
  ADD KEY `fk_subject_creator` (`created_by`);

--
-- Indexes for table `school_subscription_discounts`
--
ALTER TABLE `school_subscription_discounts`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_school_subscription_discount` (`school_id`),
  ADD KEY `fk_school_subscription_discount_user` (`updated_by`);

--
-- Indexes for table `sms_delivery_logs`
--
ALTER TABLE `sms_delivery_logs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_sms_delivery_status_created` (`status`,`created_at`),
  ADD KEY `idx_sms_delivery_actor_created` (`actor_id`,`created_at`),
  ADD KEY `fk_sms_delivery_school` (`school_id`),
  ADD KEY `fk_sms_delivery_director` (`director_user_id`);

--
-- Indexes for table `staff_leave_requests`
--
ALTER TABLE `staff_leave_requests`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_leave_school_status` (`school_id`,`status`,`start_date`),
  ADD KEY `idx_leave_user_dates` (`user_id`,`start_date`,`end_date`),
  ADD KEY `fk_leave_reviewer` (`reviewed_by`);

--
-- Indexes for table `subscriptions`
--
ALTER TABLE `subscriptions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_subscription_school` (`school_id`),
  ADD KEY `fk_subscription_price` (`price_id`),
  ADD KEY `fk_subscription_creator` (`created_by`);

--
-- Indexes for table `subscription_prices`
--
ALTER TABLE `subscription_prices`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_price_creator` (`created_by`);

--
-- Indexes for table `subscription_price_permissions`
--
ALTER TABLE `subscription_price_permissions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_subscription_price_permission_user` (`user_id`),
  ADD KEY `fk_subscription_price_permission_grantor` (`granted_by`);

--
-- Indexes for table `teacher_assignments`
--
ALTER TABLE `teacher_assignments`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_teacher_assignment` (`user_id`,`school_id`,`class_level`,`subject`),
  ADD KEY `fk_assignment_school` (`school_id`);

--
-- Indexes for table `teacher_reports`
--
ALTER TABLE `teacher_reports`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_teacher_report_period` (`school_id`,`teacher_id`,`report_type`,`period_start`,`period_end`),
  ADD KEY `idx_teacher_report_period` (`school_id`,`teacher_id`,`period_start`,`period_end`,`status`),
  ADD KEY `fk_teacher_report_teacher` (`teacher_id`),
  ADD KEY `fk_teacher_report_reviewer` (`reviewed_by`);

--
-- Indexes for table `teaching_records`
--
ALTER TABLE `teaching_records`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_teaching_record_lesson` (`lesson_plan_id`),
  ADD KEY `idx_teaching_record_coverage` (`school_id`,`teacher_id`,`taught_on`),
  ADD KEY `fk_teaching_teacher` (`teacher_id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`),
  ADD UNIQUE KEY `username` (`username`);

--
-- Indexes for table `vehicles`
--
ALTER TABLE `vehicles`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_vehicle` (`school_id`,`registration`),
  ADD KEY `fk_vehicle_driver` (`driver_user_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `academic_classes`
--
ALTER TABLE `academic_classes`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `academic_class_subjects`
--
ALTER TABLE `academic_class_subjects`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `ai_question_import_batches`
--
ALTER TABLE `ai_question_import_batches`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `audit_logs`
--
ALTER TABLE `audit_logs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `class_timetable_entries`
--
ALTER TABLE `class_timetable_entries`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `departments`
--
ALTER TABLE `departments`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `department_reports`
--
ALTER TABLE `department_reports`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `department_subjects`
--
ALTER TABLE `department_subjects`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `employee_attendance`
--
ALTER TABLE `employee_attendance`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `employee_contracts`
--
ALTER TABLE `employee_contracts`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `employee_documents`
--
ALTER TABLE `employee_documents`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `employee_profiles`
--
ALTER TABLE `employee_profiles`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `exam_paper_questions`
--
ALTER TABLE `exam_paper_questions`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `fee_assessments`
--
ALTER TABLE `fee_assessments`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `fee_reconciliation_batches`
--
ALTER TABLE `fee_reconciliation_batches`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `fee_reconciliation_lines`
--
ALTER TABLE `fee_reconciliation_lines`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `fee_structures`
--
ALTER TABLE `fee_structures`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `fee_structure_items`
--
ALTER TABLE `fee_structure_items`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `holiday_packages`
--
ALTER TABLE `holiday_packages`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `holiday_package_items`
--
ALTER TABLE `holiday_package_items`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `holiday_package_progress`
--
ALTER TABLE `holiday_package_progress`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `homework_assignments`
--
ALTER TABLE `homework_assignments`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `inventory_categories`
--
ALTER TABLE `inventory_categories`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `inventory_items`
--
ALTER TABLE `inventory_items`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `inventory_movements`
--
ALTER TABLE `inventory_movements`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `inventory_requests`
--
ALTER TABLE `inventory_requests`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `inventory_stocktakes`
--
ALTER TABLE `inventory_stocktakes`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `inventory_stocktake_lines`
--
ALTER TABLE `inventory_stocktake_lines`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `inventory_suppliers`
--
ALTER TABLE `inventory_suppliers`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `learning_notes`
--
ALTER TABLE `learning_notes`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `learning_note_terms`
--
ALTER TABLE `learning_note_terms`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `lesson_plans`
--
ALTER TABLE `lesson_plans`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `lesson_plan_resources`
--
ALTER TABLE `lesson_plan_resources`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `parent_conversations`
--
ALTER TABLE `parent_conversations`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `parent_messages`
--
ALTER TABLE `parent_messages`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `pupils`
--
ALTER TABLE `pupils`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `pupil_accounts`
--
ALTER TABLE `pupil_accounts`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `pupil_attendance`
--
ALTER TABLE `pupil_attendance`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `pupil_class_history`
--
ALTER TABLE `pupil_class_history`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `pupil_guardians`
--
ALTER TABLE `pupil_guardians`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `pupil_homework_submissions`
--
ALTER TABLE `pupil_homework_submissions`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `pupil_report_cards`
--
ALTER TABLE `pupil_report_cards`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `pupil_results`
--
ALTER TABLE `pupil_results`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `pupil_status_history`
--
ALTER TABLE `pupil_status_history`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `question_bank`
--
ALTER TABLE `question_bank`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `result_correction_requests`
--
ALTER TABLE `result_correction_requests`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `result_delegations`
--
ALTER TABLE `result_delegations`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `schemes_of_work`
--
ALTER TABLE `schemes_of_work`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `scheme_topics`
--
ALTER TABLE `scheme_topics`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `schools`
--
ALTER TABLE `schools`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `school_announcements`
--
ALTER TABLE `school_announcements`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `school_classes`
--
ALTER TABLE `school_classes`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `school_class_subjects`
--
ALTER TABLE `school_class_subjects`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `school_edit_permissions`
--
ALTER TABLE `school_edit_permissions`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `school_edit_requests`
--
ALTER TABLE `school_edit_requests`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `school_exams`
--
ALTER TABLE `school_exams`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `school_fee_ledger`
--
ALTER TABLE `school_fee_ledger`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `school_grading_bands`
--
ALTER TABLE `school_grading_bands`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `school_grading_scales`
--
ALTER TABLE `school_grading_scales`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `school_memberships`
--
ALTER TABLE `school_memberships`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `school_setup_permissions`
--
ALTER TABLE `school_setup_permissions`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `school_sms_outbox`
--
ALTER TABLE `school_sms_outbox`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `school_streams`
--
ALTER TABLE `school_streams`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `school_subjects`
--
ALTER TABLE `school_subjects`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `school_subscription_discounts`
--
ALTER TABLE `school_subscription_discounts`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `sms_delivery_logs`
--
ALTER TABLE `sms_delivery_logs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `staff_leave_requests`
--
ALTER TABLE `staff_leave_requests`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `subscriptions`
--
ALTER TABLE `subscriptions`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `subscription_prices`
--
ALTER TABLE `subscription_prices`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `subscription_price_permissions`
--
ALTER TABLE `subscription_price_permissions`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `teacher_assignments`
--
ALTER TABLE `teacher_assignments`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `teacher_reports`
--
ALTER TABLE `teacher_reports`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `teaching_records`
--
ALTER TABLE `teaching_records`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `vehicles`
--
ALTER TABLE `vehicles`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `academic_classes`
--
ALTER TABLE `academic_classes`
  ADD CONSTRAINT `fk_academic_class_creator` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `academic_class_subjects`
--
ALTER TABLE `academic_class_subjects`
  ADD CONSTRAINT `fk_academic_subject_class` FOREIGN KEY (`class_id`) REFERENCES `academic_classes` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_academic_subject_creator` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `ai_provider_settings`
--
ALTER TABLE `ai_provider_settings`
  ADD CONSTRAINT `fk_ai_provider_settings_user` FOREIGN KEY (`updated_by`) REFERENCES `users` (`id`);

--
-- Constraints for table `ai_question_import_batches`
--
ALTER TABLE `ai_question_import_batches`
  ADD CONSTRAINT `fk_ai_question_import_creator` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `fk_ai_question_import_school` FOREIGN KEY (`school_id`) REFERENCES `schools` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `audit_logs`
--
ALTER TABLE `audit_logs`
  ADD CONSTRAINT `fk_audit_actor` FOREIGN KEY (`actor_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `class_timetable_entries`
--
ALTER TABLE `class_timetable_entries`
  ADD CONSTRAINT `fk_timetable_class` FOREIGN KEY (`class_id`,`school_id`) REFERENCES `school_classes` (`id`, `school_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_timetable_creator` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `fk_timetable_school` FOREIGN KEY (`school_id`) REFERENCES `schools` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_timetable_stream` FOREIGN KEY (`stream_id`) REFERENCES `school_streams` (`id`),
  ADD CONSTRAINT `fk_timetable_subject` FOREIGN KEY (`subject_id`) REFERENCES `school_class_subjects` (`id`),
  ADD CONSTRAINT `fk_timetable_teacher` FOREIGN KEY (`teacher_id`) REFERENCES `users` (`id`);

--
-- Constraints for table `departments`
--
ALTER TABLE `departments`
  ADD CONSTRAINT `fk_department_head` FOREIGN KEY (`head_user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_department_school` FOREIGN KEY (`school_id`) REFERENCES `schools` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `department_reports`
--
ALTER TABLE `department_reports`
  ADD CONSTRAINT `fk_department_report_author` FOREIGN KEY (`author_id`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `fk_department_report_department` FOREIGN KEY (`department_id`) REFERENCES `departments` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_department_report_reviewer` FOREIGN KEY (`reviewed_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_department_report_school` FOREIGN KEY (`school_id`) REFERENCES `schools` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `department_subjects`
--
ALTER TABLE `department_subjects`
  ADD CONSTRAINT `fk_department_subject_creator` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `fk_department_subject_department` FOREIGN KEY (`department_id`) REFERENCES `departments` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_department_subject_school` FOREIGN KEY (`school_id`) REFERENCES `schools` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_department_subject_subject` FOREIGN KEY (`class_subject_id`) REFERENCES `school_class_subjects` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `employee_attendance`
--
ALTER TABLE `employee_attendance`
  ADD CONSTRAINT `fk_employee_attendance_checkin` FOREIGN KEY (`check_in_by`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `fk_employee_attendance_checkout` FOREIGN KEY (`check_out_by`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `fk_employee_attendance_school` FOREIGN KEY (`school_id`) REFERENCES `schools` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_employee_attendance_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);

--
-- Constraints for table `employee_contracts`
--
ALTER TABLE `employee_contracts`
  ADD CONSTRAINT `fk_contract_creator` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `fk_contract_renewed_from` FOREIGN KEY (`renewed_from_id`) REFERENCES `employee_contracts` (`id`),
  ADD CONSTRAINT `fk_contract_school` FOREIGN KEY (`school_id`) REFERENCES `schools` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_contract_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `employee_documents`
--
ALTER TABLE `employee_documents`
  ADD CONSTRAINT `fk_employee_document_school` FOREIGN KEY (`school_id`) REFERENCES `schools` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_employee_document_uploader` FOREIGN KEY (`uploaded_by`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `fk_employee_document_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);

--
-- Constraints for table `employee_profiles`
--
ALTER TABLE `employee_profiles`
  ADD CONSTRAINT `fk_employee_profile_creator` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `fk_employee_profile_school` FOREIGN KEY (`school_id`) REFERENCES `schools` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_employee_profile_updater` FOREIGN KEY (`updated_by`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `fk_employee_profile_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);

--
-- Constraints for table `exam_paper_questions`
--
ALTER TABLE `exam_paper_questions`
  ADD CONSTRAINT `fk_exam_question_bank` FOREIGN KEY (`question_id`) REFERENCES `question_bank` (`id`),
  ADD CONSTRAINT `fk_exam_question_exam` FOREIGN KEY (`exam_id`) REFERENCES `school_exams` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `fee_assessments`
--
ALTER TABLE `fee_assessments`
  ADD CONSTRAINT `fk_fee_assessment_item` FOREIGN KEY (`item_id`,`structure_id`,`school_id`) REFERENCES `fee_structure_items` (`id`, `structure_id`, `school_id`),
  ADD CONSTRAINT `fk_fee_assessment_ledger` FOREIGN KEY (`ledger_entry_id`,`school_id`,`pupil_id`) REFERENCES `school_fee_ledger` (`id`, `school_id`, `pupil_id`),
  ADD CONSTRAINT `fk_fee_assessment_pupil` FOREIGN KEY (`pupil_id`,`school_id`) REFERENCES `pupils` (`id`, `school_id`),
  ADD CONSTRAINT `fk_fee_assessment_structure` FOREIGN KEY (`structure_id`,`school_id`) REFERENCES `fee_structures` (`id`, `school_id`);

--
-- Constraints for table `fee_reconciliation_batches`
--
ALTER TABLE `fee_reconciliation_batches`
  ADD CONSTRAINT `fk_fee_reconciliation_completer` FOREIGN KEY (`completed_by`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `fk_fee_reconciliation_creator` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `fk_fee_reconciliation_school` FOREIGN KEY (`school_id`) REFERENCES `schools` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `fee_reconciliation_lines`
--
ALTER TABLE `fee_reconciliation_lines`
  ADD CONSTRAINT `fk_fee_reconciliation_batch` FOREIGN KEY (`batch_id`,`school_id`) REFERENCES `fee_reconciliation_batches` (`id`, `school_id`) ON DELETE CASCADE;

--
-- Constraints for table `fee_structures`
--
ALTER TABLE `fee_structures`
  ADD CONSTRAINT `fk_fee_structure_class` FOREIGN KEY (`class_id`,`school_id`) REFERENCES `school_classes` (`id`, `school_id`),
  ADD CONSTRAINT `fk_fee_structure_creator` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `fk_fee_structure_school` FOREIGN KEY (`school_id`) REFERENCES `schools` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `fee_structure_items`
--
ALTER TABLE `fee_structure_items`
  ADD CONSTRAINT `fk_fee_item_structure` FOREIGN KEY (`structure_id`,`school_id`) REFERENCES `fee_structures` (`id`, `school_id`) ON DELETE CASCADE;

--
-- Constraints for table `holiday_packages`
--
ALTER TABLE `holiday_packages`
  ADD CONSTRAINT `fk_holiday_package_class` FOREIGN KEY (`class_id`) REFERENCES `school_classes` (`id`),
  ADD CONSTRAINT `fk_holiday_package_creator` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `fk_holiday_package_reviewer` FOREIGN KEY (`reviewed_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_holiday_package_school` FOREIGN KEY (`school_id`) REFERENCES `schools` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_holiday_package_subject` FOREIGN KEY (`subject_id`) REFERENCES `school_class_subjects` (`id`);

--
-- Constraints for table `holiday_package_items`
--
ALTER TABLE `holiday_package_items`
  ADD CONSTRAINT `fk_holiday_item_note` FOREIGN KEY (`learning_note_id`) REFERENCES `learning_notes` (`id`),
  ADD CONSTRAINT `fk_holiday_item_package` FOREIGN KEY (`package_id`,`school_id`) REFERENCES `holiday_packages` (`id`, `school_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_holiday_item_question` FOREIGN KEY (`question_id`) REFERENCES `question_bank` (`id`);

--
-- Constraints for table `holiday_package_progress`
--
ALTER TABLE `holiday_package_progress`
  ADD CONSTRAINT `fk_holiday_progress_feedback` FOREIGN KEY (`feedback_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_holiday_progress_package` FOREIGN KEY (`package_id`,`school_id`) REFERENCES `holiday_packages` (`id`, `school_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_holiday_progress_pupil` FOREIGN KEY (`pupil_id`,`school_id`) REFERENCES `pupils` (`id`, `school_id`) ON DELETE CASCADE;

--
-- Constraints for table `homework_assignments`
--
ALTER TABLE `homework_assignments`
  ADD CONSTRAINT `fk_homework_note` FOREIGN KEY (`learning_note_id`) REFERENCES `learning_notes` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_homework_school` FOREIGN KEY (`school_id`) REFERENCES `schools` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_homework_teacher` FOREIGN KEY (`teacher_id`) REFERENCES `users` (`id`);

--
-- Constraints for table `inventory_categories`
--
ALTER TABLE `inventory_categories`
  ADD CONSTRAINT `fk_inventory_category_creator` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `fk_inventory_category_school` FOREIGN KEY (`school_id`) REFERENCES `schools` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_inventory_category_updater` FOREIGN KEY (`updated_by`) REFERENCES `users` (`id`);

--
-- Constraints for table `inventory_items`
--
ALTER TABLE `inventory_items`
  ADD CONSTRAINT `fk_inventory_category` FOREIGN KEY (`category_id`,`school_id`) REFERENCES `inventory_categories` (`id`, `school_id`),
  ADD CONSTRAINT `fk_inventory_school` FOREIGN KEY (`school_id`) REFERENCES `schools` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_inventory_user` FOREIGN KEY (`updated_by`) REFERENCES `users` (`id`);

--
-- Constraints for table `inventory_movements`
--
ALTER TABLE `inventory_movements`
  ADD CONSTRAINT `fk_inventory_movement_item` FOREIGN KEY (`item_id`) REFERENCES `inventory_items` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_inventory_movement_request` FOREIGN KEY (`request_id`) REFERENCES `inventory_requests` (`id`),
  ADD CONSTRAINT `fk_inventory_movement_school` FOREIGN KEY (`school_id`) REFERENCES `schools` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_inventory_movement_supplier` FOREIGN KEY (`supplier_id`) REFERENCES `inventory_suppliers` (`id`),
  ADD CONSTRAINT `fk_inventory_movement_user` FOREIGN KEY (`recorded_by`) REFERENCES `users` (`id`);

--
-- Constraints for table `inventory_requests`
--
ALTER TABLE `inventory_requests`
  ADD CONSTRAINT `fk_inventory_request_item` FOREIGN KEY (`item_id`) REFERENCES `inventory_items` (`id`),
  ADD CONSTRAINT `fk_inventory_request_school` FOREIGN KEY (`school_id`) REFERENCES `schools` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_inventory_requester` FOREIGN KEY (`requested_by`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `fk_inventory_reviewer` FOREIGN KEY (`reviewed_by`) REFERENCES `users` (`id`);

--
-- Constraints for table `inventory_stocktakes`
--
ALTER TABLE `inventory_stocktakes`
  ADD CONSTRAINT `fk_inventory_stocktake_creator` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `fk_inventory_stocktake_reviewer` FOREIGN KEY (`reviewed_by`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `fk_inventory_stocktake_school` FOREIGN KEY (`school_id`) REFERENCES `schools` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `inventory_stocktake_lines`
--
ALTER TABLE `inventory_stocktake_lines`
  ADD CONSTRAINT `fk_inventory_stocktake_line_item` FOREIGN KEY (`item_id`,`school_id`) REFERENCES `inventory_items` (`id`, `school_id`),
  ADD CONSTRAINT `fk_inventory_stocktake_line_session` FOREIGN KEY (`stocktake_id`,`school_id`) REFERENCES `inventory_stocktakes` (`id`, `school_id`) ON DELETE CASCADE;

--
-- Constraints for table `inventory_suppliers`
--
ALTER TABLE `inventory_suppliers`
  ADD CONSTRAINT `fk_inventory_supplier_creator` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `fk_inventory_supplier_school` FOREIGN KEY (`school_id`) REFERENCES `schools` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_inventory_supplier_updater` FOREIGN KEY (`updated_by`) REFERENCES `users` (`id`);

--
-- Constraints for table `learning_notes`
--
ALTER TABLE `learning_notes`
  ADD CONSTRAINT `fk_note_author` FOREIGN KEY (`author_id`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `fk_note_school` FOREIGN KEY (`school_id`) REFERENCES `schools` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `learning_note_terms`
--
ALTER TABLE `learning_note_terms`
  ADD CONSTRAINT `fk_learning_note_term_user` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`);

--
-- Constraints for table `lesson_plans`
--
ALTER TABLE `lesson_plans`
  ADD CONSTRAINT `fk_lesson_reviewer` FOREIGN KEY (`reviewed_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_lesson_scheme` FOREIGN KEY (`scheme_id`) REFERENCES `schemes_of_work` (`id`),
  ADD CONSTRAINT `fk_lesson_school` FOREIGN KEY (`school_id`) REFERENCES `schools` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_lesson_stream` FOREIGN KEY (`stream_id`) REFERENCES `school_streams` (`id`),
  ADD CONSTRAINT `fk_lesson_teacher` FOREIGN KEY (`teacher_id`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `fk_lesson_topic` FOREIGN KEY (`topic_id`) REFERENCES `scheme_topics` (`id`);

--
-- Constraints for table `lesson_plan_resources`
--
ALTER TABLE `lesson_plan_resources`
  ADD CONSTRAINT `fk_lesson_resource_creator` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `fk_lesson_resource_lesson` FOREIGN KEY (`lesson_plan_id`,`school_id`) REFERENCES `lesson_plans` (`id`, `school_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_lesson_resource_note` FOREIGN KEY (`learning_note_id`) REFERENCES `learning_notes` (`id`),
  ADD CONSTRAINT `fk_lesson_resource_school` FOREIGN KEY (`school_id`) REFERENCES `schools` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `parent_conversations`
--
ALTER TABLE `parent_conversations`
  ADD CONSTRAINT `fk_parent_conversation_guardian` FOREIGN KEY (`guardian_user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_parent_conversation_pupil` FOREIGN KEY (`pupil_id`,`school_id`) REFERENCES `pupils` (`id`, `school_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_parent_conversation_school` FOREIGN KEY (`school_id`) REFERENCES `schools` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_parent_conversation_staff` FOREIGN KEY (`staff_user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `parent_messages`
--
ALTER TABLE `parent_messages`
  ADD CONSTRAINT `fk_parent_message_conversation` FOREIGN KEY (`conversation_id`,`school_id`) REFERENCES `parent_conversations` (`id`, `school_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_parent_message_sender` FOREIGN KEY (`sender_user_id`) REFERENCES `users` (`id`);

--
-- Constraints for table `pupils`
--
ALTER TABLE `pupils`
  ADD CONSTRAINT `fk_pupil_school` FOREIGN KEY (`school_id`) REFERENCES `schools` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `pupil_accounts`
--
ALTER TABLE `pupil_accounts`
  ADD CONSTRAINT `fk_pupil_account_child` FOREIGN KEY (`pupil_id`,`school_id`) REFERENCES `pupils` (`id`, `school_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_pupil_account_linker` FOREIGN KEY (`linked_by`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `fk_pupil_account_revoker` FOREIGN KEY (`revoked_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_pupil_account_school` FOREIGN KEY (`school_id`) REFERENCES `schools` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_pupil_account_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `pupil_attendance`
--
ALTER TABLE `pupil_attendance`
  ADD CONSTRAINT `fk_attendance_pupil` FOREIGN KEY (`pupil_id`) REFERENCES `pupils` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_attendance_school` FOREIGN KEY (`school_id`) REFERENCES `schools` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_attendance_user` FOREIGN KEY (`recorded_by`) REFERENCES `users` (`id`);

--
-- Constraints for table `pupil_class_history`
--
ALTER TABLE `pupil_class_history`
  ADD CONSTRAINT `fk_class_history_pupil` FOREIGN KEY (`pupil_id`) REFERENCES `pupils` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_class_history_school` FOREIGN KEY (`school_id`) REFERENCES `schools` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_class_history_user` FOREIGN KEY (`changed_by`) REFERENCES `users` (`id`);

--
-- Constraints for table `pupil_guardians`
--
ALTER TABLE `pupil_guardians`
  ADD CONSTRAINT `fk_pupil_guardian_child` FOREIGN KEY (`pupil_id`,`school_id`) REFERENCES `pupils` (`id`, `school_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_pupil_guardian_linker` FOREIGN KEY (`linked_by`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `fk_pupil_guardian_school` FOREIGN KEY (`school_id`) REFERENCES `schools` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_pupil_guardian_user` FOREIGN KEY (`guardian_user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `pupil_homework_submissions`
--
ALTER TABLE `pupil_homework_submissions`
  ADD CONSTRAINT `fk_homework_submission_assignment` FOREIGN KEY (`assignment_id`,`school_id`) REFERENCES `homework_assignments` (`id`, `school_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_homework_submission_pupil` FOREIGN KEY (`pupil_id`,`school_id`) REFERENCES `pupils` (`id`, `school_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_homework_submission_reviewer` FOREIGN KEY (`reviewed_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_homework_submission_school` FOREIGN KEY (`school_id`) REFERENCES `schools` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `pupil_report_cards`
--
ALTER TABLE `pupil_report_cards`
  ADD CONSTRAINT `fk_report_card_creator` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `fk_report_card_headteacher` FOREIGN KEY (`headteacher_comment_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_report_card_publisher` FOREIGN KEY (`published_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_report_card_pupil` FOREIGN KEY (`pupil_id`,`school_id`) REFERENCES `pupils` (`id`, `school_id`),
  ADD CONSTRAINT `fk_report_card_school` FOREIGN KEY (`school_id`) REFERENCES `schools` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_report_card_teacher` FOREIGN KEY (`teacher_comment_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_report_card_updater` FOREIGN KEY (`updated_by`) REFERENCES `users` (`id`);

--
-- Constraints for table `pupil_results`
--
ALTER TABLE `pupil_results`
  ADD CONSTRAINT `fk_result_pupil` FOREIGN KEY (`pupil_id`) REFERENCES `pupils` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_result_school` FOREIGN KEY (`school_id`) REFERENCES `schools` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_result_user` FOREIGN KEY (`entered_by`) REFERENCES `users` (`id`);

--
-- Constraints for table `pupil_status_history`
--
ALTER TABLE `pupil_status_history`
  ADD CONSTRAINT `fk_pupil_status_history_actor` FOREIGN KEY (`changed_by`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `fk_pupil_status_history_pupil` FOREIGN KEY (`pupil_id`,`school_id`) REFERENCES `pupils` (`id`, `school_id`) ON DELETE CASCADE;

--
-- Constraints for table `question_bank`
--
ALTER TABLE `question_bank`
  ADD CONSTRAINT `fk_question_class` FOREIGN KEY (`class_id`) REFERENCES `school_classes` (`id`),
  ADD CONSTRAINT `fk_question_creator` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `fk_question_reviewer` FOREIGN KEY (`reviewed_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_question_scheme_topic` FOREIGN KEY (`scheme_topic_id`) REFERENCES `scheme_topics` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_question_school` FOREIGN KEY (`school_id`) REFERENCES `schools` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_question_subject` FOREIGN KEY (`subject_id`) REFERENCES `school_class_subjects` (`id`);

--
-- Constraints for table `result_correction_requests`
--
ALTER TABLE `result_correction_requests`
  ADD CONSTRAINT `fk_result_correction_exam` FOREIGN KEY (`exam_id`) REFERENCES `school_exams` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_result_correction_requester` FOREIGN KEY (`requested_by`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `fk_result_correction_result` FOREIGN KEY (`pupil_result_id`) REFERENCES `pupil_results` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_result_correction_reviewer` FOREIGN KEY (`reviewed_by`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `fk_result_correction_school` FOREIGN KEY (`school_id`) REFERENCES `schools` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `result_delegations`
--
ALTER TABLE `result_delegations`
  ADD CONSTRAINT `fk_delegation_grantor` FOREIGN KEY (`granted_by`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `fk_delegation_school` FOREIGN KEY (`school_id`) REFERENCES `schools` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_delegation_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `schemes_of_work`
--
ALTER TABLE `schemes_of_work`
  ADD CONSTRAINT `fk_scheme_class` FOREIGN KEY (`class_id`) REFERENCES `school_classes` (`id`),
  ADD CONSTRAINT `fk_scheme_creator` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `fk_scheme_parent` FOREIGN KEY (`parent_scheme_id`) REFERENCES `schemes_of_work` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_scheme_reviewer` FOREIGN KEY (`reviewed_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_scheme_school` FOREIGN KEY (`school_id`) REFERENCES `schools` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_scheme_subject` FOREIGN KEY (`subject_id`) REFERENCES `school_class_subjects` (`id`);

--
-- Constraints for table `scheme_topics`
--
ALTER TABLE `scheme_topics`
  ADD CONSTRAINT `fk_scheme_topic_scheme` FOREIGN KEY (`scheme_id`) REFERENCES `schemes_of_work` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `schools`
--
ALTER TABLE `schools`
  ADD CONSTRAINT `fk_school_creator` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `school_announcements`
--
ALTER TABLE `school_announcements`
  ADD CONSTRAINT `fk_announcement_creator` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `fk_announcement_publisher` FOREIGN KEY (`published_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_announcement_school` FOREIGN KEY (`school_id`) REFERENCES `schools` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `school_classes`
--
ALTER TABLE `school_classes`
  ADD CONSTRAINT `fk_class_creator` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_class_school` FOREIGN KEY (`school_id`) REFERENCES `schools` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_school_class_core` FOREIGN KEY (`core_class_id`) REFERENCES `academic_classes` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `school_class_subjects`
--
ALTER TABLE `school_class_subjects`
  ADD CONSTRAINT `fk_class_subject_class` FOREIGN KEY (`class_id`) REFERENCES `school_classes` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_class_subject_creator` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_school_class_core_subject` FOREIGN KEY (`core_subject_id`) REFERENCES `academic_class_subjects` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `school_edit_permissions`
--
ALTER TABLE `school_edit_permissions`
  ADD CONSTRAINT `fk_school_edit_permission_grantor` FOREIGN KEY (`granted_by`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `fk_school_edit_permission_school` FOREIGN KEY (`school_id`) REFERENCES `schools` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_school_edit_permission_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `school_edit_requests`
--
ALTER TABLE `school_edit_requests`
  ADD CONSTRAINT `fk_school_edit_request_reviewer` FOREIGN KEY (`reviewed_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_school_edit_request_school` FOREIGN KEY (`school_id`) REFERENCES `schools` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_school_edit_request_user` FOREIGN KEY (`requested_by`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `school_exams`
--
ALTER TABLE `school_exams`
  ADD CONSTRAINT `fk_exam_class` FOREIGN KEY (`class_id`) REFERENCES `school_classes` (`id`),
  ADD CONSTRAINT `fk_exam_creator` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `fk_exam_reviewer` FOREIGN KEY (`reviewed_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_exam_school` FOREIGN KEY (`school_id`) REFERENCES `schools` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_exam_subject` FOREIGN KEY (`subject_id`) REFERENCES `school_class_subjects` (`id`);

--
-- Constraints for table `school_fee_ledger`
--
ALTER TABLE `school_fee_ledger`
  ADD CONSTRAINT `fk_fee_ledger_pupil` FOREIGN KEY (`pupil_id`) REFERENCES `pupils` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_fee_ledger_reversal` FOREIGN KEY (`reversal_of`) REFERENCES `school_fee_ledger` (`id`),
  ADD CONSTRAINT `fk_fee_ledger_school` FOREIGN KEY (`school_id`) REFERENCES `schools` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_fee_ledger_user` FOREIGN KEY (`recorded_by`) REFERENCES `users` (`id`);

--
-- Constraints for table `school_grading_bands`
--
ALTER TABLE `school_grading_bands`
  ADD CONSTRAINT `fk_grading_band_scale` FOREIGN KEY (`scale_id`) REFERENCES `school_grading_scales` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `school_grading_scales`
--
ALTER TABLE `school_grading_scales`
  ADD CONSTRAINT `fk_grading_scale_class` FOREIGN KEY (`class_id`,`school_id`) REFERENCES `school_classes` (`id`, `school_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_grading_scale_creator` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `fk_grading_scale_publisher` FOREIGN KEY (`published_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_grading_scale_school` FOREIGN KEY (`school_id`) REFERENCES `schools` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `school_memberships`
--
ALTER TABLE `school_memberships`
  ADD CONSTRAINT `fk_member_school` FOREIGN KEY (`school_id`) REFERENCES `schools` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_member_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `school_setup_permissions`
--
ALTER TABLE `school_setup_permissions`
  ADD CONSTRAINT `fk_school_setup_permission_grantor` FOREIGN KEY (`granted_by`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `fk_school_setup_permission_school` FOREIGN KEY (`school_id`) REFERENCES `schools` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_school_setup_permission_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `school_sms_outbox`
--
ALTER TABLE `school_sms_outbox`
  ADD CONSTRAINT `fk_school_sms_outbox_creator` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_school_sms_outbox_pupil` FOREIGN KEY (`pupil_id`) REFERENCES `pupils` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_school_sms_outbox_recipient` FOREIGN KEY (`recipient_user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_school_sms_outbox_school` FOREIGN KEY (`school_id`) REFERENCES `schools` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `school_sms_templates`
--
ALTER TABLE `school_sms_templates`
  ADD CONSTRAINT `fk_school_sms_template_school` FOREIGN KEY (`school_id`) REFERENCES `schools` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_school_sms_template_updater` FOREIGN KEY (`updated_by`) REFERENCES `users` (`id`);

--
-- Constraints for table `school_streams`
--
ALTER TABLE `school_streams`
  ADD CONSTRAINT `fk_stream_class` FOREIGN KEY (`class_id`) REFERENCES `school_classes` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_stream_creator` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `school_subjects`
--
ALTER TABLE `school_subjects`
  ADD CONSTRAINT `fk_subject_creator` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_subject_school` FOREIGN KEY (`school_id`) REFERENCES `schools` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `school_subscription_discounts`
--
ALTER TABLE `school_subscription_discounts`
  ADD CONSTRAINT `fk_school_subscription_discount_school` FOREIGN KEY (`school_id`) REFERENCES `schools` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_school_subscription_discount_user` FOREIGN KEY (`updated_by`) REFERENCES `users` (`id`);

--
-- Constraints for table `sms_delivery_logs`
--
ALTER TABLE `sms_delivery_logs`
  ADD CONSTRAINT `fk_sms_delivery_actor` FOREIGN KEY (`actor_id`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_sms_delivery_director` FOREIGN KEY (`director_user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_sms_delivery_school` FOREIGN KEY (`school_id`) REFERENCES `schools` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `staff_leave_requests`
--
ALTER TABLE `staff_leave_requests`
  ADD CONSTRAINT `fk_leave_reviewer` FOREIGN KEY (`reviewed_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_leave_school` FOREIGN KEY (`school_id`) REFERENCES `schools` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_leave_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `subscriptions`
--
ALTER TABLE `subscriptions`
  ADD CONSTRAINT `fk_subscription_creator` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `fk_subscription_price` FOREIGN KEY (`price_id`) REFERENCES `subscription_prices` (`id`),
  ADD CONSTRAINT `fk_subscription_school` FOREIGN KEY (`school_id`) REFERENCES `schools` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `subscription_prices`
--
ALTER TABLE `subscription_prices`
  ADD CONSTRAINT `fk_price_creator` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `subscription_price_permissions`
--
ALTER TABLE `subscription_price_permissions`
  ADD CONSTRAINT `fk_subscription_price_permission_grantor` FOREIGN KEY (`granted_by`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `fk_subscription_price_permission_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `teacher_assignments`
--
ALTER TABLE `teacher_assignments`
  ADD CONSTRAINT `fk_assignment_school` FOREIGN KEY (`school_id`) REFERENCES `schools` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_assignment_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `teacher_reports`
--
ALTER TABLE `teacher_reports`
  ADD CONSTRAINT `fk_teacher_report_reviewer` FOREIGN KEY (`reviewed_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_teacher_report_school` FOREIGN KEY (`school_id`) REFERENCES `schools` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_teacher_report_teacher` FOREIGN KEY (`teacher_id`) REFERENCES `users` (`id`);

--
-- Constraints for table `teaching_records`
--
ALTER TABLE `teaching_records`
  ADD CONSTRAINT `fk_teaching_lesson` FOREIGN KEY (`lesson_plan_id`) REFERENCES `lesson_plans` (`id`),
  ADD CONSTRAINT `fk_teaching_school` FOREIGN KEY (`school_id`) REFERENCES `schools` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_teaching_teacher` FOREIGN KEY (`teacher_id`) REFERENCES `users` (`id`);

--
-- Constraints for table `vehicles`
--
ALTER TABLE `vehicles`
  ADD CONSTRAINT `fk_vehicle_driver` FOREIGN KEY (`driver_user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_vehicle_school` FOREIGN KEY (`school_id`) REFERENCES `schools` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
