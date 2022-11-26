-- stock.minprice definition

CREATE TABLE `minprice` (
  `code` varchar(50) NOT NULL,
  `minId` int DEFAULT NULL,
  `tradeTime` datetime NOT NULL,
  `openPrice` double DEFAULT NULL,
  `highPrice` double DEFAULT NULL,
  `lowPrice` double DEFAULT NULL,
  `closePrice` double DEFAULT NULL,
  `adjClose` double DEFAULT NULL,
  `Volume` double DEFAULT NULL,
  PRIMARY KEY (`code`,`tradeTime`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;