# ************************************************************
# Sequel Pro SQL dump
# Version 4096
#
# http://www.sequelpro.com/
# http://code.google.com/p/sequel-pro/
#
# Host: 127.0.0.1 (MySQL 10.0.11-MariaDB-log)
# Database: sqlite
# Generation Time: 2014-06-06 17:34:16 +0000
# ************************************************************


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


# Dump of table board_read_receipts
# ------------------------------------------------------------

DROP TABLE IF EXISTS `board_read_receipts`;

CREATE TABLE `board_read_receipts` (
  `board_id` varchar(32) NOT NULL DEFAULT '',
  `user_id` int(11) NOT NULL,
  `read_time` datetime NOT NULL,
  UNIQUE KEY `board_id` (`board_id`,`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table boards
# ------------------------------------------------------------

DROP TABLE IF EXISTS `boards`;

CREATE TABLE `boards` (
  `board_id` varchar(32) NOT NULL,
  `board_title` varchar(255) NOT NULL,
  `board_icon` varchar(255) NOT NULL,
  `category_id` varchar(32) NOT NULL,
  `vip_only` tinyint(4) DEFAULT NULL,
  `mods_only` tinyint(4) DEFAULT NULL,
  `board_guest_hidden` tinyint(4) DEFAULT NULL,
  `no_new_user_threads` tinyint(4) DEFAULT NULL,
  `board_position` int(11) NOT NULL,
  `board_description` varchar(255) NOT NULL,
  `board_message_total` int(11) NOT NULL DEFAULT '0',
  `board_thread_total` int(11) NOT NULL DEFAULT '0',
  `board_last_post_time` int(10) NOT NULL DEFAULT '0',
  `board_last_post_id` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`board_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table categories
# ------------------------------------------------------------

DROP TABLE IF EXISTS `categories`;

CREATE TABLE `categories` (
  `category_id` varchar(32) NOT NULL,
  `category_title` varchar(255) NOT NULL,
  `category_description` varchar(255) NOT NULL,
  `cat_guest_hidden` tinyint(4) DEFAULT NULL,
  PRIMARY KEY (`category_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table error_log
# ------------------------------------------------------------

DROP TABLE IF EXISTS `error_log`;

CREATE TABLE `error_log` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `error` text,
  `env` text,
  `get` text,
  `post` text,
  `viewer` text,
  `error_date` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



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
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table messages
# ------------------------------------------------------------

DROP TABLE IF EXISTS `messages`;

CREATE TABLE `messages` (
  `message_id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `thread_id` int(11) NOT NULL,
  `message_ip` varchar(15) NOT NULL,
  `message_time` int(10) NOT NULL,
  `edited_time` int(10) DEFAULT NULL,
  `editor_id` int(11) DEFAULT NULL,
  `message_deleted` tinyint(4) DEFAULT '0',
  `attachment` varchar(255) DEFAULT NULL,
  `message_body` text NOT NULL,
  PRIMARY KEY (`message_id`),
  KEY `messages_user_id` (`user_id`),
  KEY `messages_thread_id` (`thread_id`),
  KEY `messages_message_time` (`message_time`),
  KEY `messages_message_deleted` (`message_deleted`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table pm_messages
# ------------------------------------------------------------

DROP TABLE IF EXISTS `pm_messages`;

CREATE TABLE `pm_messages` (
  `pm_message_id` int(11) NOT NULL AUTO_INCREMENT,
  `pm_sender_id` int(11) NOT NULL,
  `pm_receiver_id` int(11) NOT NULL,
  `pm_thread_id` int(11) NOT NULL,
  `pm_ip` varchar(15) NOT NULL,
  `pm_post_time` int(10) NOT NULL,
  `pm_body` text NOT NULL,
  PRIMARY KEY (`pm_message_id`),
  KEY `pm_messages_pm_sender_id` (`pm_sender_id`),
  KEY `pm_messages_pm_receiver_id` (`pm_receiver_id`),
  KEY `pm_messages_pm_thread_id` (`pm_thread_id`),
  KEY `pm_messages_pm_post_time` (`pm_post_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table pm_threads
# ------------------------------------------------------------

DROP TABLE IF EXISTS `pm_threads`;

CREATE TABLE `pm_threads` (
  `pm_thread_id` int(11) NOT NULL AUTO_INCREMENT,
  `pm_subject` varchar(255) NOT NULL DEFAULT '(No Subject)',
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
  PRIMARY KEY (`pm_thread_id`),
  KEY `pm_threads_pm_sender_id` (`pm_sender_id`),
  KEY `pm_threads_pm_receiver_id` (`pm_receiver_id`),
  KEY `pm_threads_pm_last_msg_time` (`pm_last_msg_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table poll_options
# ------------------------------------------------------------

DROP TABLE IF EXISTS `poll_options`;

CREATE TABLE `poll_options` (
  `poll_option_id` int(11) NOT NULL AUTO_INCREMENT,
  `thread_id` int(11) NOT NULL,
  `poll_option` varchar(255) NOT NULL,
  PRIMARY KEY (`poll_option_id`),
  KEY `poll_options_thread_id` (`thread_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table poll_votes
# ------------------------------------------------------------

DROP TABLE IF EXISTS `poll_votes`;

CREATE TABLE `poll_votes` (
  `thread_id` int(11) NOT NULL DEFAULT '0',
  `user_id` int(11) NOT NULL DEFAULT '0',
  `poll_option_id` int(11) NOT NULL DEFAULT '0',
  `poll_ip_address` varchar(15) NOT NULL DEFAULT '0',
  KEY `poll_votes_thread_id` (`thread_id`),
  KEY `poll_votes_poll_option_id` (`poll_option_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table polls
# ------------------------------------------------------------

DROP TABLE IF EXISTS `polls`;

CREATE TABLE `polls` (
  `thread_id` int(11) NOT NULL AUTO_INCREMENT,
  `question` varchar(255) NOT NULL,
  `poll_locked` tinyint(4) DEFAULT '0',
  `multi` tinyint(4) DEFAULT '0',
  `private` tinyint(4) DEFAULT '0',
  `user_id` int(11) NOT NULL,
  `poll_start_time` int(10) NOT NULL,
  PRIMARY KEY (`thread_id`),
  KEY `polls_poll_start_time` (`poll_start_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table post_groups
# ------------------------------------------------------------

DROP TABLE IF EXISTS `post_groups`;

CREATE TABLE `post_groups` (
  `post_group_id` int(11) NOT NULL AUTO_INCREMENT,
  `posts_required` int(11) NOT NULL DEFAULT '0',
  `post_group_title` varchar(255) NOT NULL,
  `post_group_image` varchar(32) DEFAULT NULL,
  `post_group_color` varchar(16) DEFAULT NULL,
  PRIMARY KEY (`post_group_id`),
  KEY `post_group_post_group_id` (`post_group_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table session
# ------------------------------------------------------------

DROP TABLE IF EXISTS `session`;

CREATE TABLE `session` (
  `id` varchar(32) NOT NULL DEFAULT '',
  `user_id` int(11) DEFAULT NULL,
  `date_online` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table shoutbox
# ------------------------------------------------------------

DROP TABLE IF EXISTS `shoutbox`;

CREATE TABLE `shoutbox` (
  `shout_id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `shout_ip_address` varchar(15) NOT NULL,
  `shout_time` int(10) NOT NULL,
  `shout_deleted` tinyint(4) DEFAULT '0',
  `shout_body` varchar(255) NOT NULL,
  PRIMARY KEY (`shout_id`),
  KEY `shoutbox_user_id` (`user_id`),
  KEY `shoutbox_shout_time` (`shout_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table special_groups
# ------------------------------------------------------------

DROP TABLE IF EXISTS `special_groups`;

CREATE TABLE `special_groups` (
  `spec_group_id` int(11) NOT NULL AUTO_INCREMENT,
  `spec_group_title` varchar(255) NOT NULL,
  `spec_group_image` varchar(32) DEFAULT NULL,
  `group_can_mod` tinyint(4) DEFAULT '0',
  `group_can_admin` tinyint(4) DEFAULT '0',
  `spec_group_color` varchar(16) DEFAULT NULL,
  PRIMARY KEY (`spec_group_id`),
  KEY `spec_group_spec_group_id` (`spec_group_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table thread_read_receipts
# ------------------------------------------------------------

DROP TABLE IF EXISTS `thread_read_receipts`;

CREATE TABLE `thread_read_receipts` (
  `thread_id` varchar(32) NOT NULL DEFAULT '',
  `user_id` int(11) NOT NULL,
  `read_time` datetime NOT NULL,
  UNIQUE KEY `thread_id` (`thread_id`,`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table threads
# ------------------------------------------------------------

DROP TABLE IF EXISTS `threads`;

CREATE TABLE `threads` (
  `thread_id` int(11) NOT NULL AUTO_INCREMENT,
  `thread_subject` varchar(255) NOT NULL DEFAULT '(No Subject)',
  `board_id` varchar(32) DEFAULT NULL,
  `thread_starter_id` int(11) NOT NULL,
  `thread_locked` int(11) DEFAULT NULL,
  `thread_star` int(11) DEFAULT NULL,
  `thread_deleted` int(11) DEFAULT NULL,
  `thread_views` int(11) NOT NULL DEFAULT '0',
  `thread_messages` int(11) NOT NULL DEFAULT '1',
  `thread_icon` varchar(32) DEFAULT NULL,
  `thread_last_message_time` int(11) NOT NULL DEFAULT '0',
  `thread_last_user_id` int(11) NOT NULL,
  `thread_first_message_id` int(11) NOT NULL,
  PRIMARY KEY (`thread_id`),
  KEY `threads_thread_last_message_time` (`thread_last_message_time`),
  KEY `threads_thread_star` (`thread_star`),
  KEY `threads_thread_deleted` (`thread_deleted`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table users
# ------------------------------------------------------------

DROP TABLE IF EXISTS `users`;

CREATE TABLE `users` (
  `user_id` int(11) NOT NULL AUTO_INCREMENT,
  `user_name` varchar(64) NOT NULL,
  `display_name` varchar(64) NOT NULL,
  `real_name` varchar(64) DEFAULT NULL,
  `email` varchar(255) NOT NULL,
  `password` varchar(32) NOT NULL,
  `bcrypt_password` varchar(72) NOT NULL DEFAULT '',
  `hide_email` tinyint(4) DEFAULT '0',
  `pm_notify` tinyint(4) DEFAULT '0',
  `stealth_login` tinyint(4) DEFAULT '0',
  `spec_group_id` int(11) DEFAULT '0',
  `template` varchar(32) DEFAULT NULL,
  `language` varchar(32) DEFAULT NULL,
  `tumblr` varchar(255) DEFAULT NULL,
  `last_fm` varchar(255) DEFAULT NULL,
  `homepage` varchar(255) DEFAULT NULL,
  `icq` varchar(16) DEFAULT NULL,
  `msn` varchar(255) DEFAULT NULL,
  `yim` varchar(255) DEFAULT NULL,
  `aim` varchar(255) DEFAULT NULL,
  `gtalk` varchar(255) DEFAULT NULL,
  `skype` varchar(255) DEFAULT NULL,
  `twitter` varchar(255) DEFAULT NULL,
  `flickr` varchar(255) DEFAULT NULL,
  `deviantart` varchar(255) DEFAULT NULL,
  `vimeo` varchar(255) DEFAULT NULL,
  `youtube` varchar(255) DEFAULT NULL,
  `facebook` varchar(255) DEFAULT NULL,
  `myspace` varchar(255) DEFAULT NULL,
  `bebo` varchar(255) DEFAULT NULL,
  `avatar` varchar(255) DEFAULT NULL,
  `usertext` varchar(255) DEFAULT NULL,
  `signature` text,
  `biography` text,
  `gender` varchar(255) DEFAULT NULL,
  `birthday` varchar(10) DEFAULT NULL,
  `timezone` varchar(10) DEFAULT NULL,
  `reg_time` int(10) NOT NULL,
  `last_online` int(10) DEFAULT '0',
  `last_ip` varchar(15) DEFAULT '0',
  `user_post_num` int(11) DEFAULT '0',
  `user_shout_num` int(11) DEFAULT '0',
  `user_deleted` tinyint(4) DEFAULT '0',
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `user_name` (`user_name`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;




/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
