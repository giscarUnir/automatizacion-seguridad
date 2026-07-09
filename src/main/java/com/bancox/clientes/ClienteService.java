package com.bancox.clientes;

import com.bancox.clientes.dto.ClienteDTO;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;
import jakarta.transaction.Transactional;
import jakarta.ws.rs.NotFoundException;
import jakarta.ws.rs.WebApplicationException;

import java.util.List;

@ApplicationScoped
public class ClienteService {

    @Inject
    ClienteRepository repository;

    public List<ClienteDTO> listar() {
        return repository.listAll().stream().map(ClienteService::toDTO).toList();
    }

    public ClienteDTO obtener(Long id) {
        Cliente c = repository.findById(id);
        if (c == null) {
            throw new NotFoundException("Cliente no encontrado");
        }
        return toDTO(c);
    }

    @Transactional
    public ClienteDTO crear(ClienteDTO dto) {
        if (repository.findByDocumento(dto.documento) != null) {
            throw new WebApplicationException("Documento ya registrado", 409);
        }
        Cliente c = new Cliente();
        c.documento = dto.documento;
        c.nombre = dto.nombre;
        c.email = dto.email;
        c.estado = dto.estado == null ? "ACTIVO" : dto.estado;
        repository.persist(c);
        return toDTO(c);
    }

    @Transactional
    public ClienteDTO actualizar(Long id, ClienteDTO dto) {
        Cliente c = repository.findById(id);
        if (c == null) {
            throw new NotFoundException("Cliente no encontrado");
        }
        c.nombre = dto.nombre;
        c.email = dto.email;
        if (dto.estado != null) {
            c.estado = dto.estado;
        }
        return toDTO(c);
    }

    @Transactional
    public void eliminar(Long id) {
        if (!repository.deleteById(id)) {
            throw new NotFoundException("Cliente no encontrado");
        }
    }

    private static ClienteDTO toDTO(Cliente c) {
        ClienteDTO dto = new ClienteDTO();
        dto.id = c.id;
        dto.documento = c.documento;
        dto.nombre = c.nombre;
        dto.email = c.email;
        dto.estado = c.estado;
        return dto;
    }
}
