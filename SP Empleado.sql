create procedure SPEmpleado
	@opc int,
	@cedula int = null,
	@nombre varchar(20) = null,
	@apellido1 varchar(20) = null,
	@apellido2 varchar(20) = null,
	@fechaNacimiento date = null,
	@fechaIngreso date = null,
	@genero varchar(20) = null,
	@telefono int = null,
	@puesto varchar(30) = null,
	@escolaridad varchar(30) = null,
	@departamento varchar(30) = null,
	@idResidencia int = null

as
	begin
		if @opc = 1
			begin
			try
				if @cedula is null
					print ('La cédula del empleado no debe estar vacía.')
				if @nombre is null
					print ('El nombre del empleado no debe estar vacía.')
				else
					INSERT INTO Empleado
						(cedula, nombre, apellido1, apellido2, fechaNacimiento, fechaIngreso, genero, telefono, puesto, escolaridad, departamento, idResidencia)
						VALUES
						(@cedula, @nombre, @apellido1, @apellido2, @fechaNacimiento, @fechaIngreso, @genero, @telefono, @puesto, @escolaridad, @departamento, @idResidencia)
				
	
					
			end try
			begin catch
				print ('Hubo un error al insertar el empleado.')
			end catch
	
		if @opc = 2
			begin
				Select * from Empleado
			end

		if @opc = 3
			begin try
				if @cedula is null
						print ('La cédula del empleado no debe estar vacía.')
				else
					Update Empleado SET nombre = @nombre,
									   apellido1 = @apellido1,
									   apellido2 = @apellido2,
									   fechaNacimiento = @fechaNacimiento,
									   fechaIngreso = @fechaIngreso,
									   genero  = @genero,
									   telefono = @telefono,
	                                   puesto = @puesto,
                                   	   escolaridad  = @escolaridad,
	                                   departamento = @departamento,
	                                   idResidencia = @idResidencia
							   where   cedula = @cedula
			end try
			begin catch
				print ('Hubo un error al actualizar el empleado.')
			end catch
		
		
		else if @opc = 4
			begin  try
			if @cedula is null
						print ('La cédula del empleado no debe estar vacía.')
			else
				Delete From Empleado where cedula = @cedula
			end try
			begin catch
			print ('Hubo un error al eliminar el empleado.')
			end catch
			

end







-- Pruebas:

exec SPEmpleado 1, 303980518, 'Renato', 'Quesada', 'Brenes', '1984-11-05', '2022-01-23', 'Masculino', 85745684, 'Gerente', 'Licenciatura', 'Gerencia', 1

exec SPEmpleado 1, 104586985, 'Enzo', 'Rojas', 'Campos', '1997-10-26', '2020-02-11', 'Masculino', 45858745, 'Abogado', 'Maestria', 'Legal', 2

exec SPEmpleado 1, 114290929, 'Mery Ann', 'Castro', 'Mora', '1990-06-02', '2023-06-10', 'Femenino', 72076245, 'Miscelanea', 'No profesional', 'Servicios Generales', 3

exec SPEmpleado 1, 602540865, 'Adrián', 'Rodriguez', 'Fonseca', '1996-10-21', '2021-05-15', 'Masculino', 75869874, 'Contador', 'Bachillerato Universitario', 'Administracion', 4