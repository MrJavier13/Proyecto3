create procedure SPIncapacidades
@opc int,
@idIncapacidad int = null,
@fechaInicio date = null,
@fechaFinal date = null,
@tipoIncapacidad varchar(20) = null,
@diasDeIncapacidad int = null,
@cedula int = null

as
begin
/*Insert*/
if @opc = 1
begin
			try
			if @idIncapacidad is null
			print('ID de Incapacidad vacia, inserte datos.')
			else
			INSERT INTO Incapacidades
			(idIncapacidad,fechaInicio,fechaFinal,tipoIncapacidad,diasDeIncapacidad,cedula)
			values
			(@idIncapacidad,@fechaInicio,@fechaFinal,@tipoIncapacidad,@diasDeIncapacidad,@cedula)
			end try
			begin catch
			print ('Hubo un error al insertar la incapacidad.')
			end catch

/*Select*/
if @opc = 2
begin
Select * from Incapacidades
end

/*Update*/
if @opc = 3
begin try
if @idIncapacidad is null
			print('ID de Incapacidad vacia, inserte datos.')
else
Update Incapacidades SET

fechaInicio = @fechaInicio,
fechaFinal = @fechaFinal,
tipoIncapacidad = @tipoIncapacidad,
diasDeIncapacidad = @diasDeIncapacidad,
cedula = @cedula 

where idIncapacidad = @idIncapacidad

end try

begin catch
				print ('Hubo un error actualizando la residencia.')
end catch

/*Delete*/

else if @opc = 4
begin try
if @idIncapacidad is null
			print('ID de Incapacidad vacia, inserte datos.')
else
DELETE FROM Incapacidades WHERE idIncapacidad = @idIncapacidad
end try

begin catch
				print ('Hubo un error al eliminar residencia.')
end catch

end



--Pruebas:

exec SPIncapacidades 1, 1, '2022-07-01', '2022-07-05', 'INS', 5, 303980518
exec SPIncapacidades 1, 2, '2023-05-15', '2023-05-16', 'CCSS', 2, 602540865
exec SPIncapacidades 1, 3, '2023-07-01', '2023-07-03', 'Medico Privado', 3, 114290929