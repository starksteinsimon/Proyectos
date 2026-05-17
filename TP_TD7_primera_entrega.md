# Proyectos

# Sistema de Modelado de Reportes de Movilidad y Consumo de Combustible

Este proyecto fue desarrollado para la materia **Ingeniería de Datos (TD7)** en la **Universidad Torcuato Di Tella**. El propósito principal es modelar los datos necesarios para generar reportes analíticos de movilidad, reflejando el flujo de vehículos particulares y de flotas corporativas, la variación en el consumo de combustibles fósiles, y su impacto ecológico en función de variables climáticas, socioeconómicas y eventos externos.

---

## 📋 Estructura del Proyecto

El repositorio está organizado de la siguiente manera:
* `Analisis_Dominio.pdf`: Documento con el detalle del dominio, justificaciones de diseño técnico y supuestos de negocio adoptados.
* `Pasaje_a_modelo_relacional.pdf`: Documento con el pasaje a modelo relacional de DER.png.
* `DER.png`: Diagrama Entidad-Relación que ilustra el diseño conceptual del sistema.
* `Modelado_Fisico.sql`: Script DDL en SQL (compatible con PostgreSQL) para la creación automatizada de las tablas y sus restricciones de integridad.
* `Consultas.sql`: Set de 13 consultas SQL complejas diseñadas para extraer métricas e indicadores solicitados por el negocio.

---

## 📐 Diseño Lógico y Decisiones de Modelado

El diseño del modelo relacional fue estructurado bajo la **Forma Normal de Boyce-Codd (BCNF)** para mitigar anomalías de actualización y garantizar la consistencia referencial. Entre las decisiones clave de diseño aprobadas por la cátedra se destacan:

1. **Tratamiento de Entidades Débiles:** Las entidades `Estacion` y `Combustible` se modelaron como débiles dependientes de `Empresa`. Sus claves primarias son compuestas (incluyendo el `CUIT` de la empresa), lo que permite que distintas banderas manejen numeraciones internas idénticas sin colisiones de datos.
2. **Jerarquía Geográfica Estricta:** Se implementó una separación física para las entidades `Region`, `Provincia` y `Departamento` con el fin de asegurar mediante restricciones de clave foránea (`FK`) la integridad territorial, evitando relaciones recursivas ambiguas.
3. **Normalización del Parque Automotor y Rendimientos:** Para cumplir con la directiva de evaluar el impacto ambiental por rangos de edad vehicular sin introducir dependencias transitivas ni redundancia masiva en la tabla de unidades, se desacopló la entidad `Rendimiento_Referencia` como un maestro independiente indexado por una clave compuesta de `(Tipo_Vehiculo, Rango_Edad)`.
4. **La Venta como Evento Central:** La entidad `Venta` actúa como el nodo central del modelo. Enlaza de manera directa las dimensiones temporales (`Dia`), espaciales (`Estacion`), del producto (`Combustible`) y del consumidor (`Vehiculo` o `Vehiculo_flota`), admitiendo opcionalmente valores nulos para discriminar consumos particulares de logísticos corporativos.

---

### 💾 Capa de Modelo Relacional

A continuación se detalla el esquema lógico de tablas implementado (las claves primarias principales se encuentran **subrayadas** y las claves foráneas en *itálica*):

* **Region** (<u>Nombre_region</u>)
* **Provincia** (<u>Nombre_provincia</u>, *Nombre_region*)
* **Departamento** (<u>Nombre_departamento, Nombre_provincia</u>, habitantes, vehiculos, ingreso_per_capita)
* **Empresa** (<u>CUIT</u>, Nombre_empresa)
* **Estacion** (<u>Numero_estacion, CUIT</u>, *Nombre_departamento, Nombre_provincia*)
* **Combustible** (<u>Nombre_combustible, CUIT</u>, Tipo_combustible, Rendimiento, Valor_calorifico, Valor_emisiones)
* **Empresa_flota** (<u>Nombre_empresa_flota</u>)
* **Vehiculos** (<u>Patente</u>, *Nombre_departamento, Nombre_provincia*, Tipo_vehiculo, vejez, *Rango_edad*)
* **Vehiculos_flota** (<u>Patente</u>, *Nombre_departamento, Nombre_provincia*, Tipo_vehiculo, vejez, *Rango_edad*, *Nombre_empresa_flota*)
* **Dia** (<u>Fecha</u>, Temp_max, Temp_min, Tipo_dia)
* **Evento** (<u>ID_evento</u>, Descripción, Fecha_inicio, Fecha_fin)
* **Ocurre** (<u>*Fecha, ID_evento*</u>) -> *Tabla intermedia para la relación N:M entre Día y Evento.*
* **Venta** (<u>Numero_venta</u>, Tipo_venta, Cantidad, Destino, *Fecha*, *Patente_vehiculo*, *Patente_vehiculo_flota*, *Nombre_combustible*, *Numero_estacion*, *CUIT*)

---

## 🛠️ Tecnologías Utilizadas

* **Motor de Base de Datos:** PostgreSQL 15+
* **Herramientas de Diseño:** VS Code + Extensiones de Gestión de Bases de Datos (SQLTools, Database Client).
* **Lenguaje:** SQL Estándar / PostgreSQL Dialect.

---

## 📊 Consultas Analíticas (Casos de Uso)

El archivo `Consultas.sql` contiene trece consultas estructuradas que resuelven los requerimientos de reportería esenciales del enunciado, haciendo uso intensivo de operaciones `JOIN` y agrupamientos `GROUP BY`. Las principales métricas cubiertas incluyen:

* Consumo total fósil consolidado por niveles geográficos (`Region` y `Provincia`).
* Desagregación de despachos de Gasoil a granel orientados de forma específica a actividades productivas (`Agro` vs `Industria`).
* Estimación volumétrica de emisiones de carbono ($g/km$) por `Departamento`.
* Correlación de variaciones en la demanda comercial de combustible frente a anomalías meteorológicas (días de calor extremo $>35°C$) y marcos cronológicos de contingencias externas (`Evento`).
* Construcción de indicadores sociales de infraestructura corporativa y movilidad (unidades operativas por firmas logísticas y densidad de estaciones por habitante).
