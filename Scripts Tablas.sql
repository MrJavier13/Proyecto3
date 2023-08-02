create database Planilla
go
use Planilla 
go;



create table Residencia(
idResidencia int NOT NULL,
provincia varchar(20) NOT NULL,
canton varchar(20) NOT NULL,
distrito varchar(20) NOT NULL,
direccionExacta varchar(30) NOT NULL,
PRIMARY KEY (idResidencia),
);



create table Empleado(
cedula int NOT NULL,
nombre varchar(20) NOT NULL,
apellido1 varchar(20) NOT NULL,
apellido2 varchar(20) NOT NULL,
fechaNacimiento date NOT NULL,
fechaIngreso date NOT NULL,
genero varchar(20) NOT NULL,
telefono int NOT NULL,
puesto varchar(30) NOT NULL,
escolaridad varchar(30) NOT NULL,
departamento varchar(30) NOT NULL,
idResidencia int NOT NULL,
PRIMARY KEY (cedula),
CONSTRAINT fk_Residencia FOREIGN KEY (idResidencia) REFERENCES Residencia (idResidencia)
);



create table Vacaciones(
idVacaciones int NOT NULL,
fechaInicio date NOT NULL,
fechaFinal date NOT NULL,
diasDisfrutados int NOT NULL,
periodo int NOT NULL,
cedula int NOT NULL,
PRIMARY KEY (idVacaciones),
CONSTRAINT fk_Cedula FOREIGN KEY (cedula) REFERENCES Empleado (cedula)
);



CREATE TABLE Incapacidades(
idIncapacidad int NOT NULL,
fechaInicio date NOT NULL,
fechaFinal date NOT NULL,
tipoIncapacidad varchar(20) NOT NULL,
cedula int NOT NULL,
PRIMARY KEY (idIncapacidad),
CONSTRAINT fk_Cedula2 FOREIGN KEY (cedula) REFERENCES Empleado (cedula),
diasDeIncapacidad AS DATEDIFF(day, fechaInicio, fechaFinal),
);



create table Salario(
idSalario int IDENTITY NOT NULL,
salarioBruto float NOT NULL,
salarioNeto float NOT NULL,
cedula int NOT NULL,
PRIMARY KEY (idSalario),
CONSTRAINT fk_Cedula3 FOREIGN KEY (cedula) REFERENCES Empleado (cedula)
);