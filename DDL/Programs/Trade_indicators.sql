CREATE DEFINER=`root`@`localhost` FUNCTION `stock`.`f_deMark9`( _code varchar(10), _date datetime, _max int) RETURNS int
    DETERMINISTIC
BEGIN
 	DECLARE _number int;
    DECLARE _dayid int;
    DECLARE _cursorid int;
    DECLARE _diff real;
    
    
    SELECT Max(dayid) INTO _dayid FROM dayPrice WHERE code = _code AND date <= _date;
    SET _cursorid = _dayid;
    SET _number = 0;
  GOBACK: WHILE _cursorid > _dayid - _max DO
		
		SELECT A.closeprice - B.closeprice INTO _diff FROM dayprice A, dayprice B 
        WHERE A.code = _code AND A.code = B.code
        AND A.dayid = B.dayid + 4 AND A.dayid = _cursorid;
        
        IF _cursorid = _dayid THEN
			IF _diff > 0 THEN 
                SET _number = 1;
			ELSE
                SET _number = -1;
			END IF;
		ELSE
			IF _number > 0 AND _diff >= 0 THEN
				SET _number = _number + 1;
			ELSE
            	IF _number < 0 AND _diff <= 0 THEN
					SET _number = _number - 1;
				ELSE
					return _number;
				END IF;
            END IF;
            
		END IF;
        
        SET _cursorid = _cursorid - 1;
    END WHILE GOBACK;

RETURN _number;
END;

CREATE DEFINER=`root`@`localhost` FUNCTION `stock`.`f_initialBuyPoint`( _code varchar(10), _date datetime) RETURNS int
    DETERMINISTIC
BEGIN
 	DECLARE _number int;
    DECLARE _dayid int;
    DECLARE _daysInRange int;
    DECLARE _cursorid int;
    DECLARE _diff real;
    
     
    SELECT Min(dayid) INTO _dayid 
    FROM KDJ WHERE code = _code AND Days = 9 AND date >= _date AND daysInRange <= -5 AND dkdj2 > 0 AND dkdj5 < 0;
    
    SELECT CASE WHEN Min(dayid) > _dayid THEN _dayid ELSE Min(dayid) END INTO _dayid 
    FROM RSI WHERE code = _code AND Days = 7  AND date >= _date AND daysInRange <= -5 AND drsi2 > 0 AND drsi5 < 0;
    
    SELECT CASE WHEN Min(dayid) > _dayid THEN _dayid ELSE Min(dayid) END INTO _dayid 
    FROM demarkpoint WHERE code = _code AND date >= _date AND point  <= -8;
    
    
RETURN _dayid;
END;

CREATE DEFINER=`root`@`localhost` FUNCTION `stock`.`f_parse_rsi_trend`(_strategyName varchar(60), _parameter varchar(20)) RETURNS int
    DETERMINISTIC
BEGIN
DECLARE _temp varchar(20);
DECLARE _ret int;
SELECT CASE WHEN lower(_parameter) = 'trend' THEN  SUBSTRING_INDEX(SUBSTRING_INDEX(_strategyName, '_', 2) , '_', -1)
			WHEN lower(_parameter) = 'rsi' THEN SUBSTRING_INDEX(SUBSTRING_INDEX(_strategyName, '_', 4) , '_', -1)
			WHEN lower(_parameter) = 'drsidays' THEN SUBSTRING_INDEX(SUBSTRING_INDEX(_strategyName, '_', 5) , '_', -1)
			WHEN lower(_parameter) = 'rsidays' THEN SUBSTRING_INDEX(SUBSTRING_INDEX(_strategyName, '_', 6) , '_', -1)
            END
    INTO _temp;

SELECT CASE WHEN lower(_temp) = 'upward' THEN 1
			WHEN lower(_temp) = 'downward' THEN -1
            ELSE CAST(_temp AS UNSIGNED) END
	  INTO _ret;

RETURN _ret;
END;

CREATE DEFINER=`root`@`localhost` PROCEDURE `stock`.`p_demark9`(_ticker varchar(10))
BEGIN

 	DECLARE _prog varchar(120);
	DECLARE _Method varchar(120);
	
    DECLARE done INT DEFAULT 0;
    DECLARE _date DateTime;
	DECLARE _code varchar(10);
    DECLARE _MaxDemarkDayId INT;
    DECLARE _Cursor INT;
    DECLARE _MaxDayId INT;
    DECLARE _DemarkPoint INT;
    DECLARE _Point INT DEFAULT 0;
    DECLARE _diff REAL DEFAULT 0;
    

	DECLARE _Tickers CURSOR FOR 
	SELECT code  
	FROM equity
	WHERE code like CONCAT(_ticker, '%');
        
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET done=1;

	SET _prog = 'p_demark9start';
    SET _Method  = '';
	    
    OPEN _Tickers;
	FETCH _Tickers INTO  _code;
	REPEAT

call p_log (_prog, 'get _code', cast(_code as char(20)));
        SET _MaxDemarkDayId = 0;
        SELECT Max(dayid) INTO _MaxDemarkDayId FROM demarkpoint WHERE code = _code;
        
        SET _MaxDemarkDayId = ifnull(_MaxDemarkDayId, 0);
call p_log (_prog, 'get _MaxDemarkDayId', cast(_MaxDemarkDayId as char(20)));
        IF _MaxDemarkDayId = 0 THEN
			SET _MaxDemarkDayId = 4;
            SET _Point = 0;
		ELSE
			SELECT Max(point) INTO _Point FROM demarkpoint where code = _code AND dayid = _MaxDemarkDayId;
		END IF;
call p_log (_prog, 'get _Point', cast(_Point as char(20)));
        SET _MaxDemarkDayId = _MaxDemarkDayId + 1;
        SET _Cursor = _MaxDemarkDayId;
        SELECT Max(dayId), Max(date) INTO _MaxDayId, _date FROM dayprice WHERE code = _code;
