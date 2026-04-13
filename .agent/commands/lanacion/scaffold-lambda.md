# scaffold-lambda

## Descripción
Scaffoldea una nueva Lambda .NET 8 en el monorepo Nx, ya sea en un stack existente o creando uno nuevo. Wrapper conversacional sobre la skill `scaffold-monorepo-lambda`.

## Sintaxis
```
/scaffold-lambda [LambdaName] [StackName?] [MemorySize?] [OrderRelease?]
```

## Parámetros
- **LambdaName** (requerido): Nombre de la Lambda **sin** el sufijo `.lambda` (ej: `LN.Sus.Algo.Procesador`). El comando agrega `.lambda` automáticamente
- **StackName** (opcional): Nombre del stack CDK existente o nuevo. Se pedirá si no se indica
- **MemorySize** (opcional): Memoria en MB (ej: `512`). Default: `256`
- **OrderRelease** (opcional): Orden de release. Se pedirá si no se indica

## Referencia
Adoptar el rol de `ai-specs/.agents/lanacion-nx-monorepo-developer.md` y ejecutar la skill:
- `ai-specs/.skills/scaffold-monorepo-lambda/SKILL.md`

## Precondiciones

Verificar antes de ejecutar:
- [ ] Node.js 20 disponible
- [ ] npm disponible
- [ ] .NET SDK 8 disponible
- [ ] `package.json` y `nx.json` en la raíz del repo
- [ ] Solución global (`.sln`) existe

## Regla de Naming

El nombre interno se normaliza automáticamente:
- Input: `LN.Sus.Algo.Procesador`
- Proyecto principal: `LN.Sus.Algo.Procesador.Lambda`
- Tests: `LN.Sus.Algo.Procesador.Lambda.Tests`
- Local runner: `LN.Sus.Algo.Procesador.Lambda.Local`

## Proceso

1. Confirmar si el stack es nuevo o existente
2. Confirmar o solicitar los parámetros faltantes
3. Ejecutar el generador:
```bash
npm run generate:lambda
# cdkOption: new | existing
# cdkName: [StackName]
# name: [LambdaName].lambda
# memorySize: [MemorySize]
# orderRelease: [OrderRelease]
```
4. Verificar estructura generada
5. Revisar `cdk/src/config/appSettings.json` y `cdk/src/model/stackModel.ts`
6. Ejecutar `validate-monorepo-integration` automáticamente
7. Reportar caveats conocidos del generador

## Estructura Esperada

```
apps/[StackName]/
  app/[LambdaName].Lambda/
  tests/[LambdaName].Lambda.Tests/
  local/[LambdaName].Lambda.Local/
  cdk/
  project.json
```

## Caveats Conocidos del Generador

Revisar siempre tras la generación:
- Dependencia circular entre targets `build` y `build:package`
- Referencias a `build:net` inexistente
- Actualizaciones incompletas en archivos CDK

## Validación Post-Scaffold

```bash
npx nx run [StackName]:build
npx nx run [StackName]:test
npx nx run [StackName]:synth --configuration=dev
```

## Output

Siempre reportar:
- **Artifact Type**: Lambda
- **Stack Path**: `apps/[StackName]/`
- **Lambda Path**: `apps/[StackName]/app/[LambdaName].Lambda/`
- **Integration Status**: `.sln`, `project.json`, `cdk/`, tests
- **Known Caveats**: inconsistencias del generador que requieren revisión manual

## Ejemplo

```
/scaffold-lambda LN.Sus.Cobros.Procesador MiStack 512 30
```

Genera `apps/MiStack/app/LN.Sus.Cobros.Procesador.Lambda/` con tests, local runner y CDK integrados.
