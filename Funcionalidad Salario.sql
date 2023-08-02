--funcion calcular anualidad
CREATE OR ALTER FUNCTION CalcularAnualidad
(@fechaIngreso DATE = NULL)
RETURNS DECIMAL(10, 2)
AS
BEGIN
    DECLARE @anualidad DECIMAL(10, 2) = 0
	DECLARE @fechaR DATE;
	DECLARE @fechaAc DATE = GETDATE();
    SELECT @fechaR = @fechaIngreso;

	SELECT @anualidad = DATEDIFF(YEAR, @fechaR, @fechaAc);

    RETURN @anualidad
END

GO

--procedimiento calcular salario
CREATE OR ALTER PROCEDURE SPCalcularSalario
    @cedula INT,
	@asociacion bit,
	@rebajoObligatorio float,
	@rebajoNoObligatorio float
    
AS
BEGIN
    DECLARE @salarioBase float
    DECLARE @carreraProfesionalPuntos INT = 0
    DECLARE @dedicacionExclusiva float = 0
    DECLARE @prohibicion float = 0
    DECLARE @anualidad float
	DECLARE @anualidadTotal float = 0
	DECLARE @departamento VARCHAR(50)
	DECLARE @escolaridad VARCHAR(50)
	DECLARE @complementoGerencial float = 0
	

    -- Obtener el salario base y la fecha de ingreso seg�n el puesto del empleado
     begin
    try
    SELECT @salarioBase = CASE 
                            WHEN departamento = 'Servicios Generales' THEN 390000
                            WHEN departamento = 'Administracion' and escolaridad = 'No profesional' THEN 500000
                            WHEN departamento = 'Administracion' and escolaridad != 'No profesional' THEN 800000
                            WHEN departamento = 'Gerencia' and escolaridad = 'No profesional' THEN 600000
                            WHEN departamento = 'Gerencia' and escolaridad != 'No profesional' THEN 1200000
                            WHEN departamento = 'Legal' and escolaridad = 'No profesional' THEN 550000
                            WHEN departamento = 'Legal' and escolaridad != 'No profesional' THEN 650000
                            ELSE 0
                          END,
           @anualidad = dbo.CalcularAnualidad(FechaIngreso), @departamento = departamento, @escolaridad = escolaridad
    FROM Empleado
    WHERE Cedula = @cedula
    end try
    begin catch
    print ('Hubo un error al encontrar el departamento del empleado.')
    end catch

    -- Calcular los puntos de la carrera profesional (si aplica)
    begin
    try
    IF @escolaridad = 'Bachillerato'
        SET @carreraProfesionalPuntos = 10
    ELSE IF @escolaridad = 'Licenciatura'
        SET @carreraProfesionalPuntos = 16
    ELSE IF @escolaridad = 'Maestria'
        SET @carreraProfesionalPuntos = 20
    end try
    begin catch
    print ('Hubo un error al calcular los puntos de la carrera profesional del empleado.')
    end catch

   -- Calcular la dedicacion exclusica (si aplica)
    begin
    try
    IF @escolaridad = 'Bachillerato' 
        SET @dedicacionExclusiva = @salarioBase * 0.25
    IF @escolaridad = 'Licenciatura'
        SET @dedicacionExclusiva = @salarioBase * 0.55
    end try
    begin catch
    print ('Hubo un error al calcular la dedicacion exclusica del empleado.')
    end catch

   -- Calcular la anualidad (si aplica)
    begin
    try
	IF @anualidad >= 1 AND @departamento = 'Servicios Generales' AND @escolaridad = 'No profesional'
		SET @anualidadTotal = 7000 * @anualidad
	IF @anualidad >= 1 AND @departamento = 'Administracion' AND @escolaridad = 'No profesional'
		SET @anualidadTotal = 8000 * @anualidad
	IF @anualidad >= 1 AND	@departamento = 'Administracion' AND @escolaridad = 'Bachillerato' OR @escolaridad = 'Licenciatura' OR @escolaridad = 'Maestria'
		SET @anualidadTotal = 10000 * @anualidad
	IF @anualidad >= 1 AND @departamento = 'Gerencia' AND @escolaridad = 'No profesional'
		SET @anualidadTotal = 8500 * @anualidad
    IF @anualidad >= 1 AND @departamento = 'Gerencia' AND @escolaridad = 'Bachillerato' OR @escolaridad = 'Licenciatura' OR @escolaridad = 'Maestria'
        SET @anualidadTotal = 15000 * @anualidad
	IF @anualidad >= 1 AND @departamento = 'Legal' AND @escolaridad = 'No profesional'
		SET @anualidadTotal = 8000 * @anualidad
	IF @anualidad >= 1 AND	@departamento = 'Legal' AND @escolaridad = 'Bachillerato' OR @escolaridad = 'Licenciatura' OR @escolaridad = 'Maestria'
		SET @anualidadTotal = 10000 * @anualidad
     end try
     begin catch
     print ('Hubo un error al calcular las anualidades del empleado.')
     end catch

    -- Calcular la prohibición (si aplica)
    begin
    try
    IF  @departamento = 'Legal' and @escolaridad = 'Bachillerato'
        SET @prohibicion = @salarioBase * 0.3
    IF  @departamento = 'Legal' and @escolaridad = 'Licenciatura'
        SET @prohibicion = @salarioBase * 0.25
    IF @departamento = 'Gerencia' AND @escolaridad != 'No profesional'
		SET @complementoGerencial = @salarioBase * 0.01
     end try
     begin catch
     print ('Hubo un error al calcular la prohibición del empleado.')
     end catch

    -- Calcular el salario total
     begin
    try
    DECLARE @salarioBruto DECIMAL(10, 2)
    SET @salarioBruto = @salarioBase + @anualidadTotal + (@carreraProfesionalPuntos * 3000) + @dedicacionExclusiva + @prohibicion + @complementoGerencial

    DECLARE @salarioNeto DECIMAL(10, 2) = 0
    SET @salarioNeto =  dbo.CalcularSalarioNeto(@salarioBruto, @asociacion, @rebajoObligatorio, @rebajoNoObligatorio)
     end try
     begin catch
     print ('Hubo un error al calcular el salario bruto del empleado.')
     end catch



     -- Insertar el salario en la tabla "Salarios"
    begin
    try
    INSERT INTO Salario (cedula, SalarioBruto, salarioNeto)
    VALUES (@cedula, @salarioBruto, @salarioNeto)
     end try
     begin catch
     print ('Hubo un error al insertar el salario del empleado.')
     end catch
