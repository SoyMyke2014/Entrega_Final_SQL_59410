USE rac_ar;

DELIMITER $$

CREATE PROCEDURE registrar_nuevo_alquiler(
    IN cliente_id INT,
    IN auto_id INT,
    IN dias_alquiler INT,
    IN tarifa_id INT,
    IN metodo_pago VARCHAR(30)
)
BEGIN
    DECLARE valor_unitario DECIMAL(10,2);
    DECLARE nuevo_pago_id INT;

    SELECT precio_diario INTO valor_unitario FROM tarifas WHERE id_tarifa = tarifa_id;

    INSERT INTO pago (id_tarifa, fecha_transaccion, metodo_pago)
    VALUES (tarifa_id, NOW(), metodo_pago);

    SET nuevo_pago_id = LAST_INSERT_ID();

    INSERT INTO alquileres (fecha_inicio, cantidad_dias, id_cliente, id_auto, id_pago)
    VALUES (NOW(), dias_alquiler, cliente_id, auto_id, nuevo_pago_id);
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE obtener_clientes_frecuentes(
    IN min_alquileres INT
)
BEGIN
    SELECT c.id_cliente, c.nombre, c.apellido, COUNT(a.id_alquiler) AS total_alquileres
    FROM clientes c
    JOIN alquileres a ON c.id_cliente = a.id_cliente
    GROUP BY c.id_cliente, c.nombre, c.apellido
    HAVING total_alquileres >= min_alquileres;
END$$

DELIMITER ;
