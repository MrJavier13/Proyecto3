CREATE TRIGGER D_InsertarEmpleado
ON Empleado
AFTER INSERT
AS
BEGIN

  INSERT INTO BitacoraEmpleado (fechaModificacion, procesoRealizado)
  VALUES (GETDATE(), 'Almacenar')

  PRINT ('Se almecenó un empleado')
END

Alter TRIGGER D_ModificarEmpleado
ON Empleado
AFTER update
AS
BEGIN

  INSERT INTO BitacoraEmpleado (fechaModificacion, procesoRealizado)
  VALUES (GETDATE(), 'Actualizar')

  PRINT ('Se actualizó un empleado')
END

CREATE TRIGGER D_EliminarEmpleado
ON Empleado
AFTER delete
AS
BEGIN

  INSERT INTO BitacoraEmpleado (fechaModificacion, procesoRealizado)
  VALUES (GETDATE(), 'Eliminar')

  PRINT ('Se eliminó un empleado')
END