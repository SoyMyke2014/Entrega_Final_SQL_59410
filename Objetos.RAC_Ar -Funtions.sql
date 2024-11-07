USE rac_ar;

DELIMITER $$

CREATE FUNCTION calcular_valor_alquiler(
    dias_alquiler INT,
    valor_unitario DECIMAL(10,2)
)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE valor_final DECIMAL(10,2);
    
    SET valor_final = dias_alquiler * valor_unitario;

    RETURN valor_final;
END$$

DELIMITER ;


DELIMITER $$

CREATE FUNCTION promedio_ingresos_por_alquiler()
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE promedio_ingresos DECIMAL(10,2);
    
    SELECT AVG(t.precio_diario * a.cantidad_dias + COALESCE(ad.costo_serv_adic, 0))
    INTO promedio_ingresos
    FROM alquileres a
    JOIN pago p ON a.id_pago = p.id_pago
    JOIN tarifas t ON p.id_tarifa = t.id_tarifa
    LEFT JOIN adicionales ad ON p.id_adicional = ad.id_adicional;

    RETURN promedio_ingresos;
END$$

DELIMITER ;


