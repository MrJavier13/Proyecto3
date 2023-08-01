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

--procedimiento calcular edad
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
	

    -- Obtener el salario base y la fecha de ingreso según el puesto del empleado
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

    -- Calcular los puntos de la carrera profesional (si aplica)
    IF @escolaridad = 'Bachillerato'
        SET @carreraProfesionalPuntos = 10
    ELSE IF @escolaridad = 'Licenciatura'
        SET @carreraProfesionalPuntos = 16
    ELSE IF @escolaridad = 'Maestria'
        SET @carreraProfesionalPuntos = 20

   -- Calcular la dedicacion exclusica (si aplica)
    IF @escolaridad = 'Bachillerato' 
        SET @dedicacionExclusiva = @salarioBase * 0.25
    IF @escolaridad = 'Licenciatura'
        SET @dedicacionExclusiva = @salarioBase * 0.55

   -- Calcular la anualidad (si aplica)
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

    -- Calcular la prohibición (si aplica)
    IF  @departamento = 'Legal' and @escolaridad = 'Bachillerato'
        SET @prohibicion = @salarioBase * 0.3
    IF  @departamento = 'Legal' and @escolaridad = 'Licenciatura'
        SET @prohibicion = @salarioBase * 0.25

	IF @departamento = 'Gerencia' AND @escolaridad != 'No profesional'
		SET @complementoGerencial = @salarioBase * 0.01

    -- Calcular el salario total
    DECLARE @salarioBruto float
    SET @salarioBruto = @salarioBase + @anualidadTotal + (@carreraProfesionalPuntos * 3000) + @dedicacionExclusiva + @prohibicion + @complementoGerencial

	DECLARE @salarioNeto float = 0
	SET @salarioNeto = dbo.CalcularSalarioNeto(@salarioBruto, @asociacion, @rebajoObligatorio, @rebajoNoObligatorio)



     -- Insertar el salario bruto en la tabla "Salarios"
    INSERT INTO Salario (cedula, SalarioBruto, salarioNeto)
    VALUES (@cedula, @salarioBruto, @salarioNeto)
END

go

--funcion calcular salario neto
CREATE OR ALTER FUNCTION CalcularSalarioNeto
	(@salarioBruto float = null, @Asociacion BIT = null, @rebajoObligatorio float = null,  @rebajoNoObligatorio float = null)
	RETURNS float
	AS
BEGIN
	
	DECLARE @seguroSalud float = 0.055
	DECLARE @seguroPensiones float = 0.035
	DECLARE @bancoPopular float = 0.01
	DECLARE @fondoMortalidad float = 0.03
	DECLARE @impuestoRenta float = 0
	DECLARE @salarioNeto float = 0
	DECLARE @rebajoAsociacion float = 0


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
	set @salarioNeto = @salarioBruto - ((@salarioBruto*@seguroSalud) + (@salarioBruto*@seguroPensiones) + (@salarioBruto*@bancoPopular)+(@salarioBruto*@fondoMortalidad) + (@salarioBruto*@impuestoRenta)+(@salarioBruto*@rebajoAsociacion) + @rebajoObligatorio + @rebajoNoObligatorio)

	return @salarioNeto
END

