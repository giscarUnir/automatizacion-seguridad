-- Datos ficticios para la demo. No son personas reales.
INSERT INTO cliente (id, documento, nombre, email, estado) VALUES (1, '10010010', 'Ana Demo', 'ana.demo@example.com', 'ACTIVO');
INSERT INTO cliente (id, documento, nombre, email, estado) VALUES (2, '20020020', 'Beto Prueba', 'beto.prueba@example.com', 'ACTIVO');
INSERT INTO cliente (id, documento, nombre, email, estado) VALUES (3, '30030030', 'Caro Test', 'caro.test@example.com', 'INACTIVO');
ALTER TABLE cliente ALTER COLUMN id RESTART WITH 4;
