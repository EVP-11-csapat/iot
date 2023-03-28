/*
11. Csapat
*/

create database FactorySummary;
use FactorySummary;

create table Factory
(
	ID int primary key auto_increment,
	waterConsumption float default(0)
    /*név, telephely ..stb.*/
);

create table Section 
(
	ID int primary key auto_increment,
    factoryID int references Factory(ID)
);

/*Szülőosztály */
create table Machine
(
	ID int primary key auto_increment,
    SectionID int references Section(ID)
    
);

/* elszívó */
create table Absorbent
(
	ID int primary key references Machine(ID)
);

create table Compressor
(
	ID int primary key references Machine(ID) 
);
create table ProductionMachine
(
	ID int primary key references Machine(ID),
	AbsorbentID int references Absorbent(ID)
);
/*Változó adatok*/ 
/* Zsalu */
create table stateOfFormwork
(
	ID int primary key auto_increment,
    ProductionMachineID int references ProductionMachine(ID),
    isOpen int not null check(isOpen = 1 or isOpen = 0),
    dateOfState date not null 
);

/* Változó adatok */
create table Measurement
(
	ID int primary key  auto_increment,
    MachineID INT references Machine(ID),
    measuredValue float not null,
    unitOfMeasure varchar(10) not null check(unitOfMeasure = 'Kwh' or unitOfMeasure = 'm3' or unitOfMeasure = 'piece'),
    dateOfMeasure date not null 
);
/* INSERTS */
DELIMITER //
create procedure insertMeasurement (_MachineID int,val float,unit varchar(10),_date date)
BEGIN
	insert into FactorySummary.Measurement (MachineID, measuredValue, unitOfMeasure, dateOfMeasure)
	values (_MachineID, val, unit, _date);
END //
DELIMITER ;

DELIMITER //
create procedure insertStateOfFormwork( PMachineID int, _isOpen int, _date date)
BEGIN
	insert into FactorySummary.stateOfFormwork(ProductionMachineID, isOpen,dateOfState)
    values(PMachineID, _isOpen,_date);
END //   
DELIMITER ;

/*Termelő gépek fogyasztását számolja ki egy adott időintervallumon*/
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
    Where pm1.ID  = _ProductionMachineID and Measurement.dateOfMeasure = _till;
    
    select measuredValue into  b from Measurement
	join Machine m2 on Measurement.MachineID = m2.ID
	join ProductionMachine pm2 on m2.ID = pm2.ID
    Where pm2.ID = _ProductionMachineID and Measurement.dateOfMeasure = _from;
    /*Itt átterhelyük az elszívő fogyasztását a gépre*/
    select ID into absorbentID from Machine 
	join Absorbent ab1 on Machine.ID = ab1.ID
	join ProductionMachine  pm3 on ab1.ID = pm3.AbsorbentID
	where _ProductionMachine = pm3.ID;
    
    select count(ID) into  openFromworks from ProductionMachine
	join Absorbent ab2 on Machine.ID = ab2.ID
	join ProductionMachine pm4 on ab2.ID = pm4.AbsorbentID
	join stateOfFormwork on stateOfFormwork.ProductionMachineID = pm4.ID
    where stateOfFormwork.isOpen = 1 and ab2.ID =  absorbentID and stateOfFormwork.dateOfState = _date;
    
    select measuredValue into  c from Measurement
	join Machine m3 on Measurement.MachineID = m3.ID
	join ProductionMachine pm5 on m3.ID = pm5.ID
    Where m3.ID =  absorbentID;
    
    
    SET result = (b - a + (c / openFromworks));
    
   
    RETURN result; 
END; //
DELIMITER ;
