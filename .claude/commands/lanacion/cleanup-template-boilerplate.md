# cleanup-template-boilerplate

## Descripción
Elimina el código de boilerplate del template que no corresponde a la HU actual. Aplica tanto a APIs (`ln-minWebApi`) como a listeners (`ln-SQSlstnr`). Debe ejecutarse como último paso antes de hacer commit.

## Sintaxis
```
/cleanup-template-boilerplate [ProjectPath] [HuScope?]
```

## Parámetros
- **ProjectPath** (requerido): Ruta al proyecto (ej: `apps/LN.Sus.MiApi`)
- **HuScope** (opcional): Descripción breve del scope de la HU para guiar qué conservar (ej: `"gestión de suscripciones"`)

## Referencia
Consultar:
- `ai-specs/specs/ln-susc-api-standards.mdc` → sección HU Cleanup
- `ai-specs/specs/ln-susc-listener-standards.mdc` → sección HU Cleanup

## Proceso

1. Identificar el tipo de template (API o Listener)
2. Listar archivos de ejemplo/demo generados por el template
3. Verificar cuáles NO están relacionados con la HU actual
4. Eliminar los archivos no relacionados
5. Limpiar registros DI huérfanos en `Program.cs` / `ConfigureServicesExtensions.cs`
6. Verificar que el proyecto compila tras la limpieza

## Elementos a Eliminar (API - ln-minWebApi)

```
src/
  Domain/Entities/WeatherForecast.cs          ← ejemplo del template
  Application/Queries/GetWeatherQuery.cs      ← ejemplo del template
  Application/Handlers/GetWeatherHandler.cs   ← ejemplo del template
  Api/Endpoints/WeatherEndpoints.cs           ← ejemplo del template
```

## Elementos a Eliminar (Listener - ln-SQSlstnr)

```
src/
  Domain/Events/v1/SampleEvent.cs             ← ejemplo del template
  Application/SampleEventProcessor.cs         ← ejemplo del template
```

## Registros DI a Limpiar

Buscar y eliminar en `Program.cs` o `ConfigureServicesExtensions.cs`:
```csharp
// Eliminar registros de servicios de ejemplo no relacionados con la HU
services.AddScoped<ISampleRepository, SampleRepository>(); // ← si no es de la HU
```

## Validación Post-Limpieza

```bash
# Verificar que compila sin errores
dotnet build [ProjectPath]

# Verificar que los tests pasan
dotnet test [ProjectPath]
```

## Checklist

- [ ] Archivos de ejemplo del template eliminados
- [ ] Registros DI huérfanos eliminados
- [ ] Sin referencias rotas (build limpio)
- [ ] Tests pasan
- [ ] Solo queda código relacionado con la HU actual

## Ejemplo

```
/cleanup-template-boilerplate apps/LN.Sus.Cobros.Api "procesamiento de cobros"
```

Elimina todos los archivos de ejemplo del template que no estén relacionados con el procesamiento de cobros.
