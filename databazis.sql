/*
11. Csapat
*/

create database FactorySummary;
use FactorySummary;

create table Factory
(
	ID int primary key auto_increment
    /*név, telephely ..stb.*/
);

create table Section 
(
	ID int primary key auto_increment,
    factoryID int references Factory(ID)
);
/* elszívó */
create table Absorbent
(
    SectionID int references Section(ID)
);

create table Compressor
(
	ID int primary key auto_increment,
    SectionID int references Section(ID) 
);
create table ProductionMachine
(
	ID int primary key auto_increment,
    SectionID int references Section(ID),
	AbsorbentID int references Absorbent(ID),
    energyConsumption float default(0)
    
);
/*Változó adatok*/
create table Formwork
(
	ID int primary key auto_increment,
    MachineID int references ProductionMachine(ID)
    
);

/*Változó adatok*/
create table Measurements
(
	ID int primary key auto_increment,
    MachineID INT references ProductionMachine(ID),
    measuredValue float not null,
    unitOfMeasure varchar(10) not null check(unitOfMeasure = 'Kwh' or unitOfMeasure = 'm3' or unitOfMeasure = 'piece'),
    dateOfMeasure date not null 
);
/*
create procedure insertMeasurement (IN MachineID int, IN val float, IN unit varchar(10), IN _date date)
	BEGIN
		insert into Measurements (MachineID, measuredValue, unitOfMeasure, dateOfMeasure)
		values (MachineID, val, unit, _date);
	END;


create trigger updateConsumption on fizetesMod
after insert
as 
begin
	update FizetesMod
	if inserted.hatarido> 30 
		set fizetesMod.hatarido = deleted.hatarido
	end
end
*/
