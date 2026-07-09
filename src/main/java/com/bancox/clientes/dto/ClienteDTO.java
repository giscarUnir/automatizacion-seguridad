package com.bancox.clientes.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;

/**
 * DTO de entrada/salida. Aplica validacion de Bean Validation:
 * evita datos malformados y reduce superficie de inyeccion.
 */
public class ClienteDTO {

    public Long id;

    @NotBlank(message = "documento es obligatorio")
    @Pattern(regexp = "\\d{6,15}", message = "documento debe ser numerico de 6 a 15 digitos")
    public String documento;

    @NotBlank(message = "nombre es obligatorio")
    public String nombre;

    @NotBlank(message = "email es obligatorio")
    @Email(message = "email invalido")
    public String email;

    @Pattern(regexp = "ACTIVO|INACTIVO", message = "estado debe ser ACTIVO o INACTIVO")
    public String estado;
}
