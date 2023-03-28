	SET @_from = '2014-01-01';
	SET @_till = '2014-01-04';
    SET @_ProductionMachineID = 3;

	SET @a = 0.0;
    SET @b = 0.0;
    SET @c = 0.0;
    SET @result = 0.0;
    SET @openFromworks = 0.0;
    SET @absorbentID = 0.0;
    select measuredValue into  @a from Measurement
	join Machine m1 on Measurement.MachineID = m1.ID
	join ProductionMachine pm1 on m1.ID = pm1.ID
    Where pm1.ID  = @_ProductionMachineID and Measurement.dateOfMeasure = @_till and Measurement.unitOfMeasure = 'Kwh';
    
    SELECT @a;
    
    select measuredValue into  @b from Measurement
	join Machine m2 on Measurement.MachineID = m2.ID
	join ProductionMachine pm2 on m2.ID = pm2.ID
    Where pm2.ID = @_ProductionMachineID and Measurement.dateOfMeasure = @_from and Measurement.unitOfMeasure = 'Kwh';
    
    SELECT @b;
    
    /*Itt átterhelyük az elszívő fogyasztását a gépre*/
    select Machine.ID into @absorbentID from Machine 
	join Absorbent ab1 on Machine.ID = ab1.ID
	join ProductionMachine  pm3 on ab1.ID = pm3.AbsorbentID
	where @_ProductionMachineID = pm3.ID;
    
    SELECT @absorbentID;
    
    select count(ProductionMachine.ID) into  @openFromworks from ProductionMachine
	join Absorbent ab2 on ProductionMachine.AbsorbentID = ab2.ID
	join ProductionMachine pm4 on ab2.ID = pm4.AbsorbentID
	join stateOfFormwork on stateOfFormwork.ProductionMachineID = pm4.ID
    where stateOfFormwork.isOpen = 1 and ab2.ID =  @absorbentID and stateOfFormwork.dateOfState = @_till;
    
    SELECT @openFromworks;
    
    select measuredValue into  @c from Measurement
	join Machine m3 on Measurement.MachineID = m3.ID
	join ProductionMachine pm5 on m3.ID = pm5.ID
    Where m3.ID =  @absorbentID;
    
    SELECT @c;
    
    SET @result = @a - @b;
    
    DELIMITER //
    
    IF @openFromworks > 0
    THEN
    SET @result = @result + (@c / @openFromworks);
    END IF; //
    
   	DELIMITER ;
    SELECT @result; 
