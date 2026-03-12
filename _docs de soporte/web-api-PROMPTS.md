# 🤖 Prompts para LLMs (ChatGPT / Copilot / Claude)
Este documento contiene una serie de **prompts estructurados y detallados** que puedes copiar y pegar en tu IA favorita para generar código que cumpla estrictamente con la arquitectura `LaNacion.Core.Templates.Web.Api.Minimal`.

---

## 🏗️ Prompt 1: Crear un Endpoint de Web API de Punta a Punta (Command / Mutation)
*Usa este prompt cuando necesites crear un endpoint que modifique el estado del sistema (Crear, Actualizar, Borrar).*

> **Copia y pega el siguiente texto:**
>
> Actúa como un Arquitecto de Software Senior especializado en .NET 6 Minimal APIs y Clean Architecture. Necesito crear un nuevo caso de uso (Command) para mi dominio.
> 
> **Requerimientos del Negocio:**
> [DESCRIBE AQUÍ QUÉ DEBE HACER EL ENDPOINT. Ej: "Crear un nuevo usuario con Nombre, Apellido y Email"].
> 
> **Restricciones Arquitectónicas Obligatorias:**
> 1. **Application Layer (CQRS):** Crea un `{Accion}{Entidad}Command` que implemente `IRequest<Guid>`. Crea su validador usando FluentValidation (`AbstractValidator`).
> 2. **Application Layer (Handler):** Crea el `IRequestHandler`. Dentro de su método `Handle`, debes:
>    - Inyectar `IUnitOfWork`, un Repositorio específico y el publicador `IMessagePublisher`.
>    - Abrir una transacción de base de datos (`using var tx = _uoW.BeginTransaction()`).
>    - Invocar al repositorio para persistir la entidad.
>    - Publicar un evento asincrónico en la misma transacción mediante `await _publisher.CreateMessageAsync(..., "evt-{squad}-{entidad}-{verbo-pasado}", ...)`.
>    - Hacer `_uoW.Commit()`.
> 3. **Presentation Layer:** Crea un `IEndpointDefinition` que mapee la ruta mediante `.MapPost()`, `.MapPut()` o `.MapDelete()`. Asegúrate de que la URI use minúsculas, sea un sustantivo en plural separada por guiones (Kebab-case) y NO contenga verbos CRUD (Ej: `/api/v1/usuarios`, NO `/crear-usuario`).
> 4. Retorna `Results.Created` (o `200 OK`) usando el resultado del mediador.
>
> Proporcióname el código exacto de cada capa, respetando aislamientos (el dominio no conoce la UI ni la DB) y sin bloques `try-catch` capturando "Exception" (asumir middleware global).

---

## 🔍 Prompt 2: Crear un Endpoint de Web API de Punta a Punta (Query / Read-Only)
*Usa este prompt cuando necesites un endpoint que solo lea datos (Obtener, Listar, Buscar).*

> **Copia y pega el siguiente texto:**
>
> Actúa como un Arquitecto de Software Senior especializado en .NET 6 Minimal APIs. Necesito crear un nuevo caso de uso de solo lectura (Query).
> 
> **Requerimientos del Negocio:**
> [DESCRIBE AQUÍ QUÉ DATOS SE DEBEN BUSCAR. Ej: "Obtener un usuario por su ID" o "Listar todos los usuarios activos"].
> 
> **Restricciones Arquitectónicas Obligatorias:**
> 1. **Application Layer:** Crea un `{Accion}{Entidad}Query` que implemente `IRequest<ResponseDto>`.
> 2. **Application Layer (Handler):** Crea su Handler correspondiente. A diferencia de los Commands, aquí NO DEBES abrir una transacción (`BeginTransaction`). Simplemente inyecta el repositorio, realiza la llamada a los datos (`_repo.GetByIdAsync(...)`) y utiliza AutoMapper para devolver el DTO esperado en el response.
> 3. **Presentation Layer:** Crea un `IEndpointDefinition` usando `.MapGet()`. La ruta debe ser RESTful (Ej: `/api/v1/usuarios/{id}`).
> 4. Utiliza nomenclatura Kebab-case, minúsculas y plurales en la URL. Devuelve `Results.Ok(...)` o `Results.NotFound(...)`.
> 
> Redacta el código completo de la query, el handler, posibles DTOs a devolver y el mapeo del endpoint.

