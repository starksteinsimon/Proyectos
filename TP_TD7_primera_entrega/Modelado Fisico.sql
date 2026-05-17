CREATE TABLE Region (
    Nombre_region VARCHAR(100) PRIMARY KEY
);

CREATE TABLE Provincia (
    Nombre_provincia VARCHAR(100) PRIMARY KEY,
    Nombre_region VARCHAR(100) NOT NULL,

    FOREIGN KEY (Nombre_region) REFERENCES Region(Nombre_region)
);

CREATE TABLE Departamento (
    Nombre_departamento VARCHAR(100) NOT NULL,
    Nombre_provincia VARCHAR(100) NOT NULL,
    habitantes INT NOT NULL,
    vehiculos INT NOT NULL,
    ingreso_per_capita NUMERIC(12,2),

    PRIMARY KEY (Nombre_departamento, Nombre_provincia),

    FOREIGN KEY (Nombre_provincia) REFERENCES Provincia(Nombre_provincia),

    CHECK (habitantes >= 0),
    CHECK (vehiculos >= 0),
    CHECK (ingreso_per_capita >= 0)
);

CREATE TABLE Empresa (
    CUIT VARCHAR(20) PRIMARY KEY,
    Nombre_empresa VARCHAR(100) NOT NULL
);

CREATE TABLE Estacion (
    Numero_estacion INT NOT NULL,
    CUIT VARCHAR(20) NOT NULL,
    Nombre_departamento VARCHAR(100) NOT NULL,
    Nombre_provincia VARCHAR(100) NOT NULL,

    PRIMARY KEY (Numero_estacion, CUIT),

    FOREIGN KEY (CUIT) REFERENCES Empresa(CUIT),
    FOREIGN KEY (Nombre_departamento, Nombre_provincia) 
        REFERENCES Departamento(Nombre_departamento, Nombre_provincia)
);

CREATE TABLE Combustible (
    Nombre_combustible VARCHAR(100) NOT NULL,
    CUIT VARCHAR(20) NOT NULL,
    Tipo_combustible VARCHAR(100) NOT NULL,
    Rendimiento NUMERIC(10,2),
    Valor_calorifico NUMERIC(10,2),
    Valor_emisiones NUMERIC(10,2),

    PRIMARY KEY (Nombre_combustible, CUIT),

    FOREIGN KEY (CUIT) REFERENCES Empresa(CUIT),

    CHECK (Rendimiento >= 0),
    CHECK (Valor_calorifico >= 0),
    CHECK (Valor_emisiones >= 0)
);

CREATE TABLE Empresa_flota (
    Nombre_empresa_flota VARCHAR(100) PRIMARY KEY
);

CREATE TABLE Rendimiento_referencia (
    Tipo_vehiculo VARCHAR(100) NOT NULL,
    Rango_edad VARCHAR(20) NOT NULL,
    Rendimiento_promedio NUMERIC(10,2),
    Emision_promedio NUMERIC(10,2),

    PRIMARY KEY (Tipo_vehiculo, Rango_edad),

    CHECK (Rango_edad IN ('0-5', '5-10', '10-15', '+15')),
    CHECK (Rendimiento_promedio >= 0),
    CHECK (Emision_promedio >= 0)
);

CREATE TABLE Vehiculos (
    Patente VARCHAR(20) PRIMARY KEY,
    Nombre_departamento VARCHAR(100) NOT NULL,
    Nombre_provincia VARCHAR(100) NOT NULL,
    Tipo_vehiculo VARCHAR(100) NOT NULL,
    vejez INT NOT NULL,
    Rango_edad VARCHAR(20) NOT NULL,

    FOREIGN KEY (Nombre_departamento, Nombre_provincia) 
        REFERENCES Departamento(Nombre_departamento, Nombre_provincia),

    FOREIGN KEY (Tipo_vehiculo, Rango_edad) 
        REFERENCES Rendimiento_referencia(Tipo_vehiculo, Rango_edad),

    CHECK (vejez >= 0),
    CHECK (Rango_edad IN ('0-5', '5-10', '10-15', '+15'))
);