call p_log (_prog, 'get _MaxDayId', cast(_MaxDayId as char(20)));
        LOOPING: WHILE _Cursor <= _MaxDayId DO
			SELECT A.closeprice - B.closeprice, A.date INTO _diff, _date FROM dayprice A, dayprice B 
			WHERE A.code = _code AND A.code = B.code
			AND A.dayid = B.dayid + 4 AND A.dayid = _cursor;
call p_log (_prog, 'get _diff', cast(_diff as char(200)));
            IF _Point = 0 THEN
				IF _diff >= 0 THEN
					SET _Point = 1;
				ELSE
					SET _Point = -1;
				END IF;
			ELSE
				IF _diff >= 0  THEN
					IF _Point > 0 THEN
						SET _Point = _Point + 1;
                    ELSE
						SET _Point = 1;
					END IF;
				ELSE 
					IF _Point < 0 THEN
						SET _Point = _Point - 1;
                    ELSE
						SET _Point = -1;
					END IF;
				END IF;
            END IF;
            INSERT INTO demarkpoint (code, date, dayid, point) VALUES (_code, _date, _Cursor, _Point);
            
            COMMIT;
            SET _Cursor = _Cursor + 1;

        END WHILE LOOPING;
		FETCH _Tickers INTO  _code;
	UNTIL done END REPEAT;   
    
    CLOSE _Tickers;


END;

CREATE DEFINER=`root`@`localhost` PROCEDURE `stock`.`p_ema`( _code varchar(30), _days int)
BEGIN
	DECLARE _prog varchar(120);
	DECLARE _Method varchar(120);
	DECLARE _lastEmaDayId int;
	DECLARE _origLastEmaDayId int;
	DECLARE _lastDayId int;
    DECLARE _ema real;
    DECLARE _previosEma real;
    DECLARE _previosDEma real;

	SET _prog = 'p_ema';
    SET _Method  = '';
	
    SELECT Max(dayID) INTO _lastDayId FROM dayprice WHERE code = _code;
    SELECT Max(dayID) INTO _lastEmaDayId FROM ema WHERE code = _code and days = _days;

call p_log(_prog, _Method, CONCAT('Get _lastDayId and _lastEmaDayId: ' , cast(_lastDayId as char) , ' and ' , cast(_lastEmaDayId as char) ));
    IF _lastDayId is not null THEN

		IF _lastEmaDayId is null THEN
			
			INSERT INTO ema (code, dayId, days, ema)
			SELECT _code, _days, _days, avg(closeprice) FROM dayprice WHERE code = _code and dayId <= _days LIMIT 1;
			SET _lastEmaDayId = _days;
			SET _origLastEmaDayId = _days - 1;
		ELSE
			SET _origLastEmaDayId = _lastEmaDayId;
		END IF;
		
call p_log(_prog, _Method, CONCAT('SET _origLastEmaDayId: ', cast(_origLastEmaDayId as char)));

		WHILE _lastDayId > _lastEmaDayId DO
			
			
			SELECT ema, dema INTO _previosEma, _previosDEma FROM ema WHERE code = _code and dayId = _lastEmaDayId and days = _days;
call p_log(_prog, _Method, CONCAT('GET _previosEma and _previosDEma: ', cast(_previosEma as char) , ' and ' , cast(_previosDEma as char) , 'for ' , cast(_lastEmaDayId as char)) );

			SELECT (T.closePrice - _previosEma) * 2 /(_days + 1) + _previosEma INTO _ema FROM dayprice T
			WHERE T.code = _code
			AND T.dayId = _lastEmaDayId + 1;
call p_log(_prog, _Method, CONCAT('Calculate Ema: ', cast(_ema as char) ));

			INSERT INTO ema (code, dayId, days, ema, dema, ddema)
			VALUES( _code, _lastEmaDayId + 1, _days, _ema, _ema - _previosEma, _ema - _previosEma - _previosDEma );
call p_log(_prog, _Method, CONCAT('Insert ema dema ddema to table: ', cast(_ema as char), ', ', cast(_ema - _previosEma as char) , ', ',  cast(_ema - _previosEma - _previosDEma as char) ));            
			SET _lastEmaDayId = _lastEmaDayId + 1;

		END WHILE;
    
    END IF;

END;

CREATE DEFINER=`root`@`localhost` PROCEDURE `stock`.`p_KDJ`( _code varchar(10), _days int, _period int)
BEGIN

	DECLARE _maxdayId int;
	DECLARE _maxdayIdDayPrice int;
	DECLARE _mindayIdDayPrice int;
	DECLARE _mindayId int;
	DECLARE _currDate Date;
	DECLARE _RSV real;
	DECLARE _close real;

	DECLARE _prog varchar(120);
	DECLARE _Method varchar(120);

	SET _prog = 'p_kdj';
    SET _Method  = '';

	IF _days = null THEN
		SET _days = 9;
    END IF;
	IF _period = null THEN
		SET _period = 9;
    END IF;        

	DELETE FROM kdj WHERE code = _code and days = _days and period = _period AND K is null;

	SELECT  Max(dayId) into _maxdayId
	FROM kdj WHERE code = _code and days = _days and period = _period;

call p_log(_prog, _Method, CONCAT('Get _maxdayId: ' , ifnull(cast(_maxdayId as char), 'NULL') ));

	SELECT Max(dayId), min(dayId) into _maxdayIdDayPrice, _mindayIdDayPrice
	FROM dayprice WHERE code = _code;
call p_log(_prog, _Method, CONCAT('Get _maxdayIdDayPrice: ' , ifnull(cast(_maxdayIdDayPrice as char), 'NULL') ));

	IF _maxdayId is null THEN
		SET  _mindayId = _mindayIdDayPrice + _days + 1 ;

		SELECT  date,  closeprice INTO _currDate, _close FROM dayprice WHERE code = _code AND dayId = _mindayId ;
