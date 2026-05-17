/* 1. Total de combustible vendido por región */

SELECT 
    p.Nombre_region,
    SUM(v.Cantidad) AS Total_vendido
FROM Venta v
JOIN Estacion e 
    ON v.Numero_estacion = e.Numero_estacion
   AND v.CUIT = e.CUIT
JOIN Departamento d 
    ON e.Nombre_departamento = d.Nombre_departamento
   AND e.Nombre_provincia = d.Nombre_provincia
JOIN Provincia p 
    ON d.Nombre_provincia = p.Nombre_provincia
GROUP BY p.Nombre_region
ORDER BY Total_vendido DESC;


/* 2. Total de combustible vendido por provincia */

SELECT 
    e.Nombre_provincia,
    SUM(v.Cantidad) AS Total_vendido
FROM Venta v
JOIN Estacion e 
    ON v.Numero_estacion = e.Numero_estacion
   AND v.CUIT = e.CUIT
GROUP BY e.Nombre_provincia
ORDER BY Total_vendido DESC;


/* 3. Ventas a granel separadas por destino */

SELECT 
    Destino,
    COUNT(*) AS Cantidad_ventas,
    SUM(Cantidad) AS Total_vendido
FROM Venta
WHERE Tipo_venta = 'Orden'
GROUP BY Destino
ORDER BY Total_vendido DESC;


/* 4. Comparación de ventas entre días de semana y fines de semana */

SELECT 
    d.Tipo_dia,
    COUNT(v.Numero_venta) AS Cantidad_ventas,
    SUM(v.Cantidad) AS Total_vendido,
    AVG(v.Cantidad) AS Promedio_por_venta
FROM Dia d
JOIN Venta v 
    ON d.Fecha = v.Fecha
GROUP BY d.Tipo_dia;


/* 5. Emisiones estimadas por departamento */

SELECT 
    e.Nombre_departamento,
    e.Nombre_provincia,
    SUM(v.Cantidad * c.Valor_emisiones) AS Emisiones_estimadas
FROM Venta v
JOIN Combustible c 
    ON v.Nombre_combustible = c.Nombre_combustible
   AND v.CUIT = c.CUIT
JOIN Estacion e 
    ON v.Numero_estacion = e.Numero_estacion
   AND v.CUIT = e.CUIT
GROUP BY e.Nombre_departamento, e.Nombre_provincia
ORDER BY Emisiones_estimadas DESC;


/* 6. Antigüedad promedio del parque vehicular por departamento */

SELECT 
    Nombre_departamento,
    Nombre_provincia,
    AVG(vejez) AS Vejez_promedio,
    COUNT(Patente) AS Cantidad_vehiculos
FROM Vehiculos
GROUP BY Nombre_departamento, Nombre_provincia
ORDER BY Vejez_promedio DESC;


/* 7. Estaciones cada 10.000 habitantes por departamento */

SELECT 
    d.Nombre_departamento,
    d.Nombre_provincia,
    d.habitantes,
    COUNT(e.Numero_estacion) AS Cantidad_estaciones,
    COUNT(e.Numero_estacion)::NUMERIC / d.habitantes * 10000 AS Estaciones_cada_10mil_habitantes
FROM Departamento d
LEFT JOIN Estacion e 
    ON d.Nombre_departamento = e.Nombre_departamento
   AND d.Nombre_provincia = e.Nombre_provincia
WHERE d.habitantes > 0
GROUP BY d.Nombre_departamento, d.Nombre_provincia, d.habitantes
ORDER BY Estaciones_cada_10mil_habitantes DESC;


/* 8. Ventas en días de temperatura alta */

SELECT 
    d.Fecha,
    d.Temp_max,
    SUM(v.Cantidad) AS Total_vendido
FROM Dia d
JOIN Venta v 
    ON d.Fecha = v.Fecha
WHERE d.Temp_max >= 35
GROUP BY d.Fecha, d.Temp_max
ORDER BY Total_vendido DESC;


/* 9. Ventas registradas durante eventos */

SELECT 
    ev.Descripcion,
    ev.Fecha_inicio,
    ev.Fecha_fin,
    SUM(v.Cantidad) AS Total_vendido
FROM Evento ev
JOIN Ocurre o 
    ON ev.ID_evento = o.ID_evento
JOIN Venta v 
    ON o.Fecha = v.Fecha
GROUP BY ev.ID_evento, ev.Descripcion, ev.Fecha_inicio, ev.Fecha_fin
ORDER BY Total_vendido DESC;


/* 10. Vehículos de flota por empresa y tipo */

SELECT 
    Nombre_empresa_flota,
    Tipo_vehiculo,
    COUNT(Patente) AS Cantidad_vehiculos
FROM Vehiculos_flota
GROUP BY Nombre_empresa_flota, Tipo_vehiculo
ORDER BY Nombre_empresa_flota, Cantidad_vehiculos DESC;


/* 11. Empresas con mayor volumen de combustible vendido */

SELECT 
    emp.Nombre_empresa,
    SUM(v.Cantidad) AS Total_vendido
FROM Venta v
JOIN Empresa emp 
    ON v.CUIT = emp.CUIT
GROUP BY emp.CUIT, emp.Nombre_empresa
ORDER BY Total_vendido DESC;


/* 12. Combustibles más vendidos */

SELECT 
    v.Nombre_combustible,
    emp.Nombre_empresa,
    COUNT(*) AS Cantidad_ventas,
    SUM(v.Cantidad) AS Total_vendido
FROM Venta v
JOIN Empresa emp 
    ON v.CUIT = emp.CUIT
GROUP BY v.Nombre_combustible, emp.Nombre_empresa
ORDER BY Total_vendido DESC;


/* 13. Departamentos con más de 100000 litros vendidos */

SELECT 
    e.Nombre_departamento,
    e.Nombre_provincia,
    SUM(v.Cantidad) AS Total_vendido
FROM Venta v
JOIN Estacion e 
    ON v.Numero_estacion = e.Numero_estacion
   AND v.CUIT = e.CUIT
GROUP BY e.Nombre_departamento, e.Nombre_provincia
HAVING SUM(v.Cantidad) > 100000
ORDER BY Total_vendido DESC;