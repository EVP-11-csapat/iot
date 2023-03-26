/* 
Az adott gyár szerkezeti felípétése: 
- 1 db gyár -> 3 section
	- 1. section -> 2 elszívó - kompresszor				- 1. section -> 3 elszívó - kompresszor				- 1. section -> 1 elszívó - kompresszor
			-1. elszívó -> 4 gép							-1. elszívó -> 1 gép								-1. elszívó -> 8 gép
            -2. elszívó -> 3 gép							-2. elszívó -> 2 gép								
															-3. elszívó -> 3 gép
*/
use FactorySummary;

insert into Factory (ID)
values(1);

insert into Section (factoryID)
values(1);
insert into Section (factoryID)
values(1);
insert into Section (factoryID)
values(1);

DELIMITER //
CREATE FUNCTION insertMachines()
RETURNS INT
BEGIN
  DECLARE a INT;
  SET a = 10;
  test:
  WHILE a < 40 DO
	INSERT INTO Machine (SectionID) VALUES(FLOOR(a/10));
    SET a = a + 1;
  END WHILE test;
  RETURN 1;
END; //
DELIMITER ;

select insertMachines();

SELECT * from machine;

/*Section 1*/
insert into Absorbent(ID)
values(1);
insert into Absorbent(ID)
values(2);

insert into ProductionMachine(ID,AbsorbentID)
values(3,1);
insert into ProductionMachine(ID,AbsorbentID)
values(4,1);
insert into ProductionMachine(ID,AbsorbentID)
values(5,1);
insert into ProductionMachine(ID,AbsorbentID)
values(6,1);
insert into ProductionMachine(ID,AbsorbentID)
values(7,2);
insert into ProductionMachine(ID,AbsorbentID)
values(8,2);
insert into ProductionMachine(ID,AbsorbentID)
values(9,2);

insert into Compressor(ID)
values(10);

/*Section 2*/
insert into Absorbent(ID)
values(11);
insert into Absorbent(ID)
values(12);
insert into Absorbent(ID)
values(13);

insert into ProductionMachine(ID,AbsorbentID)
values(14,11);
insert into ProductionMachine(ID,AbsorbentID)
values(15,12);
insert into ProductionMachine(ID,AbsorbentID)
values(16,12);
insert into ProductionMachine(ID,AbsorbentID)
values(17,13);
insert into ProductionMachine(ID,AbsorbentID)
values(18,13);
insert into ProductionMachine(ID,AbsorbentID)
values(19,13);

insert into Compressor(ID)
values(20);

/*Section 3*/
insert into Absorbent(ID)
values(21);

insert into ProductionMachine(ID,AbsorbentID)
values(22,21);
insert into ProductionMachine(ID,AbsorbentID)
values(23,21);
insert into ProductionMachine(ID,AbsorbentID)
values(24,21);
insert into ProductionMachine(ID,AbsorbentID)
values(25,21);
insert into ProductionMachine(ID,AbsorbentID)
values(26,21);
insert into ProductionMachine(ID,AbsorbentID)
values(27,21);
insert into ProductionMachine(ID,AbsorbentID)
values(28,21);
insert into ProductionMachine(ID,AbsorbentID)
values(29,21);

insert into Compressor(ID)
values(30);

/*Measurements*/
DELIMITER //
CREATE PROCEDURE FillWithRandomData(_from date, _till date)
BEGIN
	DECLARE  counter INT;
	DECLARE  currentRandNumber INT;
	DECLARE  currentDate DATE;
    DECLARE i INT;
    
    SET currentDate = _from;
    SET counter =0;
    
    test1:
    while currentDate <= _till DO
		UPDATE Factory
			SET waterConsumption = waterConsumption+rand()*100
		WHERE Factory.ID=1;
		SET i =1;
        test2:
        WHILE i<=30 DO
			CALL insertMeasurement(i,rand()*100,'Kwh',currentDate);
            IF 0<(SELECT COUNT(ID) FROM ProductionMachine WHERE ProductionMachine.ID IN (i)) THEN
				CALL insertMeasurement(i,rand()*100,'piece',currentDate);
			ELSEIF 0<(SELECT COUNT(ID) FROM Compressor WHERE Compressor.ID IN (i)) THEN
				CALL insertMeasurement(i,rand()*100,'m3',currentDate);
		END IF;
            SET i = i +1;
		END WHILE test2;
        SET currentDate= currentDate +1;
	END WHILE test1;
END; //
DELIMITER ;

CALL FillWithRandomData('2014-01-01','2014-01-04');
/*Test*/
select calculateConsumption('2014-01-01','2014-01-02',3);
select calculateConsumption('2014-01-03','2014-01-04',3);
select calculateConsumption('2014-01-01','2014-01-04',3);


select * from ProductionMachine;
select * from absorbent;
select * from compressor;
select * from factory ;
select * from section;

select count(ProductionMachine.ID), Absorbent.ID from ProductionMachine
join Absorbent on Absorbent.ID = ProductionMachine.AbsorbentID
group by Absorbent.ID;

select * from Measurement;
select * from stateOfFormwork;
