package com.bancox.clientes;

import jakarta.inject.Inject;
import jakarta.persistence.EntityManager;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.QueryParam;
import jakarta.ws.rs.core.MediaType;

import java.util.List;

/**
 * DEMO INSEGURO (a proposito). NO usar como referencia.
 * Evidencia dos controles: inyeccion SQL y credencial en el codigo.
 */
@Path("/banco-x/clientes/v1/inseguro")
@Produces(MediaType.APPLICATION_JSON)
public class BusquedaInseguraResource {

    @Inject
    EntityManager em;

    // Credencial hardcodeada (DEMO) -> CodeQL / Semgrep / Gitleaks
    private static final String API_KEY = "AKIAQWERTYUIOPASDFGH";

    @GET
    @Path("/buscar")
    @SuppressWarnings("unchecked")
    public List<Cliente> buscar(@QueryParam("doc") String doc) {
        // VULNERABLE (DEMO): concatenacion directa del parametro -> INYECCION SQL
        String sql = "SELECT * FROM cliente WHERE documento = '" + doc + "'";
        return em.createNativeQuery(sql, Cliente.class).getResultList();
    }
}
