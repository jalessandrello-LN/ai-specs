# integrate-wcf-service

## Descripción
Integra un servicio WCF SOAP legacy usando Adapter Pattern para mantener Clean Architecture.

## Sintaxis
```
/integrate-wcf-service [ServiceName] [Operation] [WsdlUrl]
```

## Parámetros
- **ServiceName** (requerido): Nombre del servicio WCF (ej: `VentasConsultas`)
- **Operation** (requerido): Operación a exponer (ej: `GetCliente`, `BuscarOrdenes`)
- **WsdlUrl** (requerido): URL del WSDL del servicio

## Referencia
Consultar `ai-specs/specs/ln-susc-api-standards.mdc` para:
- WCF Integration patterns
- Adapter Pattern
- Clean Architecture boundaries

## Paso 1: Generar Proxy WCF

```bash
dotnet-svcutil {WsdlUrl} -pf LaNacion.Suscripciones.Services.csproj
```

Esto genera el cliente WCF: `{ServiceName}Client.cs`

## Archivos Generados

### 2. Interface Adaptadora (Application.Interfaces)
**Archivo**: `Application.Interfaces/I{ServiceName}.cs`

```csharp
using System.Threading.Tasks;
using LaNacion.Suscripciones.Domain;

namespace LaNacion.Suscripciones.Application.Interfaces
{
    /// <summary>
    /// Abstracción pura sin dependencias a WCF
    /// </summary>
    public interface I{ServiceName}
    {
        Task<Cliente> GetClienteAsync(string clienteId);
        Task<List<Orden>> BuscarOrdenesAsync(string criterio);
    }
}
```

**IMPORTANTE**: 
- ❌ NO usar DataContracts de WCF
- ❌ NO referenciar System.ServiceModel
- ✅ Solo usar entidades de dominio puras

### 3. Implementación Adapter (Services)
**Archivo**: `Services/{ServiceName}Adapter.cs`

```csharp
using System;
using System.Threading.Tasks;
using AutoMapper;
using LaNacion.Suscripciones.Application.Interfaces;
using LaNacion.Suscripciones.Domain;

namespace LaNacion.Suscripciones.Services
{
    public class {ServiceName}Adapter : I{ServiceName}
    {
        private readonly {ServiceName}Client _wcfClient;
        private readonly IMapper _mapper;

        public {ServiceName}Adapter(
            {ServiceName}Client wcfClient,
            IMapper mapper)
        {
            _wcfClient = wcfClient;
            _mapper = mapper;
        }

        public async Task<Cliente> GetClienteAsync(string clienteId)
        {
            // Call SOAP endpoint
            var soapResult = await _wcfClient.GetClienteAsync(clienteId);
            
            // Map SOAP DataContract to Domain Entity
            return _mapper.Map<Cliente>(soapResult);
        }

        public async Task<List<Orden>> BuscarOrdenesAsync(string criterio)
        {
            var soapResults = await _wcfClient.BuscarOrdenesAsync(criterio);
            return _mapper.Map<List<Orden>>(soapResults);
        }
    }
}
```

### 4. AutoMapper Profile
**Archivo**: `Services/Mappings/{ServiceName}Profile.cs`

```csharp
using AutoMapper;
using LaNacion.Suscripciones.Domain;

namespace LaNacion.Suscripciones.Services.Mappings
{
    public class {ServiceName}Profile : Profile
    {
        public {ServiceName}Profile()
        {
            // Map SOAP DataContract to Domain Entity
            CreateMap<{ServiceName}Client.ClienteDataContract, Cliente>()
                .ForMember(dest => dest.Id, opt => opt.MapFrom(src => src.ClienteId))
                .ForMember(dest => dest.Nombre, opt => opt.MapFrom(src => src.NombreCompleto));
        }
    }
}
```

### 5. Dependency Injection
**Archivo**: `Api/Extensions/WcfServicesExtensions.cs`

```csharp
using System;
using System.ServiceModel;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using LaNacion.Suscripciones.Application.Interfaces;
using LaNacion.Suscripciones.Services;

namespace LaNacion.Suscripciones.Api.Extensions
{
    public static class WcfServicesExtensions
    {
        public static IServiceCollection Add{ServiceName}(
            this IServiceCollection services,
            IConfiguration configuration)
        {
            // Register Adapter
            services.AddScoped<I{ServiceName}, {ServiceName}Adapter>();

            // Register WCF Client
            services.AddScoped<{ServiceName}Client>(provider =>
            {
                var endpointUrl = configuration["WCF:{ServiceName}:Endpoint"];
                var endpoint = new EndpointAddress(endpointUrl);
                
                var binding = new BasicHttpBinding
                {
                    Name = "{ServiceName}Soap",
                    MaxReceivedMessageSize = 2147483647,
                    MaxBufferSize = 2147483647
                };

                // Enable Transport security for HTTPS
                if (endpoint.Uri.Scheme == "https")
                {
                    binding.Security.Mode = BasicHttpSecurityMode.Transport;
                }

                return new {ServiceName}Client(binding, endpoint);
            });

            return services;
        }
    }
}
```

### 6. Configuration (appsettings.json)

```json
{
  "WCF": {
    "{ServiceName}": {
      "Endpoint": "https://legacy-system.lanacion.com.ar/services/{ServiceName}.svc"
    }
  }
}
```

### 7. Register in Program.cs

```csharp
builder.Services.Add{ServiceName}(builder.Configuration);
```

## Arquitectura del Adapter Pattern

```
Application Layer (Pure)
├── I{ServiceName} (interface)
    ↓ (implemented by)
Infrastructure Layer
├── {ServiceName}Adapter
    ↓ (uses)
    ├── {ServiceName}Client (WCF proxy)
    └── IMapper (AutoMapper)
```

## Principios Clave

### ✅ DO

1. **Aislar WCF**: Solo en capa de Infrastructure
2. **Interfaces Puras**: Sin referencias a System.ServiceModel
3. **Mapeo Explícito**: SOAP DataContracts → Domain Entities
4. **Configuración Externa**: URLs en appsettings.json
5. **HTTPS Support**: Habilitar Transport security

### ❌ DON'T

1. **NO exponer DataContracts**: En Application o Domain
2. **NO hardcodear URLs**: Siempre usar configuración
3. **NO acoplar**: Domain no debe conocer WCF
4. **NO omitir mapeo**: Siempre usar AutoMapper
5. **NO ignorar seguridad**: Configurar binding correctamente

## Ejemplo

```
/integrate-wcf-service VentasConsultas GetCliente https://legacy.lanacion.com.ar/VentasConsultas.svc?wsdl
```

Genera:
1. Proxy WCF (via dotnet-svcutil)
2. `IVentasConsultas.cs` (interface pura)
3. `VentasConsultasAdapter.cs` (implementación)
4. `VentasConsultasProfile.cs` (AutoMapper)
5. `WcfServicesExtensions.cs` (DI configuration)

## Validaciones

- ✅ Proxy generado con dotnet-svcutil
- ✅ Interface sin dependencias WCF
- ✅ Adapter usa AutoMapper
- ✅ Binding configurado correctamente
- ✅ HTTPS habilitado si corresponde
- ✅ URL en appsettings.json
