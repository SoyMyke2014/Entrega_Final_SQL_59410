USE rac_ar;

CREATE VIEW v_informacion_cliente AS
SELECT 
    c.id_cliente,
    c.nombre,
    c.apellido,
    c.documento,
    c.mail,
    a.id_alquiler,
    a.fecha_inicio,
    f.marca,
    f.modelo,
    h.kilometraje,
    h.estatus_devolucion
FROM cliente c
JOIN alquileres a ON c.id_cliente = a.id_cliente
JOIN flota_de_autos f ON a.id_auto = f.id_auto
LEFT JOIN historial h ON a.id_alquiler = h.id_alquiler;


CREATE VIEW v_revisiones_pendientes AS
SELECT 
    r.id_revision,
    f.marca,
    f.modelo,
    r.fecha_revision,
    r.descripcion_problema,
    r.resultado,
    t.nombre AS tecnico_asignado,
    t.especialidad
FROM revision r
JOIN flota_de_autos f ON r.id_auto = f.id_auto
JOIN tecnico_revision t ON r.id_tecnico = t.id_tecnico
WHERE r.resultado IS NULL;

CREATE VIEW v_resumen_pago_alquiler AS
SELECT 
    p.id_pago,
    a.id_alquiler,
    c.nombre,
    c.apellido,
    p.fecha_transaccion,
    p.metodo_pago,
    t.precio_diario AS tarifa_alquiler,
    COALESCE(ad.costo_serv_adic, 0) AS costo_adicional,
    (t.precio_diario + COALESCE(ad.costo_serv_adic, 0)) AS total_pagado
FROM pago p
JOIN alquileres a ON p.id_pago = a.id_pago
JOIN cliente c ON a.id_cliente = c.id_cliente
JOIN tarifas t ON p.id_tarifa = t.id_tarifa
LEFT JOIN adicionales ad ON p.id_adicional = ad.id_adicional;

CREATE VIEW v_sucursales_ventas_rrhh AS
-- Vista que le permite a RRHH visualizar cual esel ingreso que tiene cada sucursal.
SELECT 
    s.id_sucursal,
    s.nombre_sucursal,
    COUNT(DISTINCT a.id_alquiler) AS total_alquileres,
    SUM(calcular_valor_alquiler(a.cantidad_dias, t.precio_diario)) AS ingresos_totales
FROM 
    sucursales s
JOIN 
    flota_de_autos f ON s.id_sucursal = f.id_sucursal
JOIN 
    alquileres a ON f.id_auto = a.id_auto
JOIN 
    pago p ON a.id_pago = p.id_pago
JOIN 
    tarifas t ON p.id_tarifa = t.id_tarifa
GROUP BY 
    s.id_sucursal, s.nombre_sucursal
ORDER BY 
    ingresos_totales DESC;