call p_log(_prog, _Method, CONCAT('Get _currDate and _close: ' , ifnull(cast(_currDate as char), 'NULL'), ifnull(cast(_close as char),'NULL' )));

		SELECT if(max(highprice) = min(lowprice), 100,  (_close - min(lowprice))/(max(highprice)- min(lowprice)) * 100) INTO _RSV
		FROM dayprice
		WHERE   code = _code AND dayId between _mindayId - _days and _mindayId;

		INSERT INTO kdj(code, date, dayId, days, period, K, D, RSV)
		SELECT _code,
			_currDate,
			_mindayId,
			_days,
			_period,
			50 * 2/3 + _RSV /3,
			50 * 2/3 + (50 * 2/3 + _RSV /3)/3,
			 _RSV
		FROM dayprice A
		WHERE A.code = _code
		AND A.dayId =  _mindayId;
		SET _maxdayId = _mindayId;

	END IF;


	WHILE _maxdayId <  _maxdayIdDayPrice DO
		SET _maxdayId = _maxdayId + 1;
		SELECT date , closeprice INTO _currDate, _close FROM dayprice WHERE code = _code AND dayId = _maxdayId;
		SELECT if(max(highprice) = min(lowprice), 100,  (_close - min(lowprice))/(max(highprice)- min(lowprice)) * 100)  INTO  _RSV
		FROM dayprice
		WHERE   code = _code AND dayId between _maxdayId - _days and _maxdayId;

		INSERT INTO kdj(code, date, dayId, days, period, K, D, RSV)
		SELECT _code,
			_currDate,
			_maxdayId,
			_days,
			_period,
			R.K * 2/3 + _RSV /3,
			R.D * 2/3 + (R.K * 2/3 + _RSV /3)/3, _RSV
		FROM dayprice A, kdj R
		WHERE A.code = _code
		AND A.code = R.code
		AND A.dayId = R.dayId + 1
		AND A.dayId = _maxdayId
		AND R.days = _days
		AND R.period = _period;

	END WHILE;
    
    UPDATE kdj A, kdj B
    SET A.dKDJ1 = A.K - B.K
    WHERE A.code = B.code
    AND A.code = _code
    AND A.days = B.days
    AND A.dayid = B.dayid + 1
    AND  A.dKDJ1 is null;
 
 call p_log(_prog, _Method, 'Update dKD2');
    UPDATE kdj A, kdj B
    SET A.dKDJ2 = (A.K - B.K)/2
    WHERE A.code = B.code
    AND A.code = _code
    AND A.days = B.days
    AND A.dayid = B.dayid + 2
    AND  A.dKDJ2 is null
    ;
    
  call p_log(_prog, _Method, 'Update dKD3');   
    UPDATE kdj A, kdj B
    SET A.dKDJ3 =(A.K - B.K)/3
    WHERE A.code = B.code
    AND A.code = _code
    AND A.dayid = B.dayid + 3
    AND A.days = B.days
    AND A.dKDJ3 is null
    ;
    
    UPDATE kdj A, kdj B
    SET A.dKDJ4 = (A.K - B.K)/4
    WHERE A.code = B.code
    AND A.code = _code
    AND A.days = B.days
    AND A.dayid = B.dayid + 4
    AND  A.dKDJ4 is null
    ;
    
 call p_log(_prog, _Method, 'Update dKD5');    
    UPDATE kdj A, kdj B
    SET A.dKDJ5 = (A.K - B.K)/5
    WHERE A.code = B.code
    AND A.code = _code
    AND A.dayid = B.dayid + 5
    AND A.days = B.days
    AND A.dKDJ5 is null
     ;
 call p_log(_prog, _Method, 'Update aCross'); 
 
    UPDATE kdj A, kdj B
    SET A.across = if (A.K > A.D AND B.K < B.D, 1, if(A.K < A.D AND B.K > B.D, -1, 0))
    WHERE A.code = B.code
    AND A.code = _code
    AND A.dayid = B.dayid + 1
    AND A.days = B.days
    AND A.across is null;
    
    
END;

