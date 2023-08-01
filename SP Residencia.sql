/*Residencia + Incapacidades (insert –select –update-select)*/

create procedure SPResidencia
@opc int,
@idResidencia int = null,
@provincia varchar(20)= null ,
@canton varchar(20) = null,
@distrito varchar(20) = null ,
@direccionExacta varchar(30)= null

as
begin
/*Insert*/
if @opc = 1
			begin
			try
			if @idResidencia is null
			print('ID de Residencia vacia, inserte datos.')
			else
			INSERT INTO Residencia
			(idResidencia,provincia,canton,distrito,direccionExacta)
			values
			(@idResidencia,@provincia,@canton,@distrito,@direccionExacta)
			end try
			begin catch
			print ('Hubo un error al insertar la residencia.')
			end catch

/*Select*/
if @opc = 2
begin
Select * from Residencia
end

/*Update*/
if @opc = 3
begin try
if @idResidencia is null
			print('ID de Residencia vacía, inserte datos.')
else
Update Residencia SET

provincia = @provincia,
canton = @canton,
distrito = @distrito,
direccionExacta = @direccionExacta

where idResidencia = @idResidencia

end try

begin catch
				print ('Hubo un error al actualizar la residencia la residencia.')
end catch

/*Delete*/

else if @opc = 4
begin try
if @idResidencia is null
                 print('ID de Residencia vacía, inserte datos.')
else
DELETE FROM Residencia WHERE idResidencia = @idResidencia
end try

begin catch
				print ('Hubo un error al eliminar la residencia.')
end catch

end




--Pruebas:

exec SPResidencia 1, 1, 'San José', 'Puriscal', 'Santiago', 'Cañales Abajo'
exec SPResidencia 1, 2, 'Puntarenas', 'Golfito', 'Guaycara', 'Km 28'
exec SPResidencia 1, 3, 'San José', 'Escazú', 'San Antonio', 'Barrio El Tajo'
exec SPResidencia 1, 4, 'Limón', 'Talamanca', 'Sixaola', 'Finca 52'