---

## 💾 Prompt 3: Crear un Nuevo Repositorio de Base de Datos (Dapper)
*Usa este prompt para agregar un nuevo agregador de persistencia a la Capa de Infraestructura.*

> **Copia y pega el siguiente texto:**
>
> Como desarrollador experto en Dapper y Clean Architecture para .NET 6, necesito crear un nuevo repositorio.
> 
> **Contexto:** 
> La entidad de dominio se llama `[NOMBRE_ENTIDAD]`, y debe mapear hacia la tabla SQL llamada `[NOMBRE_TABLA]`. Necesito las operaciones de [CRUD / CONSULTA ESPECIFICA].
> 
> **Restricciones Arquitectónicas Obligatorias:**
> 1. **Definición Abstracta:** Define una interfaz en la capa de `Application.Interfaces` que herede de `IRepository<[NombreEntidad], Guid>` (o el tipo de Id correspondiente).
> 2. **Implementación Concreta:** En la capa `Repositories.SQL` (Infrastructure), crea la clase concreta que herede de `BaseRepository<[NombreEntidad], Guid>` e implemente la interfaz anterior.
> 3. **Dapper:** Debes utilizar sintaxis directa de Dapper haciendo uso explicito de la conexión inyectada, orquestada junto con la transacción de unidad de trabajo (Unit of Work). Ejemplo: `await _context.Connection.ExecuteAsync("INSERT...", parameters, transaction: base.Transaction)`. Escribe al menos un insert, un update o un select con JOIN de ejemplo demostrando la sentencia SQL en crudo.
> 4. **Inyección de Dependencias:** Muestra exactamente el código necesario (ej: `services.AddScoped<I[Entidad]Repository, [Entidad]Repository>()`) que debe agregarse en el inicio de la aplicación para enlazar ambas piezas.

---

## 🔌 Prompt 4: Integrar un Cliente de Servicio WCF Legacy (Adapter Pattern)
*Usa este prompt para interconectar tu núcleo moderno con un viejo sistema SOAP.*

> **Copia y pega el siguiente texto:**
>
> Actúa como un Arquitecto de Software .NET. Debo consumir un servicio WCF SOAP legacy asumiendo que ya generé el código proxy en mi proyecto usando `dotnet-svcutil`.
> 
> **Servicio Objetivo:** 
> El proxy cliente local generado se llama `[NombreClienteWcfServiceClient]` y necesitamos exponer su funcionalidad de buscar [DETALLAR OPERACIÓN DEL SERVICIO].
> 
> **Restricciones de Diseño Estrictas:**
> 1. **Prohibido el Acoplamiento:** La capa de `Application` y `Domain` NO puede tener dependencias ni referencias a los DataContracts nativos del proxy WCF ni al espacio de nombre `System.ServiceModel`.
> 2. **Interface Adaptadora:** Debes crear una interfaz pura de C# (`I[NombreDelServicio]`) en `Application.Interfaces` exponiendo métodos asíncronos que devuelvan clases puras o arreglos de nuestras propias Entidades de Dominio.
> 3. **Implementación Wrapper (Adapter Pattern):** Crea la clase implementadora en la capa `Infrastructure.Services`. Debe inyectar en su constructor el cliente SOAP generado (`[NombreClienteWcfServiceClient]`) y tu librería `IMapper` (AutoMapper). Consume el endpoint nativo, recibe los DataContracts SOAP, y haz un `.Map<T>()` de vuelta a tu Entidad de Dominio antes de un retorno `return`. 
> 4. **Configuración e Inyección de Dependencias (DI):**  Muestra el fragmento de código final (`AddScoped`) para añadir en `Program.cs` o las `Extensions` de inicialización. A la hora de registrar la instancia delegada del `*ServiceClient` nativo, enséñame a configurar estáticamente un `EndpointAddress` que lea el valor de `appsettings.json`, junto con su `BasicHttpBinding` habilitando modo `Transport` si es HTTPS.