CREATE TABLE Vehiculos_flota (
    Patente VARCHAR(20) PRIMARY KEY,
    Nombre_departamento VARCHAR(100) NOT NULL,
    Nombre_provincia VARCHAR(100) NOT NULL,
    Tipo_vehiculo VARCHAR(100) NOT NULL,
    vejez INT NOT NULL,
    Rango_edad VARCHAR(20) NOT NULL,
    Nombre_empresa_flota VARCHAR(100) NOT NULL,

    FOREIGN KEY (Nombre_departamento, Nombre_provincia) 
        REFERENCES Departamento(Nombre_departamento, Nombre_provincia),

    FOREIGN KEY (Tipo_vehiculo, Rango_edad) 
        REFERENCES Rendimiento_referencia(Tipo_vehiculo, Rango_edad),

    FOREIGN KEY (Nombre_empresa_flota) 
        REFERENCES Empresa_flota(Nombre_empresa_flota),

    CHECK (vejez >= 0),
    CHECK (Rango_edad IN ('0-5', '5-10', '10-15', '+15'))
);

CREATE TABLE Dia (
    Fecha DATE PRIMARY KEY,
    Temp_max NUMERIC(5,2),
    Temp_min NUMERIC(5,2),
    Tipo_dia VARCHAR(20) NOT NULL,

    CHECK (Temp_max >= Temp_min),
    CHECK (Tipo_dia IN ('Dia de semana', 'Fin de semana'))
);

CREATE TABLE Evento (
    ID_evento INT PRIMARY KEY,
    Descripcion VARCHAR(255) NOT NULL,
    Fecha_inicio DATE NOT NULL,
    Fecha_fin DATE NOT NULL,

    CHECK (Fecha_fin >= Fecha_inicio)
);

CREATE TABLE Ocurre (
    Fecha DATE NOT NULL,
    ID_evento INT NOT NULL,

    PRIMARY KEY (Fecha, ID_evento),

    FOREIGN KEY (Fecha) REFERENCES Dia(Fecha),
    FOREIGN KEY (ID_evento) REFERENCES Evento(ID_evento)
);

CREATE TABLE Venta (
    Numero_venta INT PRIMARY KEY,
    Tipo_venta VARCHAR(20) NOT NULL,
    Cantidad NUMERIC(12,2) NOT NULL,
    Destino VARCHAR(20),
    Fecha DATE NOT NULL,

    Patente_vehiculo VARCHAR(20),
    Patente_vehiculo_flota VARCHAR(20),

    Nombre_combustible VARCHAR(100) NOT NULL,
    Numero_estacion INT NOT NULL,
    CUIT VARCHAR(20) NOT NULL,

    FOREIGN KEY (Fecha) REFERENCES Dia(Fecha),

    FOREIGN KEY (Patente_vehiculo) 
        REFERENCES Vehiculos(Patente),

    FOREIGN KEY (Patente_vehiculo_flota) 
        REFERENCES Vehiculos_flota(Patente),

    FOREIGN KEY (Nombre_combustible, CUIT) 
        REFERENCES Combustible(Nombre_combustible, CUIT),

    FOREIGN KEY (Numero_estacion, CUIT) 
        REFERENCES Estacion(Numero_estacion, CUIT),

    CHECK (Cantidad > 0),
    CHECK (Tipo_venta IN ('Simple', 'Orden')),
    CHECK (Destino IN ('Agro', 'Industria') OR Destino IS NULL),

    CHECK (
        (Patente_vehiculo IS NOT NULL AND Patente_vehiculo_flota IS NULL)
        OR
        (Patente_vehiculo IS NULL AND Patente_vehiculo_flota IS NOT NULL)
    ),

    CHECK (
        (Tipo_venta = 'Orden' AND Destino IN ('Agro', 'Industria'))
        OR
        (Tipo_venta = 'Simple' AND Destino IS NULL)
    )
);