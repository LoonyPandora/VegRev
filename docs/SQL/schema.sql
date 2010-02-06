# Sequel Pro dump
# Version 1630
# http://code.google.com/p/sequel-pro
#
# Host: localhost (MySQL 5.1.41-log)
# Database: dancer
# Generation Time: 2010-02-04 09:43:37 +0000
# ************************************************************

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


# Dump of table --pm_messages
# ------------------------------------------------------------

DROP TABLE IF EXISTS `--pm_messages`;

CREATE TABLE `--pm_messages` (
  `pm_message_id` int(11) NOT NULL AUTO_INCREMENT,
  `pm_sender_id` int(11) NOT NULL,
  `pm_receiver_id` int(11) NOT NULL,
  `pm_thread_id` int(11) NOT NULL,
  `pm_ip` varchar(15) COLLATE utf8_unicode_ci NOT NULL,
  `pm_post_time` int(10) NOT NULL,
  `pm_body` text COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`pm_message_id`),
  KEY `pm_sender_id` (`pm_sender_id`),
  KEY `pm_receiver_id` (`pm_receiver_id`)
) ENGINE=InnoDB AUTO_INCREMENT=27631 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;



# Dump of table --pm_threads
# ------------------------------------------------------------

DROP TABLE IF EXISTS `--pm_threads`;

