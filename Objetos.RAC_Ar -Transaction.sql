USE rac_ar;

DELIMITER $$

CREATE PROCEDURE registrar_nuevo_cliente_y_alquiler(
    IN nombre_cliente VARCHAR(50),
    IN dni_cliente VARCHAR(20),
    IN direccion_cliente VARCHAR(100),
    IN telefono_cliente VARCHAR(15),
    IN email_cliente VARCHAR(50),
    IN id_sucursal INT,
    IN id_auto INT,
    IN id_tarifa INT,
    IN id_adicional INT,
    IN cantidad_dias INT
)
BEGIN
    DECLARE cliente_id INT DEFAULT NULL;
    DECLARE alquiler_id INT DEFAULT NULL;

    START TRANSACTION;

    SELECT id_cliente INTO cliente_id
    FROM clientes
    WHERE dni = dni_cliente;

    IF cliente_id IS NOT NULL THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El cliente ya existe';
    ELSE
        INSERT INTO clientes (nombre, dni, direccion, telefono, email)
        VALUES (nombre_cliente, dni_cliente, direccion_cliente, telefono_cliente, email_cliente);

        SET cliente_id = LAST_INSERT_ID();

        INSERT INTO alquileres (id_cliente, id_sucursal, id_auto, cantidad_dias)
        VALUES (cliente_id, id_sucursal, id_auto, cantidad_dias);

        SET alquiler_id = LAST_INSERT_ID();

        INSERT INTO pago (id_alquiler, id_tarifa, id_adicional, monto_total)
        VALUES (
            alquiler_id,
            id_tarifa,
            id_adicional,
            (SELECT precio_diario FROM tarifas WHERE id_tarifa = id_tarifa) * cantidad_dias +
            COALESCE((SELECT costo_serv_adic FROM adicionales WHERE id_adicional = id_adicional), 0)
        );

        COMMIT;
    END IF;
END$$

DELIMITER ;
