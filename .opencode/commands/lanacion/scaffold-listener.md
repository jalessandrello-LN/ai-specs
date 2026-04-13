# scaffold-listener

## Descripción
Scaffoldea un nuevo listener SQS en el monorepo Nx + .NET usando el generador corporativo. Wrapper conversacional sobre la skill `scaffold-monorepo-backend-app` con `templateType: ln-SQSlstnr`.

## Sintaxis
```
/scaffold-listener [ProjectName] [OrderRelease?]
```

## Parámetros
- **ProjectName** (requerido): Nombre del proyecto (ej: `LN.Sus.Ventas.Listener`)
- **OrderRelease** (opcional): Orden de release (ej: `20`). Se pedirá si no se indica

## Referencia
Adoptar el rol de `ai-specs/.agents/lanacion-nx-monorepo-developer.md` y ejecutar la skill:
- `ai-specs/.skills/scaffold-monorepo-backend-app/SKILL.md`
- Estándares post-generación: `ai-specs/specs/ln-susc-listener-standards.mdc`

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
# Seleccionar: Listener (ln-SQSlstnr)
# Nombre: [ProjectName]
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
    Domain/Events/v1/
    Application/          ← processors
    Workers/              ← ConfigureServicesExtensions.cs
  tests/
```

## Validación Post-Scaffold

```bash
npx nx run [ProjectName]:build
npx nx run [ProjectName]:test
```

## Output

Siempre reportar:
- **Artifact Type**: Listener
- **Project Path**: `apps/[ProjectName]/`
- **Integration Status**: `.sln`, `project.json`, `cdk/`, tests
- **Known Caveats**: elementos que requieren revisión manual
- **Next Step**: usar `lanacion-lstnr-developer` + `/add-event` para implementar los eventos

## Ejemplo

```
/scaffold-listener LN.Sus.Ventas.Listener 20
```

Genera el listener bajo `apps/LN.Sus.Ventas.Listener/` completamente integrado en el monorepo.
