package com.bancox.clientes;

import io.quarkus.test.junit.QuarkusTest;
import org.junit.jupiter.api.Test;

import static io.restassured.RestAssured.given;
import static org.hamcrest.Matchers.*;

@QuarkusTest
class ClienteResourceTest {

    private static final String BASE = "/banco-x/clientes/v1";

    @Test
    void listarDevuelveClientesSembrados() {
        given().when().get(BASE)
                .then().statusCode(200)
                .body("size()", greaterThanOrEqualTo(3));
    }

    @Test
    void obtenerPorIdExistente() {
        given().when().get(BASE + "/1")
                .then().statusCode(200)
                .body("documento", is("10010010"));
    }

    @Test
    void crearYValidarRechazaEmailInvalido() {
        given().contentType("application/json")
                .body("{\"documento\":\"99099099\",\"nombre\":\"X\",\"email\":\"no-es-email\",\"estado\":\"ACTIVO\"}")
                .when().post(BASE)
                .then().statusCode(400);
    }

    @Test
    void crearClienteValido() {
        given().contentType("application/json")
                .body("{\"documento\":\"88088088\",\"nombre\":\"Nuevo\",\"email\":\"nuevo@example.com\",\"estado\":\"ACTIVO\"}")
                .when().post(BASE)
                .then().statusCode(201)
                .body("id", notNullValue());
    }
}
