use FactorySummary;

/* 1. Question function */
DELIMITER //
create function calculateConsumption(_from date, _till date, _ProductionMachineID int) 
RETURNS FLOAT
BEGIN
	DECLARE a FLOAT;
    DECLARE b FLOAT;
    DECLARE c FLOAT;
    DECLARE result FLOAT;
    DECLARE openFromworks INT;
    DECLARE absorbentID INT;
    select measuredValue into  a from Measurement
	join Machine m1 on Measurement.MachineID = m1.ID
	join ProductionMachine pm1 on m1.ID = pm1.ID
    Where pm1.ID  = _ProductionMachineID and Measurement.dateOfMeasure = _till and Measurement.unitOfMeasure = 'Kwh';
    
    select measuredValue into  b from Measurement
	join Machine m2 on Measurement.MachineID = m2.ID
	join ProductionMachine pm2 on m2.ID = pm2.ID
    Where pm2.ID = _ProductionMachineID and Measurement.dateOfMeasure = _from and Measurement.unitOfMeasure = 'Kwh';
    /*Itt átterhelyük az elszívő fogyasztását a gépre*/
    select Machine.ID into absorbentID from Machine 
	join Absorbent ab1 on Machine.ID = ab1.ID
	join ProductionMachine  pm3 on ab1.ID = pm3.AbsorbentID
	where _ProductionMachineID = pm3.ID;
    
    select count(ProductionMachine.ID) into  openFromworks from ProductionMachine
	join Absorbent ab2 on ProductionMachine.AbsorbentID = ab2.ID
	join ProductionMachine pm4 on ab2.ID = pm4.AbsorbentID
	join stateOfFormwork on stateOfFormwork.ProductionMachineID = pm4.ID
    where stateOfFormwork.isOpen = 1 and ab2.ID =  absorbentID and stateOfFormwork.dateOfState = _till;
    
    select measuredValue into  c from Measurement
	join Machine m3 on Measurement.MachineID = m3.ID
	join ProductionMachine pm5 on m3.ID = pm5.ID
    Where m3.ID =  absorbentID;
    
  SET result = a - b;
    
    IF @openFromworks > 0
    THEN
    SET result = result + (c / openFromworks);
    END IF;
    
   
    RETURN result; 
END; //
DELIMITER ;

/* 2. Question function */
DELIMITER //
create function totalConsumption(sectionID INT)
RETURNS FLOAT
BEGIN
    RETURN (SELECT SUM(measuredValue) from measurement
    join Machine m1 on m1.ID = measurement.MachineID
    join Section s1 on s1.ID =m1.SectionID
    where s1.ID = sectionID and dateOfMeasure=(select Max(dateOfMeasure) from Measurement
    join Machine m1 on m1.ID=Measurement.MachineID
    join Section s1 on s1.ID =m1.sectionID
    join Factory f1 on f1.ID =s1.factoryID)
    group by s1.ID);
END; //
DELIMITER ;

/* 3. Question procedure */
DELIMITER //
CREATE PROCEDURE GetMachineWithHighestPowerConsumption(IN startDate DATE, IN endDate DATE)
BEGIN
  SELECT measurement.MachineID, MAX(measurement.measuredValue) - MIN(measurement.measuredValue) as totalConsumption
  FROM measurement
  WHERE measurement.unitOfMeasure = 'Kwh' AND
        measurement.dateOfMeasure BETWEEN startDate AND endDate
  GROUP BY MachineID
  ORDER BY totalConsumption DESC
  LIMIT 1;
END //;
DELIMITER ;

/* 4. Question procedure */
DELIMITER //
CREATE PROCEDURE GetMachineWithMaxOnTime(IN startDate DATE, IN endDate DATE)
BEGIN
  SELECT machine.ID, MAX(onTime) as maxOnTime FROM (
    SELECT machine.ID, COUNT(stateofformwork.isOpen) as onTime from stateofformwork
    JOIN productionmachine ON stateofformwork.ProductionMachineID = productionmachine.ID
    JOIN machine ON productionmachine.ID = machine.ID
    WHERE stateofformwork.isOpen = 1
      AND stateofformwork.dateOfState BETWEEN startDate AND endDate
    GROUP BY machine.ID
  ) as subquery
  JOIN machine ON subquery.ID = machine.ID;
END //
DELIMITER ;

/* 5.Question procedure */
DELIMITER //
CREATE PROCEDURE GetMachineCountBySection()
BEGIN
  SELECT machine.SectionID, COUNT(machine.ID) as mCount FROM machine
  GROUP BY machine.SectionID
  ORDER BY mCount DESC;
END //
DELIMITER ;

/* 6. Question function */
DELIMITER //
create function Deviation(_from date, _till date, _ProductionMachine INT)
RETURNS INT
BEGIN
   	 RETURN (SELECT STDDEV(measuredValue) from Measurement
   	 join Machine  m1 on m1.ID = measurement.MachineID
    	join ProductionMachine pm1 on m1.ID = pm1.ID
    	where dateOfMeasure >=_from and dateOfMeasure<=_till and pm1.ID = _ProductionMachine
   	 group by m1.ID);
END; //
DELIMITER ;

/* 7. Question function */
DELIMITER //
CREATE FUNCTION GetAverageProductionInSection(sectionId INT)
RETURNS DECIMAL(10,2)
BEGIN
    DECLARE totalProduction DECIMAL(10,2);
    DECLARE machineCount INT;

    SELECT SUM(measurement.measuredValue) INTO totalProduction
    FROM measurement
    INNER JOIN machine ON measurement.MachineID = machine.ID
    WHERE machine.SectionID = sectionId
    AND measurement.unitOfMeasure = 'piece';

    SELECT COUNT(*) INTO machineCount
    FROM machine
    WHERE machine.SectionID = sectionId;

    RETURN IFNULL(totalProduction / machineCount, 0);
END //;
DELIMITER ;

/* 1. Question Answer */
select calculateConsumption('2014-01-03','2014-01-04',3);
select calculateConsumption('2014-01-01','2014-01-04',3);
select calculateConsumption('2014-01-01','2014-01-02',3);

/* 2. Question Answer */
select totalConsumption(1);

/* 3. Question Answer */
CALL GetMachineWithHighestPowerConsumption('2014-01-02', '2014-01-04');

/* 4. Question Answer */
CALL GetMachineWithMaxOnTime('2014-01-01', '2014-01-04');

/* 5. Question Answer */
CALL GetMachineCountBySection();

/* 6. Question Answer */
select Deviation('2014-1-01','2014-1-2',5);

/* 7. Question Answer*/
SELECT machine.SectionID, GetAverageProductionInSection(machine.SectionID) AS avgProduction
FROM machine
GROUP BY machine.SectionID
ORDER BY avgProduction DESC
LIMIT 1;