END

go

--funcion calcular salario neto
CREATE OR ALTER FUNCTION CalcularSalarioNeto
	(@salarioBruto float = null, @Asociacion BIT = null, @rebajoObligatorio float = null,  @rebajoNoObligatorio float = null)
	RETURNS float
	AS
BEGIN
	
	DECLARE @seguroSalud FLOAT = 0.055
	DECLARE @seguroPensiones FLOAT = 0.035
	DECLARE @bancoPopular FLOAT = 0.01
	DECLARE @fondoMortalidad FLOAT = 0.03
	DECLARE @impuestoRenta FLOAT = 0
	DECLARE @salarioNeto FLOAT = 0
	DECLARE @rebajoAsociacion FLOAT = 0

	--Impuesto sobre el salario (Renta)
	IF  @salarioBruto > 941000 AND @salarioBruto <= 1380999
        SET @impuestoRenta = 0.1
	IF  @salarioBruto > 1381000 AND @salarioBruto <= 2422999
        SET @impuestoRenta = 0.15
	IF  @salarioBruto > 2423000 AND @salarioBruto <= 4844999
        SET @impuestoRenta = 0.20
	IF  @salarioBruto > 4845000
        SET @impuestoRenta = 0.25
	IF @Asociacion = 1
	SET @rebajoAsociacion = 0.055

	--calcular el salario neto
	set @salarioNeto = @salarioBruto - (@salarioBruto*@seguroSalud) - (@salarioBruto*@seguroPensiones) - (@salarioBruto*@bancoPopular) - (@salarioBruto*@fondoMortalidad) - (@salarioBruto*@impuestoRenta)-(@salarioBruto*@rebajoAsociacion) - @rebajoObligatorio - @rebajoNoObligatorio

	return @salarioNeto

END

exec SPCalcularSalario 114290929, 1, 20000, 15000