CREATE DEFINER=`root`@`localhost` PROCEDURE `stock`.`p_kdj_range`(_equity varchar(20))
BEGIN


    DECLARE _prog varchar(120);
	DECLARE _Method varchar(120);
	DECLARE _done INT DEFAULT 0;	
    
    DECLARE _upperK real;
	DECLARE _upperD real;
	DECLARE _lowerK real;
	DECLARE _lowerD real;
    DECLARE _upperK_recent real;
	DECLARE _upperD_recent real;
	DECLARE _lowerK_recent real;
	DECLARE _lowerD_recent real;
    
    DECLARE _upperKAll real;
	DECLARE _upperDAll real;
	DECLARE _lowerKAll real;
	DECLARE _lowerDAll real;
	DECLARE _count int;
    DECLARE _days int;
    DECLARE _period int;
    DECLARE _10percent int;
    DECLARE _maxdayid int;
    DECLARE _weight int;
    
    DECLARE _code varchar(20);
    
    DECLARE _KDJ CURSOR FOR 
	SELECT distinct code, days, period   
	FROM kdj
    WHERE _equity = 'All' OR _equity = code ;
    
    DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET _done=1;
    
    SET _prog = 'p_kdj_range';
    SET _Method  = '';
    
    SELECT count(*) INTO _count from kdj;	
    SET _10percent = _count / 10;
    
    DROP TEMPORARY TABLE IF EXISTS _temp;
	create temporary table _temp (indicator real);
    
    INSERT INTO _temp
    SELECT kdj.K  
    FROM kdj order by K desc LIMIT _10percent;
    SELECT min(indicator) into _UpperKAll FROM _temp;
    
    TRUNCATE TABLE _temp;
    INSERT INTO _temp
    SELECT kdj.K  
    FROM kdj order by K LIMIT _10percent;    
    SELECT Max(indicator) into _lowerKAll FROM _temp;
    
    TRUNCATE TABLE _temp;
    INSERT INTO _temp
    SELECT kdj.D  
    FROM kdj order by D desc LIMIT _10percent;
    SELECT min(indicator) into _UpperDAll FROM _temp;
    
    TRUNCATE TABLE _temp;
    INSERT INTO _temp
    SELECT kdj.D  
    FROM kdj order by D LIMIT _10percent;    
    SELECT Max(indicator) into _lowerDAll FROM _temp;
    
    SELECT _count, _10percent, _UpperKAll, _LowerKAll, _UpperDAll, _lowerDAll;

    OPEN _KDJ;

	REPEAT
		FETCH _KDJ INTO  _code, _days, _period;
        
        SELECT count(*), max(dayid)  INTO _count, _maxdayid from kdj WHERE code = _code and days = _days and period = _period;	
		SET _10percent = _count / 10;
		
        IF _count < 500 THEN
			SET _weight = _count;
		ELSE
			SET _weight = 500;
        END IF;
        
        TRUNCATE TABLE _temp;
		INSERT INTO _temp
		SELECT kdj.K  
		FROM kdj WHERE code = _code and days = _days and period = _period order by K desc LIMIT _10percent;
		SELECT min(indicator) into _UpperK FROM _temp;
        
        TRUNCATE TABLE _temp;
		INSERT INTO _temp
		SELECT kdj.K  
		FROM kdj WHERE code = _code and days = _days and period = _period and dayid > _maxdayid - 500 order by K desc LIMIT 50;
		SELECT min(indicator) into _UpperK_recent FROM _temp;
        
        SET _UpperK = (_UpperK + _UpperK_recent) / 2;
		
		TRUNCATE TABLE _temp;
		INSERT INTO _temp
		SELECT kdj.K  
		FROM kdj WHERE code = _code and days = _days and period = _period order by K LIMIT _10percent;    
		SELECT Max(indicator) into _lowerK FROM _temp;
		
		TRUNCATE TABLE _temp;
		INSERT INTO _temp
		SELECT kdj.K  
		FROM kdj WHERE code = _code and days = _days and period = _period and dayid > _maxdayid - 500 order by K LIMIT 50;    
		SELECT Max(indicator) into _lowerK_recent FROM _temp; 
        
        SET _lowerK = (_lowerK + _lowerK_recent) / 2;       
        
		TRUNCATE TABLE _temp;
		INSERT INTO _temp
		SELECT kdj.D  
		FROM kdj WHERE code = _code and days = _days and period = _period order by D desc LIMIT _10percent;
		SELECT min(indicator) into _UpperD FROM _temp;
        
        TRUNCATE TABLE _temp;
		INSERT INTO _temp
		SELECT kdj.D  
		FROM kdj WHERE code = _code and days = _days and period = _period and dayid > _maxdayid - 500 order by D desc LIMIT 50;  
		SELECT min(indicator) into _UpperD_recent FROM _temp;
        
        SET _UpperD = (_UpperD + _UpperD_recent) / 2;  
		
		TRUNCATE TABLE _temp;
		INSERT INTO _temp
		SELECT kdj.D  
		FROM kdj WHERE code = _code and days = _days and period = _period order by D LIMIT _10percent;    
		SELECT Max(indicator) into _lowerD FROM _temp;

		TRUNCATE TABLE _temp;
		INSERT INTO _temp
		SELECT kdj.D  
		FROM kdj WHERE code = _code and days = _days and period = _period and dayid > _maxdayid - 500 order by D LIMIT 50;    
		SELECT Max(indicator) into _lowerD_recent FROM _temp;
        
        SET _lowerD = (_lowerD + _lowerD_recent) / 2;  

        IF _UpperK > _UpperKAll THEN
			SET _UpperK = (_UpperK * _weight + _UpperKAll * (1000 - _weight))/1000;
        END IF;

        IF _LowerK < _LowerKAll THEN
			SET _LowerK = (_LowerK * _weight + _LowerKAll* (1000 - _weight))/1000;
        END IF;
        
        IF _UpperD > _UpperDAll THEN
			SET _UpperD = (_UpperD * _weight + _UpperDAll* (1000 - _weight))/1000;
        END IF;

        IF _LowerD < _LowerDAll THEN
			SET _LowerD = (_LowerD * _weight + _LowerDAll* (1000 - _weight))/1000;
        END IF;
        
        IF exists (SELECT 1 FROM kdj_range WHERE code = _code and days = _days and period = _period ) THEN
			DELETE FROM kdj_range WHERE code = _code and days = _days and period = _period;
        END IF;
		INSERT kdj_range (code, days, period, low_K, low_D, upper_K, upper_D, UpdateOn)
        VALUES (_code, _days, _period, _lowerK, _lowerD, _upperK, _upperD, SYSDATE());
        
        IF _days = 9 and _code like '%S%' THEN
			SELECT _code, _days, _period, _lowerK, _lowerD, _upperK, _upperD;
        END IF;
        Commit;

    UNTIL _done END REPEAT;   
    
    CLOSE _KDJ;

END;

CREATE DEFINER=`root`@`localhost` PROCEDURE `stock`.`p_log`(_program varchar(120), _method varchar(120), _comments varchar(2000))
BEGIN
	DECLARE _debug int;
    SET _debug = 1; 
    IF _debug = 1 THEN
		INSERT INTO log (program, method, comments, timestampe)
		VALUES (_program, _method, _comments, now());
	END IF;

END;