CREATE TABLE `--pm_threads` (
  `pm_thread_id` int(11) NOT NULL AUTO_INCREMENT,
  `pm_subject` varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT '(No Subject)',
  `pm_sender_id` int(11) NOT NULL,
  `pm_receiver_id` int(11) NOT NULL,
  `pm_sender_unread` int(11) DEFAULT '0',
  `pm_receiver_unread` int(11) DEFAULT '0',
  `pm_total_messages` int(11) DEFAULT '0',
  `pm_sender_delete` tinyint(4) DEFAULT '0',
  `pm_receiver_delete` tinyint(4) DEFAULT '0',
  `pm_sender_archive` tinyint(4) DEFAULT '0',
  `pm_receiver_archive` tinyint(4) DEFAULT '0',
  `pm_last_msg_time` int(10) NOT NULL DEFAULT '0',
  `pm_last_poster_id` int(11) NOT NULL,
  PRIMARY KEY (`pm_thread_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1260545479 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;



# Dump of table board_permissions
# ------------------------------------------------------------

DROP TABLE IF EXISTS `board_permissions`;

CREATE TABLE `board_permissions` (
  `group_id` tinyint(4) DEFAULT NULL,
  `board_id` varchar(11) COLLATE utf8_unicode_ci DEFAULT NULL,
  `can_view_threads` tinyint(4) DEFAULT NULL,
  `can_start_threads` tinyint(4) DEFAULT NULL,
  `can_reply_threads` tinyint(4) DEFAULT NULL,
  `can_start_polls` tinyint(4) DEFAULT NULL,
  KEY `group_id` (`group_id`),
  KEY `board_id` (`board_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;



# Dump of table board_readers
# ------------------------------------------------------------

DROP TABLE IF EXISTS `board_readers`;

CREATE TABLE `board_readers` (
  `hash_id` varchar(32) COLLATE utf8_unicode_ci NOT NULL,
  `read_board_id` varchar(32) COLLATE utf8_unicode_ci NOT NULL,
  `read_user_id` int(11) NOT NULL,
  `read_timestamp` int(11) NOT NULL,
  PRIMARY KEY (`hash_id`),
  KEY `read_board_id` (`read_board_id`),
  KEY `read_user_id` (`read_user_id`),
  KEY `read_timestamp` (`read_timestamp`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;



# Dump of table board_subscriptions
# ------------------------------------------------------------

DROP TABLE IF EXISTS `board_subscriptions`;

CREATE TABLE `board_subscriptions` (
  `user_id` int(11) NOT NULL DEFAULT '0',
  `board_id` varchar(32) COLLATE utf8_unicode_ci NOT NULL,
  `type` tinyint(4) DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;



# Dump of table boards
# ------------------------------------------------------------

DROP TABLE IF EXISTS `boards`;

CREATE TABLE `boards` (
  `board_id` varchar(32) COLLATE utf8_unicode_ci NOT NULL,
  `board_title` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `board_icon` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `section_id` varchar(32) COLLATE utf8_unicode_ci NOT NULL,
  `category_id` varchar(32) COLLATE utf8_unicode_ci NOT NULL,
  `board_position` int(11) NOT NULL,
  `board_description` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `board_message_total` int(11) NOT NULL DEFAULT '0',
  `board_thread_total` int(11) NOT NULL DEFAULT '0',
  `board_last_post_time` int(10) NOT NULL DEFAULT '0',
  `board_last_post_id` int(11) NOT NULL DEFAULT '0',
  `board_member_only` int(11) NOT NULL,
  `board_vip_only` int(11) NOT NULL,
  `board_mod_only` int(11) NOT NULL,
  PRIMARY KEY (`board_id`),
  KEY `category_id` (`category_id`),
  KEY `board_id` (`board_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;



# Dump of table categories
# ------------------------------------------------------------

DROP TABLE IF EXISTS `categories`;

CREATE TABLE `categories` (
  `category_id` varchar(32) COLLATE utf8_unicode_ci NOT NULL,
  `category_title` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `category_description` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `cat_member_only` tinyint(1) DEFAULT NULL,
  `cat_vip_only` tinyint(1) DEFAULT NULL,
  `cat_mod_only` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`category_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;



# Dump of table category_permissions
# ------------------------------------------------------------

DROP TABLE IF EXISTS `category_permissions`;

CREATE TABLE `category_permissions` (
  `group_id` tinyint(4) DEFAULT NULL,
  `category_id` varchar(11) COLLATE utf8_unicode_ci DEFAULT NULL,
  `can_see` tinyint(4) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;



# Dump of table forum_stats
# ------------------------------------------------------------

DROP TABLE IF EXISTS `forum_stats`;

CREATE TABLE `forum_stats` (
  `forum_total_posts` int(11) NOT NULL DEFAULT '0',
  `forum_total_threads` int(11) NOT NULL DEFAULT '0',
  `forum_total_photos` int(11) NOT NULL DEFAULT '0',
  `forum_total_users` int(11) NOT NULL DEFAULT '0',
  `forum_total_shouts` int(11) NOT NULL DEFAULT '0',
  `forum_max_online` int(11) NOT NULL DEFAULT '0',
  `forum_max_online_time` int(10) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;



# Dump of table messages
# ------------------------------------------------------------

DROP TABLE IF EXISTS `messages`;

CREATE TABLE `messages` (
  `message_id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `thread_id` int(11) NOT NULL,
  `message_ip` varchar(15) COLLATE utf8_unicode_ci NOT NULL,
  `message_time` int(10) NOT NULL,
  `edited_time` int(10) DEFAULT NULL,
  `editor_id` int(11) DEFAULT NULL,
  `message_deleted` tinyint(4) DEFAULT '0',
  `attachment` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `message_body` text COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`message_id`),
  KEY `thread_id` (`thread_id`),
  KEY `user_id` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=799488 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;



# Dump of table poll_options
# ------------------------------------------------------------

DROP TABLE IF EXISTS `poll_options`;

CREATE TABLE `poll_options` (
  `poll_option_id` int(11) NOT NULL AUTO_INCREMENT,
  `thread_id` int(11) NOT NULL,
  `poll_option` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`poll_option_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1237 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;



# Dump of table poll_votes
# ------------------------------------------------------------

DROP TABLE IF EXISTS `poll_votes`;

CREATE TABLE `poll_votes` (
  `thread_id` int(11) NOT NULL DEFAULT '0',
  `user_id` int(11) NOT NULL DEFAULT '0',
  `poll_option_id` int(11) NOT NULL DEFAULT '0',
  `poll_ip_address` varchar(15) COLLATE utf8_unicode_ci NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;



# Dump of table polls
# ------------------------------------------------------------

DROP TABLE IF EXISTS `polls`;

CREATE TABLE `polls` (
  `thread_id` int(11) NOT NULL AUTO_INCREMENT,
  `question` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `poll_locked` tinyint(4) DEFAULT '0',
  `multi` tinyint(4) DEFAULT '0',
  `private` tinyint(4) DEFAULT '0',
  `user_id` int(11) NOT NULL,
  `poll_start_time` int(10) NOT NULL,
  PRIMARY KEY (`thread_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1259199095 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;



# Dump of table priv_conversations
# ------------------------------------------------------------

DROP TABLE IF EXISTS `priv_conversations`;

CREATE TABLE `priv_conversations` (
  `thread_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `unread_count` int(11) DEFAULT NULL,
  `deleted` int(11) DEFAULT NULL,
  KEY `user_id` (`user_id`),
  KEY `thread_id` (`thread_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;



# Dump of table priv_messages
# ------------------------------------------------------------

DROP TABLE IF EXISTS `priv_messages`;

CREATE TABLE `priv_messages` (
  `pm_message_id` int(11) NOT NULL AUTO_INCREMENT,
  `pm_sender_id` int(11) NOT NULL,
  `pm_receiver_id` int(11) NOT NULL,
  `pm_thread_id` int(11) NOT NULL,
  `pm_ip` varchar(15) COLLATE utf8_unicode_ci NOT NULL,
  `pm_post_time` int(10) NOT NULL,
  `pm_body` text COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`pm_message_id`),
  KEY `pm_sender_id` (`pm_sender_id`),
  KEY `pm_receiver_id` (`pm_receiver_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;



# Dump of table priv_threads
# ------------------------------------------------------------

DROP TABLE IF EXISTS `priv_threads`;

CREATE TABLE `priv_threads` (
  `pm_thread_id` int(11) NOT NULL AUTO_INCREMENT,
  `pm_subject` varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT '(No Subject)',
  `pm_total_messages` int(11) DEFAULT '0',
  `pm_last_msg_time` int(10) NOT NULL DEFAULT '0',
  `pm_last_poster_id` int(11) NOT NULL,
  PRIMARY KEY (`pm_thread_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;



# Dump of table searches
# ------------------------------------------------------------

DROP TABLE IF EXISTS `searches`;

CREATE TABLE `searches` (
  `search_id` int(11) NOT NULL DEFAULT '0',
  `search_type` varchar(11) COLLATE utf8_unicode_ci NOT NULL,
  `search_query` varchar(32) COLLATE utf8_unicode_ci NOT NULL,
  `search_time_from` int(11) NOT NULL DEFAULT '0',
  `search_time_to` int(11) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;



# Dump of table sections
# ------------------------------------------------------------

DROP TABLE IF EXISTS `sections`;

CREATE TABLE `sections` (
  `section_id` varchar(32) COLLATE utf8_unicode_ci NOT NULL,
  `section_title` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `section_description` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`section_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;



# Dump of table sessions
# ------------------------------------------------------------

DROP TABLE IF EXISTS `sessions`;

CREATE TABLE `sessions` (
  `user_id` int(11) NOT NULL,
  `last_online` int(10) NOT NULL DEFAULT '0',
  `session_ip` varchar(15) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;



# Dump of table shoutbox
# ------------------------------------------------------------

DROP TABLE IF EXISTS `shoutbox`;

CREATE TABLE `shoutbox` (
  `shout_id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `shout_ip_address` varchar(15) COLLATE utf8_unicode_ci NOT NULL,
  `shout_time` int(10) NOT NULL,
  `shout_deleted` tinyint(4) DEFAULT '0',
  `shout_body` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`shout_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4435 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;



# Dump of table thread_readers
# ------------------------------------------------------------

DROP TABLE IF EXISTS `thread_readers`;

CREATE TABLE `thread_readers` (
  `hash_id` varchar(32) COLLATE utf8_unicode_ci NOT NULL,
  `read_thread_id` int(11) NOT NULL,
  `read_user_id` int(11) NOT NULL,
  `read_timestamp` int(11) NOT NULL,
  PRIMARY KEY (`hash_id`),
  KEY `read_board_id` (`read_thread_id`),
  KEY `read_user_id` (`read_user_id`),
  KEY `read_timestamp` (`read_timestamp`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;



# Dump of table thread_subscriptions
# ------------------------------------------------------------

DROP TABLE IF EXISTS `thread_subscriptions`;

CREATE TABLE `thread_subscriptions` (
  `user_id` int(11) NOT NULL DEFAULT '0',
  `thread_id` int(11) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;



# Dump of table threads
# ------------------------------------------------------------

DROP TABLE IF EXISTS `threads`;

CREATE TABLE `threads` (
  `thread_id` int(11) NOT NULL,
  `thread_subject` varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT '(No Subject)',
  `board_id` varchar(32) COLLATE utf8_unicode_ci NOT NULL,
  `thread_starter_id` int(11) NOT NULL,
  `thread_locked` tinyint(4) DEFAULT NULL,
  `thread_star` int(11) DEFAULT NULL,
  `thread_deleted` tinyint(4) DEFAULT NULL,
  `thread_views` int(11) NOT NULL DEFAULT '0',
  `thread_messages` int(11) NOT NULL DEFAULT '1',
  `thread_icon` varchar(32) COLLATE utf8_unicode_ci DEFAULT NULL,
  `thread_last_message_time` int(10) NOT NULL DEFAULT '0',
  `thread_last_user_id` int(11) NOT NULL,
  `thread_first_message_id` int(11) NOT NULL,
  PRIMARY KEY (`thread_id`),
  KEY `board_id` (`board_id`),
  KEY `thread_last_message_time` (`thread_last_message_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;



# Dump of table user_groups
# ------------------------------------------------------------

DROP TABLE IF EXISTS `user_groups`;

CREATE TABLE `user_groups` (
  `group_id` int(11) NOT NULL AUTO_INCREMENT,
  `special_group` tinyint(4) NOT NULL DEFAULT '0',
  `posts_required` int(11) NOT NULL DEFAULT '0',
  `group_title` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `group_image` varchar(32) COLLATE utf8_unicode_ci DEFAULT NULL,
  `group_color` varchar(16) COLLATE utf8_unicode_ci DEFAULT NULL,
  `is_mod` tinyint(4) NOT NULL DEFAULT '0',
  `is_vip` tinyint(4) NOT NULL DEFAULT '0',
  `is_admin` tinyint(4) NOT NULL DEFAULT '0',
  PRIMARY KEY (`group_id`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;



# Dump of table users
# ------------------------------------------------------------

DROP TABLE IF EXISTS `users`;

CREATE TABLE `users` (
  `user_id` int(11) NOT NULL AUTO_INCREMENT,
  `user_name` varchar(64) COLLATE utf8_unicode_ci NOT NULL,
  `display_name` varchar(64) COLLATE utf8_unicode_ci NOT NULL,
  `real_name` varchar(64) COLLATE utf8_unicode_ci DEFAULT NULL,
  `email` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `password` varchar(32) COLLATE utf8_unicode_ci NOT NULL,
  `hide_email` tinyint(4) DEFAULT '0',
  `pm_notify` tinyint(4) DEFAULT '0',
  `stealth_login` tinyint(4) DEFAULT '0',
  `group_id` int(11) DEFAULT '0',
  `template` varchar(32) COLLATE utf8_unicode_ci DEFAULT NULL,
  `language` varchar(32) COLLATE utf8_unicode_ci DEFAULT NULL,
  `tumblr` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `last_fm` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `homepage` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `icq` varchar(16) COLLATE utf8_unicode_ci DEFAULT NULL,
  `msn` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `yim` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `aim` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `gtalk` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `skype` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `twitter` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `flickr` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `deviantart` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `vimeo` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `youtube` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `facebook` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `myspace` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `bebo` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `avatar` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `usertext` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `signature` text COLLATE utf8_unicode_ci,
  `biography` text COLLATE utf8_unicode_ci,
  `gender` varchar(8) COLLATE utf8_unicode_ci DEFAULT NULL,
  `birthday` varchar(10) COLLATE utf8_unicode_ci DEFAULT NULL,
  `timezone` varchar(10) COLLATE utf8_unicode_ci DEFAULT NULL,
  `reg_time` int(10) NOT NULL,
  `last_online` int(10) DEFAULT '0',
  `last_ip` varchar(15) COLLATE utf8_unicode_ci DEFAULT '0',
  `user_post_num` int(11) DEFAULT '0',
  `user_shout_num` int(11) DEFAULT '0',
  `user_deleted` tinyint(4) DEFAULT '0',
  PRIMARY KEY (`user_id`),
  KEY `user_name` (`user_name`)
) ENGINE=InnoDB AUTO_INCREMENT=2066 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;






/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
