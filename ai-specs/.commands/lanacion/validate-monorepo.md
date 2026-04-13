# validate-monorepo

## Descripción
Valida que un proyecto generado o modificado en el monorepo esté correctamente integrado. Wrapper conversacional sobre la skill `validate-monorepo-integration`. Ejecutar siempre después de un scaffold o cambio estructural.

## Sintaxis
```
/validate-monorepo [ProjectName] [ArtifactType?]
```

## Parámetros
- **ProjectName** (requerido): Nombre del proyecto a validar (ej: `LN.Sus.Cobros.Api`)
- **ArtifactType** (opcional): `api`, `listener`, o `lambda`. Si no se indica, se detecta automáticamente

## Referencia
Adoptar el rol de `ai-specs/.agents/lanacion-nx-monorepo-developer.md` y ejecutar la skill:
- `ai-specs/.skills/validate-monorepo-integration/SKILL.md`

## Checks Ejecutados

### 1. Placement
- [ ] Proyecto existe bajo `apps/[ProjectName]/`
- [ ] No hay código de servicio bajo `ai-specs/` ni `openspec/`

### 2. Solución .NET
- [ ] Todos los `.csproj` del proyecto están registrados en el `.sln` global

### 3. Nx (`project.json`)
- [ ] `project.json` existe
- [ ] Targets esperados presentes: `build`, `test`, `lint`
- [ ] Para Lambdas: revisar `build:package` y ausencia de referencias rotas

### 4. Tests
- [ ] Carpeta `tests/` existe con al menos un proyecto de tests

### 5. CDK
- [ ] Carpeta `cdk/` existe
- [ ] Para Lambdas: `cdk/src/config/appSettings.json` y `cdk/src/model/stackModel.ts` presentes

### 6. VS Code
- [ ] `.vscode/launch.json` actualizado (cuando aplica)
- [ ] `.vscode/tasks.json` actualizado (cuando aplica)

## Comandos de Validación

```bash
# Validación targeted (preferida)
npx nx run [ProjectName]:build
npx nx run [ProjectName]:test

# Para stacks con infraestructura
npx nx run [ProjectName]:synth --configuration=dev

# Validación amplia (si la targeted pasa)
dotnet build
dotnet test
```

## Output

Siempre reportar:
- **Project Path**: ruta exacta en `apps/`
- **`.sln` Status**: ✅ registrado / ❌ faltante
- **`project.json` Status**: ✅ completo / ⚠️ targets faltantes
- **Tests Status**: ✅ existe / ❌ faltante
- **CDK Status**: ✅ existe / ❌ faltante / N/A
- **Build Result**: ✅ limpio / ❌ errores
- **Known Caveats**: inconsistencias que requieren revisión manual

## Ejemplo

```
/validate-monorepo LN.Sus.Cobros.Api api
```

Ejecuta todos los checks de integración para la API y reporta el estado completo.
