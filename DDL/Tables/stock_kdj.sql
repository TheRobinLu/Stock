CREATE DATABASE  IF NOT EXISTS `stock` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `stock`;
-- MySQL dump 10.13  Distrib 8.0.28, for Win64 (x86_64)
--
-- Host: localhost    Database: stock
-- ------------------------------------------------------
-- Server version	8.0.28

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `kdj`
--

DROP TABLE IF EXISTS `kdj`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `kdj` (
  `code` varchar(50) NOT NULL,
  `date` datetime DEFAULT NULL,
  `dayId` int NOT NULL,
  `days` int NOT NULL,
  `period` int NOT NULL,
  `K` double DEFAULT NULL,
  `D` double DEFAULT NULL,
  `RSV` double DEFAULT NULL,
  `dkdj1` double DEFAULT NULL,
  `dkdj2` double DEFAULT NULL,
  `dkdj3` double DEFAULT NULL,
  `dkdj4` double DEFAULT NULL,
  `dkdj5` double DEFAULT NULL,
  `across` int DEFAULT NULL,
  `daysInRange` int DEFAULT NULL,
  PRIMARY KEY (`code`,`dayId`,`days`,`period`),
  KEY `ind_K` (`code`,`days`,`K`) /*!80000 INVISIBLE */,
  KEY `ind_d2` (`code`,`days`,`dkdj2`) /*!80000 INVISIBLE */,
  KEY `ind_d3` (`code`,`days`,`dkdj3`) /*!80000 INVISIBLE */,
  KEY `ind_d5` (`code`,`days`,`dkdj5`) /*!80000 INVISIBLE */,
  KEY `ind_cross` (`code`,`days`,`across`) /*!80000 INVISIBLE */,
  KEY `ind_daysinrange` (`code`,`days`,`daysInRange`),
  KEY `ind_InRangeDays` (`days`,`daysInRange`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

