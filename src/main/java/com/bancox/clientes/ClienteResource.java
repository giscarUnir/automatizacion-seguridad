package com.bancox.clientes;

import com.bancox.clientes.dto.ClienteDTO;
import jakarta.inject.Inject;
import jakarta.validation.Valid;
import jakarta.ws.rs.*;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;
import jakarta.ws.rs.core.UriBuilder;

import java.util.List;

/**
 * CRUD de clientes de "Banco X" (demo). Version SEGURA:
 * - Validacion de entrada con @Valid.
 * - Acceso a datos parametrizado (sin concatenacion SQL).
 * - Sin secretos ni credenciales en el codigo.
 */
@Path("/banco-x/clientes/v1")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
public class ClienteResource {

    @Inject
    ClienteService service;

    @GET
    public List<ClienteDTO> listar() {
        return service.listar();
    }

    @GET
    @Path("/{id}")
    public ClienteDTO obtener(@PathParam("id") Long id) {
        return service.obtener(id);
    }

    @POST
    public Response crear(@Valid ClienteDTO dto) {
        ClienteDTO creado = service.crear(dto);
        return Response.created(UriBuilder.fromResource(ClienteResource.class)
                .path(String.valueOf(creado.id)).build()).entity(creado).build();
    }

    @PUT
    @Path("/{id}")
    public ClienteDTO actualizar(@PathParam("id") Long id, @Valid ClienteDTO dto) {
        return service.actualizar(id, dto);
    }

    @DELETE
    @Path("/{id}")
    public Response eliminar(@PathParam("id") Long id) {
        service.eliminar(id);
        return Response.noContent().build();
    }
}
