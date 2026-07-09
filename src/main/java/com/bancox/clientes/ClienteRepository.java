package com.bancox.clientes;

import io.quarkus.hibernate.orm.panache.PanacheRepository;
import jakarta.enterprise.context.ApplicationScoped;

/**
 * Repositorio Panache. Las consultas usan parametros vinculados (no
 * concatenacion de strings), lo que evita inyeccion SQL por diseno.
 */
@ApplicationScoped
public class ClienteRepository implements PanacheRepository<Cliente> {

    public Cliente findByDocumento(String documento) {
        // Consulta parametrizada: el valor NO se concatena en el SQL.
        return find("documento", documento).firstResult();
    }
}
