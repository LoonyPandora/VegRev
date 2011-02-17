# Sequel Pro dump
# Version 2492
# http://code.google.com/p/sequel-pro
#
# Host: localhost (MySQL 5.1.45-log)
# Database: testing
# Generation Time: 2011-02-17 18:15:43 +0000
# ************************************************************

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


# Dump of table attachment
# ------------------------------------------------------------

DROP TABLE IF EXISTS `attachment`;

CREATE TABLE `attachment` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `message_id` int(10) unsigned NOT NULL,
  `title` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `extension` varchar(8) COLLATE utf8_unicode_ci NOT NULL,
  `original_name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  KEY `message_id` (`message_id`),
  CONSTRAINT `attachment_ibfk_1` FOREIGN KEY (`message_id`) REFERENCES `message` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;



# Dump of table forgot_password
# ------------------------------------------------------------

DROP TABLE IF EXISTS `forgot_password`;

CREATE TABLE `forgot_password` (
  `id` varchar(64) NOT NULL,
  `user_id` int(10) unsigned NOT NULL,
  `time_requested` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `forgot_password_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table mail
# ------------------------------------------------------------

DROP TABLE IF EXISTS `mail`;

CREATE TABLE `mail` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `ip_address` int(10) unsigned NOT NULL,
  `timestamp` datetime NOT NULL,
  `body` text COLLATE utf8_unicode_ci NOT NULL,
  `sent_to` int(10) unsigned NOT NULL,
  `sent_from` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `sent_to` (`sent_to`),
  KEY `sent_from` (`sent_from`),
  CONSTRAINT `mail_ibfk_2` FOREIGN KEY (`sent_from`) REFERENCES `user` (`id`),
  CONSTRAINT `mail_ibfk_1` FOREIGN KEY (`sent_to`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;



# Dump of table mail_read_receipt
# ------------------------------------------------------------

DROP TABLE IF EXISTS `mail_read_receipt`;

CREATE TABLE `mail_read_receipt` (
  `user_id` int(10) unsigned NOT NULL,
  `mail_id` int(10) unsigned NOT NULL,
  `datetime` datetime NOT NULL,
  KEY `user_id` (`user_id`),
  KEY `mail_id` (`mail_id`),
  CONSTRAINT `mail_read_receipt_ibfk_2` FOREIGN KEY (`mail_id`) REFERENCES `mail` (`id`),
  CONSTRAINT `mail_read_receipt_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;



# Dump of table message
# ------------------------------------------------------------

DROP TABLE IF EXISTS `message`;

CREATE TABLE `message` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int(10) unsigned NOT NULL,
  `thread_id` int(10) unsigned NOT NULL,
  `ip_address` int(10) unsigned NOT NULL,
  `timestamp` datetime NOT NULL,
  `edited_timestamp` datetime DEFAULT NULL,
  `editor_id` int(10) unsigned DEFAULT NULL,
  `deleted` tinyint(1) DEFAULT '0',
  `body` text COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  KEY `editor_id` (`editor_id`),
  KEY `thread_id` (`thread_id`),
  KEY `timestamp` (`timestamp`),
  CONSTRAINT `message_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`),
  CONSTRAINT `message_ibfk_2` FOREIGN KEY (`editor_id`) REFERENCES `user` (`id`),
  CONSTRAINT `message_ibfk_3` FOREIGN KEY (`thread_id`) REFERENCES `thread` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;



# Dump of table poll
# ------------------------------------------------------------

DROP TABLE IF EXISTS `poll`;

CREATE TABLE `poll` (
  `thread_id` int(10) unsigned NOT NULL,
  `question` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `locked` tinyint(1) DEFAULT '0',
  `multi_vote` tinyint(1) DEFAULT '0',
  `user_id` int(10) unsigned NOT NULL,
  `start_time` datetime NOT NULL,
  KEY `thread_id` (`thread_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `poll_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`),
  CONSTRAINT `poll_ibfk_1` FOREIGN KEY (`thread_id`) REFERENCES `thread` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;



# Dump of table poll_option
# ------------------------------------------------------------

DROP TABLE IF EXISTS `poll_option`;

CREATE TABLE `poll_option` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `text` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `poll_id` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `poll_id` (`poll_id`),
  CONSTRAINT `poll_option_ibfk_1` FOREIGN KEY (`poll_id`) REFERENCES `poll` (`thread_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;



# Dump of table poll_vote
# ------------------------------------------------------------

DROP TABLE IF EXISTS `poll_vote`;

CREATE TABLE `poll_vote` (
  `user_id` int(10) unsigned NOT NULL DEFAULT '0',
  `option_id` int(10) unsigned NOT NULL DEFAULT '0',
  `ip_address` int(10) unsigned NOT NULL DEFAULT '0',
  `timestamp` datetime NOT NULL,
  KEY `user_id` (`user_id`),
  KEY `option_id` (`option_id`),
  CONSTRAINT `poll_vote_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`),
  CONSTRAINT `poll_vote_ibfk_2` FOREIGN KEY (`option_id`) REFERENCES `poll_option` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;



# Dump of table profanity
# ------------------------------------------------------------

DROP TABLE IF EXISTS `profanity`;

CREATE TABLE `profanity` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `original_word` varchar(255) NOT NULL,
  `replacement_word` varchar(255) NOT NULL,
  `replacement_type` enum('always','whole word') NOT NULL DEFAULT 'whole word',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table quote
# ------------------------------------------------------------

DROP TABLE IF EXISTS `quote`;

CREATE TABLE `quote` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `message_id` int(10) unsigned NOT NULL,
  `message_id_quoted` int(10) unsigned NOT NULL,
  `body` text NOT NULL,
  PRIMARY KEY (`id`),
  KEY `message_id` (`message_id`),
  KEY `message_id_quoted` (`message_id_quoted`),
  CONSTRAINT `quote_ibfk_1` FOREIGN KEY (`message_id`) REFERENCES `message` (`id`),
  CONSTRAINT `quote_ibfk_2` FOREIGN KEY (`message_id_quoted`) REFERENCES `message` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='we have the body in case user edits a post after quoting';



# Dump of table rbac_permission
# ------------------------------------------------------------

DROP TABLE IF EXISTS `rbac_permission`;

CREATE TABLE `rbac_permission` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `title` varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT 'default',
  `description` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;



# Dump of table rbac_role
# ------------------------------------------------------------

DROP TABLE IF EXISTS `rbac_role`;

CREATE TABLE `rbac_role` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `posts_required` int(10) unsigned DEFAULT NULL,
  `title` varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT 'newbie',
  `image` varchar(32) COLLATE utf8_unicode_ci DEFAULT NULL,
  `color` varchar(8) COLLATE utf8_unicode_ci DEFAULT NULL,
  `special_role` tinyint(1) unsigned NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;



# Dump of table rbac_role_to_permission
# ------------------------------------------------------------

DROP TABLE IF EXISTS `rbac_role_to_permission`;

CREATE TABLE `rbac_role_to_permission` (
  `role_id` int(10) unsigned NOT NULL,
  `permission_id` int(10) unsigned NOT NULL,
  `create` tinyint(1) NOT NULL,
  `read` tinyint(1) NOT NULL,
  `update` tinyint(1) NOT NULL,
  `delete` tinyint(1) NOT NULL,
  KEY `role_id` (`role_id`),
  KEY `user_id` (`permission_id`),
  CONSTRAINT `rbac_role_to_permission_ibfk_1` FOREIGN KEY (`role_id`) REFERENCES `rbac_role` (`id`),
  CONSTRAINT `rbac_role_to_permission_ibfk_2` FOREIGN KEY (`permission_id`) REFERENCES `rbac_permission` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table rbac_role_to_user
# ------------------------------------------------------------

DROP TABLE IF EXISTS `rbac_role_to_user`;

CREATE TABLE `rbac_role_to_user` (
  `role_id` int(10) unsigned NOT NULL,
  `user_id` int(10) unsigned NOT NULL,
  PRIMARY KEY (`role_id`,`user_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `rbac_role_to_user_ibfk_1` FOREIGN KEY (`role_id`) REFERENCES `rbac_role` (`id`),
  CONSTRAINT `rbac_role_to_user_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table session
# ------------------------------------------------------------

DROP TABLE IF EXISTS `session`;

CREATE TABLE `session` (
  `id` char(72) NOT NULL DEFAULT '',
  `session_data` varchar(1024) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MEMORY DEFAULT CHARSET=utf8;



# Dump of table shoutbox
# ------------------------------------------------------------

DROP TABLE IF EXISTS `shoutbox`;

CREATE TABLE `shoutbox` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int(10) unsigned NOT NULL,
  `ip_address` varchar(15) COLLATE utf8_unicode_ci NOT NULL,
  `time` datetime NOT NULL,
  `deleted` tinyint(1) DEFAULT '0',
  `body` varchar(512) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `shoutbox_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;



# Dump of table tag
# ------------------------------------------------------------

DROP TABLE IF EXISTS `tag`;

CREATE TABLE `tag` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `title` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `url_slug` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `group_id` int(10) unsigned NOT NULL,
  `description` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `group_id` (`group_id`),
  CONSTRAINT `tag_ibfk_1` FOREIGN KEY (`group_id`) REFERENCES `taggroup` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='thread has_many tags. flags lock/sticky/deleted';



# Dump of table tagged_thread
# ------------------------------------------------------------

DROP TABLE IF EXISTS `tagged_thread`;

CREATE TABLE `tagged_thread` (
  `tag_id` int(10) unsigned NOT NULL,
  `thread_id` int(10) unsigned NOT NULL,
  PRIMARY KEY (`tag_id`,`thread_id`),
  KEY `thread_id` (`thread_id`),
  CONSTRAINT `tagged_thread_ibfk_1` FOREIGN KEY (`tag_id`) REFERENCES `tag` (`id`),
  CONSTRAINT `tagged_thread_ibfk_2` FOREIGN KEY (`thread_id`) REFERENCES `thread` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table taggroup
# ------------------------------------------------------------

DROP TABLE IF EXISTS `taggroup`;

CREATE TABLE `taggroup` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table thread
# ------------------------------------------------------------

DROP TABLE IF EXISTS `thread`;

CREATE TABLE `thread` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `subject` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `url_slug` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `icon` varchar(32) COLLATE utf8_unicode_ci DEFAULT NULL,
  `start_date` datetime NOT NULL,
  `last_updated` datetime NOT NULL,
  `started_by_user_id` int(10) unsigned NOT NULL,
  `latest_post_user_id` int(10) unsigned NOT NULL,
  `first_message_id` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `started_by_user_id` (`started_by_user_id`),
  KEY `latest_post_user_id` (`latest_post_user_id`),
  KEY `first_message_id` (`first_message_id`),
  CONSTRAINT `thread_ibfk_1` FOREIGN KEY (`started_by_user_id`) REFERENCES `user` (`id`),
  CONSTRAINT `thread_ibfk_2` FOREIGN KEY (`latest_post_user_id`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;



# Dump of table thread_read_receipt
# ------------------------------------------------------------

DROP TABLE IF EXISTS `thread_read_receipt`;

CREATE TABLE `thread_read_receipt` (
  `thread_id` int(10) unsigned NOT NULL,
  `user_id` int(10) unsigned NOT NULL,
  `datetime` datetime NOT NULL,
  KEY `thread_id` (`thread_id`),
  KEY `user_id` (`user_id`),
  KEY `datetime` (`datetime`)
) ENGINE=MEMORY DEFAULT CHARSET=utf8;



# Dump of table user
# ------------------------------------------------------------

DROP TABLE IF EXISTS `user`;

CREATE TABLE `user` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `user_name` varchar(64) COLLATE utf8_unicode_ci NOT NULL,
  `display_name` varchar(64) COLLATE utf8_unicode_ci NOT NULL,
  `real_name` varchar(64) COLLATE utf8_unicode_ci DEFAULT NULL,
  `email` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `password` varchar(64) COLLATE utf8_unicode_ci NOT NULL,
  `hide_email` tinyint(1) NOT NULL DEFAULT '0',
  `mail_notify` tinyint(1) NOT NULL DEFAULT '0',
  `stealth_login` tinyint(1) NOT NULL DEFAULT '0',
  `template` varchar(32) COLLATE utf8_unicode_ci NOT NULL DEFAULT 'default',
  `language` varchar(32) COLLATE utf8_unicode_ci NOT NULL DEFAULT 'en-GB',
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
  `avatar` varchar(32) COLLATE utf8_unicode_ci DEFAULT 'default_avatar.png',
  `usertext` varchar(255) COLLATE utf8_unicode_ci DEFAULT 'Viva La Revolution!',
  `signature` text COLLATE utf8_unicode_ci,
  `biography` text COLLATE utf8_unicode_ci,
  `gender` varchar(8) COLLATE utf8_unicode_ci DEFAULT NULL,
  `birthday` date DEFAULT NULL,
  `gmt_offset` tinyint(3) NOT NULL DEFAULT '0',
  `registration` datetime NOT NULL DEFAULT '2001-03-13 01:00:00',
  `last_online` datetime DEFAULT NULL,
  `last_ip` int(10) unsigned DEFAULT NULL,
  `post_count` int(11) unsigned NOT NULL DEFAULT '0',
  `shout_count` int(11) unsigned NOT NULL DEFAULT '0',
  `account_disabled` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `user_name` (`user_name`),
  KEY `email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;






/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