CREATE DEFINER=`root`@`localhost` PROCEDURE `stock`.`p_obv`( _code varchar(50))
BEGIN
	DECLARE _dayId int;
	DECLARE _maxDayId int;
	DECLARE _obv real;
    DECLARE _sign int;
    
    SELECT Max(dayId)INTO _dayId FROM obv WHERE code = _code;
    SELECT Max(dayId)INTO _maxDayId FROM dayprice WHERE code = _code;
    
	If _dayId is null THEN
		SET _dayId = 100;
        
        INSERT INTO obv (code, date, dayId, OBV )
        SELECT code, date, dayId, Volume / avgVolumn
        FROM dayprice, (SELECT avg(Volume) as avgVolumn 
						FROM dayprice 
                        WHERE code = _code
                        AND dayId between _dayId - 99 AND _dayId) AS A
		WHERE code = _code
        AND dayId = _dayId;

	END IF;
    SET _dayId = _dayId + 1;    
Days: WHILE _dayId <= _maxDayId DO  
        
        INSERT INTO obv (code, date, dayId, OBV )
        SELECT code, date, dayId, Volume / avgVolumn
        FROM dayprice, (SELECT avg(Volume) as avgVolumn 
						FROM dayprice 
                        WHERE code = _code
                        AND dayId between _dayId - 99 AND _dayId) AS A
		WHERE code = _code
        AND dayId = _dayId;
        
        SELECT CASE WHEN B.closePrice > A.closePrice THEN -1 
					WHEN B.closePrice = A.closePrice THEN 0
					WHEN B.closePrice < A.closePrice THEN 1 END
				INTO _sign
		FROM dayprice A, dayprice B
        WHERE A.code = _code
        AND A.code = B.code
        AND A.dayId = B.dayId + 1
        AND A.dayId = _dayId;
                    
        UPDATE obv A, obv B
        SET A.OBV = B.OBV + _sign * A.OBV
        WHERE A.code = _code
        AND A.code = B.code
        AND A.dayId = B.dayId + 1
        AND A.dayId = _dayId;

        SET _dayId = _dayId + 1;
END WHILE Days;


END;

CREATE DEFINER=`root`@`localhost` PROCEDURE `stock`.`p_RSI`( _code varchar(10), _days int)
BEGIN
	DECLARE _maxdayId int;
	DECLARE _maxdayIddayprice int;
	DECLARE _mindayId int;
	DECLARE _currDate Date;
	DECLARE _EMAWeight real;
	
	DELETE FROM rsi WHERE code = _code and days = _days and RSI is null;
	
	SELECT Max(dayId) INTO _maxdayId
	FROM rsi WHERE code = _code and days = _days;

	SELECT Max(dayId) INTO _maxdayIddayprice
	FROM dayprice WHERE code = _code;



	IF _maxdayId is null THEN
		SET  _mindayId = _days + 1 ;

		SELECT date into _currDate FROM dayprice WHERE code = _code AND dayId = _mindayId;
		
		INSERT INTO rsi (code, date, dayId, days, U, D)
		SELECT _code, 
			_currDate,
			_mindayId,
			_days,
			SUM((A.closePrice - B.closePrice) * (IF( A.closePrice > B.closePrice,1, 0 )))/_days,
			SUM((B.closePrice - A.closePrice) * (IF( A.closePrice < B.closePrice, 1 , 0 )))/_days
		FROM dayprice A, dayprice B 
		WHERE A.dayId = B.dayId + 1  
		AND A.code = B.code
		AND A.code = _code
		AND A.dayId between  _mindayId - _days + 1  AND  _mindayId;

		
		UPDATE rsi
		SET RSI = 100 * U/ (U + D) 
		WHERE code = _code 
		AND dayId = _mindayId
		AND Days = _days;

		SET _maxdayId = _mindayId;

	END IF;

	SET _EMAWeight = 2/(cast(_days as real) + 1);
	SET _EMAWeight = 1/cast(_days as real);

	WHILE _maxdayId <  _maxdayIddayprice DO
		SET _maxdayId = _maxdayId + 1;

		SELECT date INTO _currDate FROM dayprice WHERE code = _code AND dayId = _maxdayId;
			
		INSERT INTO rsi (code, date, dayId, days, U, D)
		SELECT _code,
			_currDate,
			_maxdayId,
			_days,
			(IF( A.closePrice > B.closePrice, (A.closePrice - B.closePrice), 0)  * _EMAWeight + R.U * (1 - _EMAWeight )) , 
			(IF( A.closePrice < B.closePrice, (B.closePrice - A.closePrice), 0)  * _EMAWeight + R.D * (1 - _EMAWeight )) 
		FROM dayprice A, dayprice B , rsi R
		WHERE A.code = B.code
		AND A.code = _code
		AND A.code = R.code
		AND A.dayId = B.dayId + 1  
		AND B.dayId = R.dayId
		AND A.dayId = _maxdayId
		AND R.days = _days;

	END WHILE;


	UPDATE rsi
	SET RSI = 100 * U/ (U + D) 
	WHERE code = _code 
	AND dayId is not null
	AND Days = _days;
	
    UPDATE rsi A, rsi B
    SET A.dRSI1 = A.RSI - B.RSI
    WHERE A.code = B.code
    AND A.code = _code
    AND A.days = B.days
    AND A.dayid = B.dayid + 1
    AND A.dRSI1 is null;
    
    UPDATE rsi A, rsi B
    SET A.dRSI2 = (A.RSI - B.RSI) / 2
    WHERE A.code = B.code
    AND A.code = _code
    AND A.days = B.days
    AND A.dayid = B.dayid + 2
    AND A.dRSI2 is null;
    
    
    UPDATE rsi A, rsi B
    SET A.dRSI3 = (A.RSI - B.RSI) / 3
    WHERE A.code = B.code
    AND A.code = _code
    AND A.dayid = B.dayid + 3
    AND A.days = B.days
    AND A.dRSI3 is null;
    
    UPDATE rsi A, rsi B
    SET A.dRSI4 = (A.RSI - B.RSI) / 4
    WHERE A.code = B.code
    AND A.code = _code
    AND A.days = B.days
    AND A.dayid = B.dayid + 4
    AND A.dRSI4 is null;
    
    UPDATE rsi A, rsi B
    SET A.dRSI5 = (A.RSI - B.RSI) / 5
    WHERE A.code = B.code
    AND A.code = _code
    AND A.dayid = B.dayid + 5
    AND A.days = B.days 
    AND A.dRSI5 is null;    

