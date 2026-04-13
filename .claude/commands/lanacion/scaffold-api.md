# scaffold-api

## Descripción
Scaffoldea una nueva Minimal API en el monorepo Nx + .NET usando el generador corporativo. Wrapper conversacional sobre la skill `scaffold-monorepo-backend-app` con `templateType: ln-minWebApi`.

## Sintaxis
```
/scaffold-api [ProjectName] [HttpPort?] [HttpsPort?] [OrderRelease?]
```

## Parámetros
- **ProjectName** (requerido): Nombre del proyecto (ej: `LN.Sus.Cobros.Api`)
- **HttpPort** (opcional): Puerto HTTP local (ej: `5010`). Se pedirá si no se indica
- **HttpsPort** (opcional): Puerto HTTPS local (ej: `5011`). Se pedirá si no se indica
- **OrderRelease** (opcional): Orden de release (ej: `10`). Se pedirá si no se indica

## Referencia
Adoptar el rol de `ai-specs/.agents/lanacion-nx-monorepo-developer.md` y ejecutar la skill:
- `ai-specs/.skills/scaffold-monorepo-backend-app/SKILL.md`
- Estándares post-generación: `ai-specs/specs/ln-susc-api-standards.mdc`

## Precondiciones

Verificar antes de ejecutar:
- [ ] Node.js 20 disponible
- [ ] npm disponible
- [ ] .NET SDK 6 disponible
- [ ] `package.json` y `nx.json` en la raíz del repo
- [ ] `NuGet.config` con acceso al feed corporativo
- [ ] Solución global (`.sln`) existe

## Proceso

1. Confirmar o solicitar los parámetros faltantes
2. Ejecutar el generador:
```bash
npm run generate:template
# Seleccionar: Minimal API (ln-minWebApi)
# Nombre: [ProjectName]
# Puerto HTTP: [HttpPort]
# Puerto HTTPS: [HttpsPort]
# OrderRelease: [OrderRelease]
```
3. Verificar estructura generada bajo `apps/[ProjectName]/`
4. Ejecutar `validate-monorepo-integration` automáticamente
5. Reportar resultado

## Estructura Esperada

```
apps/[ProjectName]/
  project.json
  Dockerfile
  .dockerignore
  cdk/
  src/
  tests/
```

## Validación Post-Scaffold

```bash
npx nx run [ProjectName]:build
npx nx run [ProjectName]:test
```

## Output

Siempre reportar:
- **Artifact Type**: API
- **Project Path**: `apps/[ProjectName]/`
- **Integration Status**: `.sln`, `project.json`, `cdk/`, tests
- **Known Caveats**: elementos que requieren revisión manual
- **Next Step**: usar `lanacion-api-developer` para implementar la lógica de negocio

## Ejemplo

```
/scaffold-api LN.Sus.Cobros.Api 5010 5011 10
```

Genera la API bajo `apps/LN.Sus.Cobros.Api/` completamente integrada en el monorepo.
