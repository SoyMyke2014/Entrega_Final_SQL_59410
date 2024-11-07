USE rac_ar;

DELIMITER $$

CREATE TRIGGER verificar_disponibilidad_auto

BEFORE INSERT ON alquileres
FOR EACH ROW
BEGIN
    DECLARE auto_disponible TINYINT;

    SELECT disponibilidad INTO auto_disponible
    FROM flota_de_autos
    WHERE id_auto = NEW.id_auto;

    IF auto_disponible = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El auto seleccionado no está disponible para alquiler.';
    END IF;
END$$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER auditoria_actualizacion_tarifa
AFTER UPDATE ON tarifas
FOR EACH ROW
BEGIN
    
    INSERT INTO auditoria_tarifas (id_tarifa, precio_anterior, precio_nuevo, fecha_actualizacion)
    VALUES (OLD.id_tarifa, OLD.precio_diario, NEW.precio_diario, NOW());
END$$

DELIMITER ;