END;

CREATE DEFINER=`root`@`localhost` PROCEDURE `stock`.`p_rsi_range`()
BEGIN






    DECLARE _prog varchar(120);
	DECLARE _Method varchar(120);
	DECLARE _done INT DEFAULT 0;	
    
    DECLARE _upperRSI real;
	DECLARE _lowerRSI real;
    DECLARE _upperRSI_recent real;
	DECLARE _lowerRSI_recent real;
    DECLARE _upperAll real;
	DECLARE _lowerAll real;
	DECLARE _count int;
    DECLARE _days int;
    DECLARE _10percent int;
    DECLARE _maxdayid int;
    
    DECLARE _code varchar(20);
    
    DECLARE _RSI CURSOR FOR 
	SELECT distinct code, days  
	FROM rsi;
    
    DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET _done=1;
    
    SET _prog = 'p_rsi_range';
    SET _Method  = '';
    
    SELECT count(*) INTO _count from rsi;	
    SET _10percent = _count * 0.05;
    
    DROP TEMPORARY TABLE IF EXISTS _temp;
	create temporary table _temp (indicator real);
    
    INSERT INTO _temp
    SELECT RSI
    FROM rsi order by RSI desc LIMIT _10percent;
    SELECT min(indicator) into _UpperAll FROM _temp;
    
    TRUNCATE TABLE _temp;
    INSERT INTO _temp
    SELECT RSI  
    FROM rsi order by RSI LIMIT _10percent;    
    SELECT Max(indicator) into _lowerAll FROM _temp;
  
    SELECT _count, _10percent, _UpperAll, _LowerAll;

	TRUNCATE TABLE rsi_range;
    
    OPEN _RSI;

	REPEAT
		FETCH _RSI INTO  _code, _days;
        
        SELECT count(*), max(dayid) INTO _count, _maxdayid from rsi WHERE code = _code and days = _days;	
		SET _10percent = _count * 0.05;
       
        TRUNCATE TABLE _temp;
		INSERT INTO _temp
		SELECT RSI  
		FROM rsi WHERE code = _code and days = _days order by RSI desc LIMIT _10percent;
		SELECT min(indicator) into _UpperRSI FROM _temp;
        
        TRUNCATE TABLE _temp;
		INSERT INTO _temp
		SELECT RSI  
		FROM rsi WHERE code = _code and days = _days and dayid > _maxdayid - 500  order by RSI desc LIMIT 30;
		SELECT min(indicator) into _UpperRSI_recent FROM _temp;
        
        SET _UpperRSI = (_UpperRSI + _UpperRSI_recent) / 2;
 		
		TRUNCATE TABLE _temp;
		INSERT INTO _temp
		SELECT RSI  
		FROM rsi WHERE code = _code and days = _days order by RSI LIMIT _10percent;    
		SELECT Max(indicator) into _lowerRSI FROM _temp;
        
 		TRUNCATE TABLE _temp;
		INSERT INTO _temp
		SELECT RSI  
		FROM rsi WHERE code = _code and days = _days and dayid > _maxdayid - 500 order by RSI LIMIT 30;    
		SELECT Max(indicator) into _lowerRSI_recent FROM _temp;       
        
        SET _lowerRSI = (_lowerRSI + _lowerRSI_recent) / 2;
        
		IF _UpperRSI > _UpperAll THEN
			SET _UpperRSI = (_UpperRSI + _UpperAll)/2;
        END IF;

        IF _LowerRSI < _LowerAll THEN
			SET _LowerRSI = (_LowerRSI + _LowerAll)/2;
        END IF;
        

        IF _days = 7 and _code like '%E%' THEN
			SELECT _code, _days,  _lowerRSI, _lowerRSI_recent, _upperRSI, _UpperRSI_recent ;
        END IF;
		INSERT rsi_range (code, days,  lower_RSI, upper_RSI)
        VALUES (_code, _days,  _lowerRSI,  _upperRSI);
        
        Commit;

    UNTIL _done END REPEAT;   
    
    CLOSE _RSI;

END;

