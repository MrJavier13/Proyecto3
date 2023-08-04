create table bitacoraVacaciones(
	fecha_modificacion datetime primary key,
	proceso varchar(15) not null

);


GO
CREATE TRIGGER D_BitadoraVacaciones
ON Vacaciones
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    DECLARE @operacion VARCHAR(15);
    
    IF EXISTS (SELECT * FROM inserted)
    BEGIN
        IF EXISTS (SELECT * FROM deleted)
        BEGIN
            SELECT @operacion = 'MODIFICAR'
        END
        ELSE
        BEGIN
            SELECT @operacion = 'INSERTAR'
        END
    END
    ELSE
    BEGIN
        SELECT @operacion = 'ELIMINAR'
    END
    
    INSERT INTO bitacoraVacaciones(fecha_modificacion, proceso)
    VALUES (GETDATE(), @operacion)
END