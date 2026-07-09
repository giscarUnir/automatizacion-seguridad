package com.bancox.clientes;

import io.quarkus.hibernate.orm.panache.PanacheEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Table;

/**
 * Entidad Cliente (datos ficticios de "Banco X" para la demo de seguridad).
 * No representa informacion real de ninguna persona.
 */
@Entity
@Table(name = "cliente")
public class Cliente extends PanacheEntity {

    @Column(nullable = false, unique = true)
    public String documento;

    @Column(nullable = false)
    public String nombre;

    @Column(nullable = false)
    public String email;

    @Column(nullable = false)
    public String estado; // ACTIVO / INACTIVO
}