CREATE DEFINER=`root`@`localhost` PROCEDURE `stock`.`p_scripts`(_script varchar(100))
BEGIN
	DECLARE _rows int;
    DECLARE _parameter1 varchar(90);
    DECLARE _parameter2 varchar(90);
    DECLARE _parameter3 varchar(90);
    DECLARE _intP1 int;
    DECLARE _intP2 int;
    DECLARE _intP3 int;
    DECLARE _realP4 real;
	DECLARE _realP5 real;
	DECLARE _realP6 real;
    DECLARE _maxDay date;
    
    DECLARE _done INT DEFAULT 0;	


    DECLARE _Strategy CURSOR FOR 
	SELECT id, StrategyName, ForBuySale, rate, intP1, intP2,intP3,realP4,realP5,realP6
	FROM recommendstrategy ;
    
    

    
    DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET _done=1;  

	IF _script = 'DeleteKDJ' THEN
		SET _rows = 1;
    
		WHILE _rows > 0 DO
			IF EXISTS (SELECT 1 FROM kdj WHERE days in (5,14, 19,36,45,73) LIMIT 10 ) THEN
				START TRANSACTION;
					DELETE FROM kdj WHERE days in (5,14, 19,36,45,73) LIMIT 10000;
                COMMIT;
			ELSE
				SET _rows = 0;
			END IF;
        END WHILE;
        
		SET _rows = 1;
        
		WHILE _rows > 0 DO
			IF EXISTS (SELECT 1 FROM kdj_range WHERE days in (5,14, 19,36,45,73) LIMIT 10 ) THEN
				DELETE FROM kdj_range WHERE days in (5,14, 19,36,45,73) LIMIT 10000;
			ELSE
				SET _rows = 0;
			END IF;
        END WHILE;        
    END IF;

    IF _script like 'FIndSP%' THEN
		
		SELECT   SUBSTRING_INDEX(SUBSTRING_INDEX(_script, ';', 2), ';', -1) INTO _parameter1;
        SELECT _parameter1, CONCAT('%', _parameter1, '%');
		select ROUTINE_NAME, ROUTINE_TYPE, ROUTINE_DEFINITION 
		from information_schema.ROUTINES 
		where ROUTINE_DEFINITION like CONCAT('%', _parameter1, '%');
    END IF;


	IF _script like 'recommend%' THEN
		call p_recomm_all (CURRENT_DATE());
    END IF;


	IF _script like 'KDJGrow%' THEN
		
		SET  _parameter1 = SUBSTRING_INDEX(SUBSTRING_INDEX(_script, ';', 2), ';', -1);
        SELECT KDJ.*, Up.Earn FROM KDJ, (SELECT A.dayid, Max(((B.highPrice + B.closePrice)/2)/A.closeprice) as Earn FROM dayprice A, dayprice B 
							WHERE A.code = B.code
							AND B.dayid between A.dayid + 3 and A.dayid + 7 
							AND A.Code = _parameter1
							Group by A.dayId
							having Max(((B.highPrice + B.closePrice)/2)/A.closeprice) > 1.10) AS Up
        
        WHERE code = _parameter1
        AND days = 9 
        AND KDJ.dayid = Up.dayId;
	END IF;


	IF _script like 'KDJDropw%' THEN
		
		SET  _parameter1 = SUBSTRING_INDEX(SUBSTRING_INDEX(_script, ';', 2), ';', -1);
        SELECT KDJ.*, Up.Loss FROM KDJ, (SELECT A.dayid, Min(((B.lowPrice + B.closePrice)/2)/A.closeprice) as Loss FROM dayprice A, dayprice B 
							WHERE A.code = B.code
							AND B.dayid between A.dayid + 3 and A.dayid + 7 
							AND A.Code = _parameter1
							Group by A.dayId
							having Min(((B.lowPrice + B.closePrice)/2)/A.closeprice) < 0.95) AS Up
        
        WHERE code = _parameter1
        AND days = 9 
        AND KDJ.dayid = Up.dayId;
	END IF;

	IF _script like 'DailyMap' THEN
		call p_analysis_mapped_rsi('ARKK', null);
		call p_analysis_mapped_rsi('FOOD', null);
		call p_analysis_mapped_rsi('WELL', null);
		call p_analysis_mapped_rsi('SHOPT', null);
		call p_analysis_mapped_rsi('PLTR', null);
		call p_analysis_mapped_rsi('FSLY', null);
		call p_analysis_mapped_rsi('LSPDT', null);
    
    END IF;
    
    IF _script like 'DemarkMap' THEN
		SELECT D.code, D.date, D.dayid, p.ClosePrice, D.point, E.ema, E.dema/E.ema, E.ddema/E.ema  FROM DayPrice P, EMA E,
		(SELECT DP.code, DP.date, DP.dayid, DP.point  
        FROM demarkpoint DP, (SELECT Max(dayid) as dayid, code  FROM dayprice GROUP BY code ) M
        WHERE DP.code = M.code AND DP.dayid  = M.Dayid
        AND abs(DP.point) > 7) D
        WHERE P.code = D.code AND P.code = E.code
        AND P.dayid = D.dayid AND P.dayid = E.dayid
        AND E.days = 3
        Order by D.point;
        
	END IF;
    
    IF _script like 'Extract' THEN
		INSERT INTO equity_perform
		SELECT code, dayId, buySale, Max(high4),Max(low4),Max(above4),Max(below4),
			Max(high7),Max(low7),Max(above7),Max(below7),Max(high12),Max(low12),
			Max(above12),Max(below12),Max(createAt) 
		FROM strategy_test T
		WHERE NOT EXISTS (SELECT 1 FROM equity_perform P 
							WHERE T.code = P.code and T.dayId = P.dayId and T.buySale = P.buySale)
		GROUP BY code, dayId, buySale limit 5000;
	END IF;
END;

CREATE DEFINER=`root`@`localhost` PROCEDURE `stock`.`p_set_all_kdj_daysInRange`(_reset int)
BEGIN
    DECLARE _prog varchar(120);
	DECLARE _Method varchar(120);
	DECLARE _done INT DEFAULT 0;	
    
    DECLARE _code varchar(20);
    
    
    
    DECLARE _Ticker CURSOR FOR 
	SELECT code   
	FROM equity ;
    
    DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET _done=1;  
    
	SET _prog = 'p_set_all_kdj_daysInRange';
    SET _Method  = '';
    
    OPEN _Ticker;
	REPEAT    
		FETCH _Ticker INTO   _code;
        
        call p_set_kdj_daysInRange (_code, _reset);
        

    
    UNTIL _done END REPEAT;   
    
    CLOSE _Ticker;    

END;

CREATE DEFINER=`root`@`localhost` PROCEDURE `stock`.`p_set_all_rsi_daysInRange`(_reset int)
BEGIN
    DECLARE _prog varchar(120);
	DECLARE _Method varchar(120);
	DECLARE _done INT DEFAULT 0;	
    
    DECLARE _code varchar(20);
    DECLARE _Ticker CURSOR FOR 
	SELECT code   
	FROM equity ;
    
    DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET _done=1;  
    
	SET _prog = 'p_set_all_rsi_daysInRange';
    SET _Method  = '';
    
    OPEN _Ticker;
	REPEAT    
		FETCH _Ticker INTO   _code;
        
        call p_set_rsi_daysInRange (_code, _reset);
        

    
    UNTIL _done END REPEAT;   
    
    CLOSE _Ticker;    

END;

CREATE DEFINER=`root`@`localhost` PROCEDURE `stock`.`p_set_kdj_daysInRange`(_code varchar(20), _reset int)
BEGIN






    DECLARE _prog varchar(120);
	DECLARE _Method varchar(120);
	DECLARE _done INT DEFAULT 0;	
    
    DECLARE _upperK real;
	DECLARE _lowerK real;
    DECLARE _upperD real;
	DECLARE _lowerD real;
    DECLARE _days int;
    DECLARE _backDays int default 20 ;
    DECLARE _mindayid int;
    DECLARE _maxdayid int;
    DECLARE _inrangedays int;
    DECLARE _period int;
    
    
    
    DECLARE _kdj_range CURSOR FOR 
	SELECT days,period, low_K, upper_K, low_D, upper_D   
	FROM kdj_range WHERE code = _code;
    
    DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET _done=1;  
    
	SET _prog = 'p_set_kdj_daysInRange';
    SET _Method  = '';
    
    OPEN _kdj_range;
	REPEAT    
		FETCH _kdj_range INTO   _days, _period, _lowerK, _upperK, _lowerD, _upperD;
        
        IF _reset = 1 THEN
            UPDATE kdj
            SET daysInRange = null
            WHERE code = _code and days = _days AND period = _period ;
			
        END IF;
        
        SELECT min(dayid), max(dayid) INTO _mindayid, _maxdayid FROM kdj WHERE code = _code AND days = _days and period = _period and daysInRange is null;
        
        WHILE _mindayid <=  _maxdayid DO
			SET _inrangedays = 0;
            IF EXISTS (SELECT 1 FROM kdj WHERE code = _code AND dayid = _mindayid AND days = _days and period = _period AND K <= _lowerK) THEN
				SELECT count(*) INTO _inrangedays  FROM kdj A
				WHERE A.code = _code AND A.days = _days AND A.period = _period
				AND A.dayID between _mindayid - _backDays and _mindayid
                AND A.K <= _lowerK;
                
                SET _inrangedays = _inrangedays * (-1);
                
            ELSEIF EXISTS (SELECT 1 FROM kdj WHERE code = _code AND dayid = _mindayid AND days = _days and period = _period AND K >= _upperK) THEN
            
				SELECT count(*) INTO _inrangedays  FROM kdj A
				WHERE A.code = _code AND A.days = _days AND A.period = _period
				AND A.dayID between _mindayid - _backDays and _mindayid
                AND A.K >= _upperK;
			END IF;
            
            UPDATE kdj
            SET daysInRange = _inrangedays
            WHERE code = _code and days = _days AND period = _period
            AND dayid = _mindayid;
            
            Commit;
            SET _mindayid = _mindayid + 1;
        END WHILE;
    
    UNTIL _done END REPEAT;   
    
    CLOSE _kdj_range;    

END;

CREATE DEFINER=`root`@`localhost` PROCEDURE `stock`.`p_set_rsi_daysInRange`(_code varchar(20), _reset int)
BEGIN





    DECLARE _prog varchar(120);
	DECLARE _Method varchar(120);
	DECLARE _done INT DEFAULT 0;	
    
    DECLARE _upperRSI real;
	DECLARE _lowerRSI real;
						 
					  
    DECLARE _days int;
    DECLARE _backDays int default 20 ;
    DECLARE _mindayid int;
    DECLARE _maxdayid int;
    DECLARE _inrangedays int;
						
    
    
    
    DECLARE _rsi_range CURSOR FOR 
	SELECT days, lower_RSI, upper_RSI  
	FROM rsi_range WHERE code = _code;
    
    DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET _done=1;  
    
	SET _prog = 'p_rsi_daysInRange';
    SET _Method  = '';
    
    OPEN _rsi_range;
	REPEAT    
		FETCH _rsi_range INTO   _days, _lowerRSI, _upperRSI;
        
        IF _reset = 1 THEN
            UPDATE rsi
            SET daysInRange = null
            WHERE code = _code and days = _days ;
			
        END IF;       
		
		SELECT min(dayid), max(dayid) INTO _mindayid, _maxdayid FROM rsi WHERE code = _code AND days = _days and daysInRange is null;
        
        WHILE _mindayid <=  _maxdayid DO
			SET _inrangedays = 0;
            IF EXISTS (SELECT 1 FROM rsi WHERE code = _code AND dayid = _mindayid AND RSI <= _lowerRSI) THEN
				SELECT (-1) * count(*) INTO _inrangedays  FROM rsi A 
				WHERE A.code = _code AND A.days = _days 
				AND A.dayID between _mindayid - _backDays and _mindayid
                AND A.RSI <= _lowerRSI;
				
            ELSEIF EXISTS (SELECT 1 FROM rsi WHERE code = _code AND dayid = _mindayid AND RSI >= _upperRSI) THEN
				SELECT count(*) INTO _inrangedays  FROM rsi A 
				WHERE A.code = _code AND A.days = _days 
				AND A.dayID between _mindayid - _backDays and _mindayid
                AND A.RSI >= _upperRSI;
            
			END IF;
            
            UPDATE rsi
            SET daysInRange = _inrangedays
            WHERE code = _code and days = _days
            AND dayid = _mindayid;
            
			 Commit;	   
            SET _mindayid = _mindayid + 1;
        END WHILE;
    
    UNTIL _done END REPEAT;   
    
    CLOSE _rsi_range;    

END;
