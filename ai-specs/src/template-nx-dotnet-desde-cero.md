# Template Nx + .NET para crear proyectos desde cero

## Objetivo

Este documento explica cómo usar el template del monorepo para crear proyectos nuevos desde cero.

El foco no está en las aplicaciones actuales del repositorio, sino en:

1. Cómo está construido el template.
2. Qué rol cumple Nx.
3. Cómo se crean proyectos nuevos usando los generadores de código.
4. Cómo quedan configurados los proyectos generados.
5. Qué hace cada archivo raíz que participa del build, test, dockerización y despliegue.
6. Qué limitaciones o inconsistencias tiene hoy el template.

---

## 1. Idea general del template

Este repositorio implementa un monorepo híbrido:

- Nx se usa como orquestador de workspace.
- .NET sigue siendo el sistema real de compilación de cada aplicación.
- La solución `.sln` sigue existiendo y se mantiene viva.
- Cada aplicación generada se guarda bajo `apps/<NombreProyecto>`.
- La infraestructura de despliegue de cada aplicación vive co-localizada bajo `apps/<NombreProyecto>/cdk`.
- Las pruebas del proyecto viven bajo `apps/<NombreProyecto>/tests`.

En otras palabras:

- Nx no reemplaza a `.NET`.
- Nx envuelve comandos `dotnet`, `docker` y `cdk`.
- El build de negocio sigue entrando por `.csproj`.

La pieza central del scaffolding está en:

- `tools/ln-generators`

Ahí vive un plugin local de Nx con 4 generadores:

- `add-template`
- `remove-template`
- `add-lib`
- `add-lambda`

Referencia:

- `tools/ln-generators/generators.json`

---

## 2. Modelo mental correcto

Si se crea un proyecto nuevo con este template, el resultado esperado no es un proyecto Nx puro.

El resultado esperado es:

1. Un proyecto .NET generado con `dotnet new` usando templates corporativos.
2. Ese proyecto se incrusta dentro del monorepo bajo `apps/`.
3. Todos los `.csproj` internos se agregan a la solución `.sln`.
4. Se crea un `project.json` de Nx para orquestar el proyecto como unidad de build.
5. Se conserva el patrón de CDK, Docker, tests y configuración local.

Eso significa que la unidad operativa principal del monorepo es:

- una app completa

No:

- una librería .NET por separado modelada como proyecto Nx independiente

---

## 3. Requisitos previos para usar el template

Para usar el template desde cero se necesita lo siguiente.

### Runtime y tooling

- Node.js 20
- npm 10
- .NET SDK 6
- .NET SDK 8
- Docker
- acceso a AWS
- acceso al feed NuGet corporativo de Azure Artifacts

### Motivo de cada requisito

#### Node 20

El workspace está definido con:

- `engines.node = >=20 <21`

Nx, TypeScript, CDK y los generadores locales dependen de esta capa.

#### .NET 6

Las aplicaciones generadas por `add-template` y los proyectos actuales del template están orientados principalmente a:

- `net6.0`

#### .NET 8

El pipeline instala también .NET 8 porque:

- el generador `add-lambda` crea lambdas en `net8.0`
- el runner local de lambdas también usa `net8.0`

#### Docker

Cada aplicación generada define target `docker` en Nx y utiliza un `Dockerfile` propio.

#### Azure Artifacts / NuGet

El template depende de:

- `NuGet.config` con feed corporativo
- credenciales para restaurar paquetes privados
- templates corporativos instalables por `dotnet new install`

Sin ese acceso:

- no se podrán instalar los templates corporativos
- no se podrán restaurar paquetes privados
- no se podrán construir imágenes Docker que restauran dependencias

### Archivos raíz que fijan estos prerequisitos

- `package.json`
- `NuGet.config`
- `azure-pipelines.yml`

---

## 4. Archivos raíz que gobiernan el template

### 4.1 `package.json`

Define la interfaz principal del workspace.

Scripts relevantes:

- `generate:template`
- `generate:lambda`
- `generate:lib`
- `delete:template`
- `build`
- `build:all`
- `build:ci`
- `docker:ci`
- `deploy:ci`
- `deploy:local`
- `test`
- `test:all`
- `test:ci`

Qué implica esto:

1. El alta y baja de proyectos se hace por scripts de npm que llaman a generadores Nx.
2. El build y deploy no se hace proyecto por proyecto manualmente, sino que se canaliza por Nx.
3. El pipeline ya espera que los targets estándar existan con nombres concretos.

### 4.2 `nx.json`

`nx.json` configura la capa de orquestación.

Puntos importantes:

- `appsDir = apps`
- `libsDir = libs`
- `defaultCollection = @workspace`
- plugins automáticos de ESLint y Jest
- `namedInputs` excluye `bin/` y `obj/`

Lectura correcta:

1. Nx considera a `apps` como carpeta principal de proyectos.
2. La idea original contemplaba también `libs`, aunque hoy la estructura real está mucho más concentrada en `apps`.
3. Los outputs de compilación .NET quedan fuera del input hash principal por exclusión de `bin` y `obj`.

### 4.3 `tsconfig.base.json`

Cumple dos roles:

1. configuración TypeScript del workspace
2. resolución de paths para plugins locales

Punto clave:

- `@ln/generators` apunta a `tools/ln-generators/src/index.ts`

Eso hace que Nx pueda resolver el plugin local del repo.

### 4.4 `LN.Sus.Cobranza.Ingesta.sln`

La solución `.sln` sigue siendo parte central del template.

Los generadores:

- agregan proyectos a la solución
- los remueven de la solución

Esto es importante porque el template no abandona el ecosistema Visual Studio / `.sln`.

### 4.5 `NuGet.config`

Define las fuentes de paquetes:

- `https://api.nuget.org/v3/index.json`
- feed corporativo `lanacion-v2` en Azure Artifacts

Esto es crítico porque:

- el template corporativo de `dotnet new` se instala desde el feed privado
- muchas dependencias internas vienen de ese feed

### 4.6 `azure-pipelines.yml`

El pipeline materializa el comportamiento esperado del template.

Qué hace:

1. instala .NET 6
2. instala .NET 8
3. instala Node 20
4. autentica NuGet
5. hace login a Docker registry
6. calcula `CONFIGURATION`
7. define variables para Docker y Nx
8. ejecuta:
   - `npm run docker:ci`
   - `npm run build:ci`

Lectura importante:

- el pipeline primero construye imágenes Docker
- después genera templates CDK (`synth`)

### 4.7 `.vscode/tasks.json`

Este archivo también forma parte del andamiaje operativo del template.

Expone tareas para:

- `npm run generate:lib`
- `npm run generate:template`
- `npm run generate:lambda`
- `npm run delete:template`
- inicialización de Docker local
- utilidades de MySQL
- utilidades de SQS
- utilidades de Step Functions
- compilación puntual por proyecto

Esto implica que el template no vive solo en:

- `package.json`
- `nx.json`

También deja una capa de productividad explícita en VS Code.

Observación importante:

- hoy existe una tarea `npm run build:lambda`
- ese script no existe en `package.json`

Eso sugiere una tarea vieja o incompleta.

### 4.8 `.vscode/launch.json`

Los generadores también integran debugging local.

`add-template` agrega:

- una configuración `launch` por proyecto
- un `preLaunchTask` `build.<Proyecto>`
- variables `ASPNETCORE_ENVIRONMENT`
- puertos HTTP/HTTPS locales
- apertura automática de Swagger

`add-lambda` agrega:

- una configuración de debug para el runner local `Local`
- variables como `AWS_PROFILE` y `USE_LOCALSTACK`

Conclusión:

Los generadores del template no solo crean código.

También preparan:

- experiencia de build
- experiencia de ejecución local
- experiencia de debug

---

## 5. Estructura esperada de un proyecto nuevo generado con `add-template`

Un proyecto nuevo generado por este template debería terminar con una forma similar a esta:

```text
apps/
  Nombre.Proyecto/
    project.json
    Dockerfile
    .dockerignore
    cdk/
      cdk.json
      tsconfig.json
      src/
        bin/
        lib/
        model/
        utils/
        config/
          appSettings.json
          appSettings.dev.json
          appSettings.qa.json
          appSettings.prod.json
          appSettings.localhost.json
    src/
      Nombre.Proyecto/
        Nombre.Proyecto.csproj
      Nombre.Proyecto.Application/
        Nombre.Proyecto.Application.csproj
      Nombre.Proyecto.Application.Interfaces/
        Nombre.Proyecto.Application.Interfaces.csproj
      Nombre.Proyecto.Domain/
        Nombre.Proyecto.Domain.csproj
      Nombre.Proyecto.Domain.Events/
        Nombre.Proyecto.Domain.Events.csproj
      Nombre.Proyecto.Infrastructure/ o Repositories.*
        ...csproj
    tests/
      Nombre.Proyecto.Tests.csproj
      FunctionTests.cs
      appsettings.Tests.json
```

Notas:

- La estructura exacta de `src/` depende del template corporativo de `dotnet new`.
- El generador `add-template` no construye toda esa estructura manualmente.
- La mayor parte viene del template corporativo instalado con `dotnet new`.
- El generador local hace el post-procesamiento y la integración con el monorepo.

---

## 6. Flujo completo para crear un proyecto nuevo desde cero

### Paso 1. Instalar dependencias del workspace

```bash
npm install
```

Esto instala:

- Nx
- TypeScript
- CDK
- herramientas del plugin local

### Paso 2. Ejecutar el generador principal

```bash
npm run generate:template
```

Eso llama a:

```bash
nx g @ln/generators:add-template --interactive
```

### Paso 3. Responder los prompts

El generador `add-template` pide:

1. `name`
2. `templateType`
3. `httpPort`
4. `httpsPort`
5. `orderRelease`

Significado:

- `name`: nombre lógico del proyecto
- `templateType`: tipo base del template corporativo
- `httpPort`: puerto para debug local
- `httpsPort`: puerto para debug local
- `orderRelease`: orden de salida en `dist/apps/<orden>-<nombre>`

### Paso 4. Instalación del template corporativo si falta

El generador verifica si el template ya está instalado vía:

- `dotnet new --list`

Si no está, instala:

- `lanacion.Core.SQS.EventListener`
- o `lanacion.Core.MinimalWebApi.Template`

según el tipo elegido.

### Paso 5. Generación base con `dotnet new`

Después ejecuta:

```bash
dotnet new <shortName> -n <NombreProyecto> -o apps/<NombreProyecto>
```

Esto crea el esqueleto base del proyecto.

### Paso 6. Limpieza post-template

El generador elimina artefactos que no deben vivir duplicados dentro del monorepo.

Elimina archivos como:

- `.editorconfig`
- `.gitignore`
- `.vscode`
- `azure-pipelines.yml`
- `NuGet.config`
- scripts SQL auxiliares

También elimina carpetas como:

- `Cloudformation`
- `EasyConfigurator`
- `scripts`
- `solutionItems`

Y borra el `.sln` propio generado por el template individual.

### Paso 7. Integración con la solución del monorepo

El generador escanea todos los `.csproj` dentro del proyecto recién creado y ejecuta:

```bash
dotnet sln LN.Sus.Cobranza.Ingesta.sln add "<ruta-csproj>"
```

Esto registra el proyecto en la solución global del monorepo.

### Paso 8. Creación de carpeta `tests`

El generador agrega una plantilla local de tests que no proviene del template externo.

Crea:

- `tests/<Nombre>.Tests.csproj`
- `tests/FunctionTests.cs`
- `tests/appsettings.Tests.json`

### Paso 9. Creación del `project.json` de Nx

El generador crea `apps/<NombreProyecto>/project.json`.

Ese archivo define los targets estándar:

- `restore`
- `build`
- `datadog`
- `docker`
- `synth`
- `serve`
- `test`

### Paso 10. Integración con VS Code

El generador actualiza:

- `.vscode/launch.json`
- `.vscode/tasks.json`

para permitir:

- compilar el proyecto
- correrlo localmente
- abrir Swagger al levantarlo

### Paso 11. Ajuste de `cdk/tsconfig.json`

El generador sobrescribe el `tsconfig.json` de `cdk/` para alinearlo con el workspace.

### Qué pasa internamente cuando Nx ejecuta un generador

A bajo nivel, la ejecución sigue este camino:

1. el usuario dispara un script de npm
2. ese script llama a `nx g @ln/generators:<nombre> --interactive`
3. Nx resuelve el plugin local `@ln/generators`
4. la resolución se apoya en el path mapping del workspace
5. Nx lee `tools/ln-generators/generators.json`
6. desde ahí localiza:
   - `schema.json`
   - `generator.ts`
7. el `schema.json` define prompts, required fields y validaciones
8. el `generator.ts` ejecuta la lógica real

Este repo usa una implementación híbrida.

### Capa 1. Operaciones de Nx Devkit

Se usan APIs como:

- `generateFiles`
- `tree.write`
- `formatFiles`
- `joinPathFragments`
- `names`

Eso cubre:

- archivos templados
- `project.json`
- tests
- escritura declarativa dentro del workspace

### Capa 2. Operaciones imperativas por shell y filesystem

También se usan:

- `execSync`
- `fs`
- `path`

Eso cubre:

- `dotnet new`
- `dotnet new install`
- borrado de carpetas
- movimientos de archivos
- edición de `.vscode`
- `dotnet sln add`
- `dotnet sln remove`
- actualización de archivos JSON ya existentes

Conclusión técnica:

Estos no son generadores Nx puros.

Son generadores híbridos:

- una parte opera sobre `Tree`
- otra parte ejecuta side effects directos sobre disco y shell

Eso les da mucho alcance, pero también los vuelve más frágiles si una operación externa falla a mitad de camino.

### Momento en que ocurren las acciones

En varios generadores hay dos fases:

#### Fase 1. Durante la ejecución principal

Se generan archivos base y se dejan escrituras pendientes sobre el `Tree`.

#### Fase 2. En el callback final que retorna el generador

Después de materializar el `Tree`, se ejecutan side effects finales como:

- `dotnet sln add`
- actualizaciones sobre archivos ya creados

Este patrón aparece especialmente en:

- `add-template`
- `add-lib`
- `add-lambda`

---

## 7. Qué genera exactamente `add-template`

## Nombre formal

- `@ln/generators:add-template`

## Propósito

Crear una aplicación nueva integrada al monorepo.

## Inputs

- `name`
- `templateType`
- `httpPort`
- `httpsPort`
- `orderRelease`

## Plantillas corporativas usadas

### Opción 1

- `ln-SQSlstnr`
- paquete: `lanacion.Core.SQS.EventListener`

### Opción 2

- `ln-minWebApi`
- paquete: `lanacion.Core.MinimalWebApi.Template`

## Qué hace internamente

1. Resuelve nombre y path base.
2. Instala el template corporativo si falta.
3. Ejecuta `dotnet new`.
4. Corrige la estructura si el template creó una subcarpeta redundante.
5. Borra archivos locales que no deben quedar duplicados.
6. Borra el `.sln` del proyecto individual.
7. Busca todos los `.csproj`.
8. Los agrega al `.sln` global.
9. Genera la carpeta de tests local del monorepo.
10. Genera `project.json` para Nx.
11. Actualiza VS Code.
12. Sobrescribe `cdk/tsconfig.json`.

## Cómo funciona a bajo nivel

Internamente combina:

- `execSync` para `dotnet new`
- `fs` y `path` para limpiar y mover archivos
- `generateFiles` para crear la carpeta `tests`
- `tree.write` para crear `project.json`
- `formatFiles` para formatear el resultado
- `execSync` adicional para agregar los `.csproj` al `.sln`

La app no nace desde cero en Nx.

Nx actúa como adaptador alrededor de una app corporativa creada primero por `.NET`.

El flujo real es:

1. generar base con `dotnet new`
2. limpiar el output individual
3. integrarlo al monorepo
4. recién ahí crear la capa Nx

## Qué toca además del código fuente

Además del árbol `apps/<Proyecto>`, este generador también modifica:

- `.vscode/launch.json`
- `.vscode/tasks.json`
- la solución `.sln`
- `cdk/tsconfig.json`

## Qué no hace

- No modela cada `.csproj` interno como proyecto Nx separado.
- No crea librerías Nx reutilizables en `libs/`.
- No resuelve dependencias entre apps a nivel Nx.

## Resultado esperado

Una app nueva lista para:

- restaurar paquetes
- compilar
- correr tests
- levantar localmente
- generar `datadog.json`
- dockerizar
- sintetizar infraestructura CDK

---

## 8. Qué genera exactamente `add-lambda`

## Nombre formal

- `@ln/generators:add-lambda`

## Propósito

Agregar una lambda .NET 8 al monorepo, ya sea:

1. dentro de un stack CDK existente
2. creando un stack CDK nuevo

## Inputs

- `cdkOption`
- `cdkName`
- `name`
- `memorySize`
- `orderRelease`

## Convención de nombres

El input `name` debe terminar en:

- `.lambda`

Ejemplo:

- `LN.Sus.Algo.Procesador.lambda`

El generador lo normaliza a:

- proyecto principal: `LN.Sus.Algo.Procesador.Lambda`
- tests: `LN.Sus.Algo.Procesador.Lambda.Tests`
- runner local: `LN.Sus.Algo.Procesador.Lambda.Local`

## Árbol que puede crear

### Siempre crea

- `apps/<Stack>/app/<Lambda>/`
- `apps/<Stack>/tests/<Lambda>.Tests/`
- `apps/<Stack>/local/<Lambda>.Local/`

### Si se elige crear stack nuevo

También crea:

- `apps/<Stack>/cdk/`
- `apps/<Stack>/project.json`

## Qué contienen esas carpetas

### `app/<Lambda>/`

Contiene la lambda real en .NET 8.

Archivo principal:

- `Function.cs`

Incluye:

- handler base `FunctionHandler`
- serialización por `Amazon.Lambda.Serialization.SystemTextJson`

### `tests/<Lambda>.Tests/`

Contiene proyecto MSTest en .NET 8.

### `local/<Lambda>.Local/`

Contiene un ejecutable local para invocar/debuggear la lambda fuera de AWS.

Incluye soporte para:

- LocalStack
- AWS profile
- AWS SSO

### `cdk/`

Contiene un stack CDK TypeScript para publicar lambdas.

Elementos relevantes:

- `cdk.json`
- `src/bin/cdk.ts`
- `src/lib/cdk-stack.ts`
- `src/lib/resources/lambdaFunctions.ts`
- `src/model/stackModel.ts`
- `src/config/appSettings*.json`

## Cómo funciona a bajo nivel

Este generador:

1. normaliza el nombre terminado en `.lambda`
2. deriva nombres para:
   - proyecto principal
   - tests
   - runner local
   - clave lógica de lambda
3. usa `generateFiles` para crear:
   - `app/`
   - `tests/`
   - `local/`
4. si se pide stack nuevo, también crea:
   - `cdk/`
   - `project.json`
5. actualiza `cdk/src/config/appSettings.json`
6. intenta editar `cdk/src/model/stackModel.ts`
7. agrega al `.sln`:
   - proyecto principal
   - tests
   - runner local
8. agrega una entrada de debug a `.vscode/launch.json`

Detalle importante:

- no agrega tareas nuevas a `.vscode/tasks.json`
- solo agrega configuración de launch para debug local

## Cómo funciona la parte CDK de lambdas

La configuración se lee desde:

- `StackElements.LambdaFunctions`

Cada lambda define:

- `Name`
- `MemorySize`
- `Path`
- `Namespace`

La resource CDK:

1. recorre `StackElements.LambdaFunctions`
2. crea una `aws-lambda Function` por cada entrada
3. usa runtime:
   - `DOTNET_8`
4. toma el código desde:
   - `dist/apps/<orden>-<stack>/app/<lambda>/function.zip`

## Qué modifica si apunta a un stack existente

Si el stack ya existe:

1. actualiza `cdk/src/config/appSettings.json`
2. agrega la lambda al bloque `StackElements.LambdaFunctions`
3. intenta actualizar `cdk/src/model/stackModel.ts`
4. agrega al `.sln`:
   - proyecto app
   - proyecto tests
   - proyecto local

## Targets Nx que define cuando crea stack nuevo

- `build`
- `build:package`
- `synth`
- `build:local`
- `test`

La intención es:

1. compilar lambdas
2. empaquetarlas con `Amazon.Lambda.Tools`
3. dejar `function.zip` en `dist`
4. sintetizar el stack CDK

## Observaciones importantes sobre `add-lambda`

Hoy este generador tiene inconsistencias que deben conocerse:

1. `build` depende de `build:package` y `build:package` depende de `build`.
   - eso genera una dependencia circular en el target modelado
2. `test` depende de `build:net`
   - ese target no existe
3. `cdkName` figura como requerido en el schema incluso cuando conceptualmente podría no ser necesario en ciertos flujos

Conclusión:

- la intención del generador está clara
- pero su implementación actual necesita ajuste antes de usarlo como camino principal de producción

---

## 9. Qué genera exactamente `add-lib`

## Nombre formal

- `@ln/generators:add-lib`

## Propósito

Crear una librería .NET simple bajo `libs/`.

## Input

- `name`

## Qué crea

Plantilla mínima con:

- `libs/<Nombre>/project.json`
- `libs/<Nombre>/<Nombre>.csproj`
- `libs/<Nombre>/src/Class.cs`
- `libs/<Nombre>/README.md`

## Qué hace internamente

1. genera archivos estáticos desde template local
2. crea un `project.json` Nx de tipo `library`
3. intenta agregar el `.csproj` a la solución `.sln`

## Cómo funciona a bajo nivel

Es el generador más simple del conjunto.

No llama a templates externos de `dotnet new`.

Su implementación se apoya en:

- `generateFiles`
- `tree.write`
- callback final con `dotnet sln add`

Eso lo vuelve conceptualmente simple, pero hoy su problema no está en la complejidad interna sino en que no está bien alineado con el modelo real del workspace.

## Estado real de este generador

Aunque existe, hoy no está alineado con el estado real del monorepo.

Problemas observables:

1. El workspace declara `libs`, pero actualmente no la usa como parte central del modelo.
2. El target `serve` calcula un `cwd` incorrecto.
3. No existe un patrón de consumo real de estas libs desde las apps actuales.

Conclusión:

- existe como idea de expansión
- hoy no parece ser el camino principal maduro del template

---

## 10. Qué hace exactamente `remove-template`

## Nombre formal

- `@ln/generators:remove-template`

## Propósito

Eliminar una aplicación previamente creada con el template.

## Input

- `name`

## Qué hace internamente

1. busca todos los `.csproj` bajo `apps/<name>/src`
2. ejecuta `dotnet sln ... remove` para cada uno
3. intenta limpiar `.vscode/launch.json`
4. intenta limpiar `.vscode/tasks.json`
5. elimina la carpeta completa `apps/<name>`

## Cómo funciona a bajo nivel

Este generador es casi totalmente imperativo.

No crea archivos nuevos.

No usa templates externos.

Su lógica depende de:

- `fs`
- `path`
- `execSync`

Primero desregistra proyectos del `.sln` y después elimina la carpeta física del proyecto.

## Observaciones importantes

Tiene una inconsistencia actual:

- el nombre que intenta eliminar en `launch.json` no coincide con el nombre con el que `add-template` crea esa configuración

Eso significa que:

- puede eliminar correctamente la carpeta y sacar proyectos del `.sln`
- pero dejar basura residual en `.vscode/launch.json`

---

## 11. Cómo queda configurado un proyecto nuevo en Nx

Cada proyecto nuevo generado por `add-template` recibe un `project.json` con comportamiento estándar.

## `restore`

Ejecuta:

```bash
dotnet restore apps/<Proyecto>/src/<Proyecto>/<Proyecto>.csproj
```

## `build`

Ejecuta:

```bash
dotnet build apps/<Proyecto>/src/<Proyecto>/<Proyecto>.csproj
```

Depende de:

- `restore`

## `test`

Ejecuta:

```bash
dotnet test apps/<Proyecto>/tests/<Proyecto>.Tests.csproj --logger trx
```

## `serve`

Ejecuta:

```bash
dotnet run
```

con `cwd` en el proyecto principal.

## `datadog`

Ejecuta:

```bash
node scripts/generate-datadog.js apps/<Proyecto>/src/<Proyecto>/appsettings.json $BUILD_BUILDNUMBER
```

Esto genera un `datadog.json` junto a `appsettings.json`.

## Relación con `.vscode/tasks.json`

Además de este `project.json`, el alta por generador agrega una tarea:

- `build.<Proyecto>`

en `.vscode/tasks.json`

Esa tarea es la que después usa `.vscode/launch.json` como:

- `preLaunchTask`

Entonces hay dos capas de orquestación coexistiendo:

1. Nx para build/test/docker/synth del workspace
2. VS Code tasks para experiencia local de compilación y debug

## `docker`

Ejecuta:

1. `docker build`
2. `docker push`

Depende de:

- `datadog`

## `synth`

Ejecuta:

```bash
cdk synth -c configs=<...> -c distDir=... -o ...
```

con `cwd` en:

- `apps/<Proyecto>/cdk`

Genera artefactos en:

- `dist/apps/<orderRelease>-<Proyecto>/cdk`

---

## 12. Cómo queda configurado un proyecto nuevo en .NET

## La compilación real entra por `.csproj`

El target `build` de Nx no compila archivos manualmente.

Compila el `.csproj` principal.

Ese `.csproj` referencia otros proyectos internos mediante:

- `ProjectReference`

Por eso:

- la relación real entre capas vive en `.NET`
- Nx solamente dispara la compilación del proyecto raíz

## El `.sln` sigue siendo importante

Cada proyecto nuevo se agrega al `.sln`.

Esto mantiene compatibilidad con:

- Visual Studio
- navegación del código
- build tradicional de solución
- operaciones manuales de `.NET`

## Target frameworks esperables

### Para apps generadas con `add-template`

Principalmente:

- `net6.0`

### Para lambdas generadas con `add-lambda`

Principalmente:

- `net8.0`

### Para algunos proyectos de eventos

Puede aparecer:

- `netstandard2.0`

Esto explica por qué el pipeline instala más de un SDK.

---

## 13. Cómo queda configurada la infraestructura de una app nueva

Cada app tiene un proyecto CDK propio.

No existe una carpeta única central de infraestructura para todas las apps.

Eso significa:

- la infraestructura está co-localizada por aplicación
- cada app carga su propio `stackModel`
- cada app sintetiza su propio stack

## Piezas típicas del `cdk/`

### `src/bin/cdk.ts`

Punto de entrada del stack CDK.

Usa:

- `createStack` de `@ln/aws-core-cdk-utils`

### `src/lib/cdk-stack.ts`

Implementa el stack concreto.

Suele ensamblar recursos como:

- roles
- task definitions
- services
- target groups
- listener rules
- record sets
- log groups
- scalable targets

### `src/model/stackModel.ts`

Modela la configuración tipada del stack.

### `src/config/appSettings.json`

Config base del stack.

### `src/config/appSettings.dev.json`

Override de entorno dev.

### `src/config/appSettings.qa.json`

Override de entorno qa.

### `src/config/appSettings.prod.json`

Override de entorno prod.

### `src/config/appSettings.localhost.json`

Override local, cuando el template base lo trae.

---

## 14. Cómo se configura `appSettings.json` del CDK

En el patrón actual, `appSettings.json` de `cdk/` es el archivo de configuración declarativa de infraestructura.

Campos típicos:

- `Aplication`
- `Solution`
- `AwsAccount`
- `AwsRegion`
- `Tags`
- `AdminStack`

Dentro de `AdminStack` suelen configurarse elementos como:

- host
- roles
- target groups
- service
- task definition
- listener rules
- recursos externos
- escalado

En lambdas el bloque principal pasa a ser:

- `StackElements.LambdaFunctions`

Este enfoque implica que el template:

- separa código de infraestructura
- pero deja la infraestructura como configuración local por app

---

## 15. Cómo queda configurado Docker

Cada aplicación nueva hereda el patrón de Dockerfile co-localizado en la carpeta raíz del proyecto Nx.

Patrón general:

1. imagen base runtime
2. imagen de build con SDK .NET
3. instalación de Azure Artifacts credential provider
4. inyección de `FEED_ACCESSTOKEN`
5. copia de `.csproj` primero
6. `dotnet restore`
7. copia del resto del código
8. `dotnet build`
9. `dotnet publish`
10. imagen final runtime

Beneficios de este patrón:

- aprovecha cache de restore si no cambian `.csproj`
- permite restaurar paquetes privados
- deja imágenes publicadas listas para ECS/Fargate o el runtime elegido

Relación con Datadog:

- antes del `docker build`, el target `datadog` genera `datadog.json`
- el Docker build lo empaqueta junto con la app

---

## 16. Cómo funciona el build global del monorepo

La entrada principal es:

```bash
npm run build
```

Eso hace:

1. limpia `build`
2. setea `BUILD_ALL=false`
3. ejecuta `scripts/build.sh`

`scripts/build.sh` decide:

- `affected` si `BUILD_ALL=false`
- `run-many` si `BUILD_ALL=true`

Y decide target:

- `build` por defecto
- `synth` si `TARGET=synth`

Ejemplo:

```bash
npx nx affected --target=build --verbose --configuration=dev
```

## Caso CI

### Docker

```bash
npx nx affected --target=docker
```

### Synth

```bash
TARGET=synth BUILD_ALL=false bash ./scripts/build.sh
```

---

## 17. Cómo funciona el deploy

El deploy se apoya en artefactos generados en:

- `dist/apps/<orden>-<proyecto>`

El script:

- recorre carpetas `cdk`
- busca template matching `*-$ENV-*stack.template.json`
- deriva `stack_name`
- ejecuta `cdk deploy`

Observación importante:

El orden del release no se obtiene del grafo de Nx.

Se obtiene del prefijo numérico:

- `1-...`
- `2-...`
- `3-...`

Eso significa que el campo `orderRelease` del generador tiene impacto real en despliegue.

---

## 18. Cómo se usa el template en una secuencia completa

## Caso A. Crear una nueva aplicación listener o API

1. Instalar dependencias del repo.
2. Ejecutar `npm run generate:template`.
3. Elegir:
   - Listener
   - Minimal API
4. Definir nombre del proyecto.
5. Definir puertos locales.
6. Definir orden de release.
7. Verificar que se agregaron los `.csproj` al `.sln`.
8. Verificar que existe `apps/<Proyecto>/project.json`.
9. Ejecutar:
   - `npm run build`
   - `npm run test`
10. Si corresponde, ejecutar:
   - `npx nx run <Proyecto>:synth --configuration=dev`
11. Si corresponde, ejecutar:
   - `npx nx run <Proyecto>:docker`

## Caso B. Agregar una lambda a un stack existente

1. Ejecutar `npm run generate:lambda`.
2. Elegir stack existente.
3. Indicar nombre del stack.
4. Indicar nombre de lambda terminado en `.lambda`.
5. Definir memoria.
6. Definir orden de release.
7. Verificar:
   - carpeta `app/`
   - carpeta `tests/`
   - carpeta `local/`
   - actualización de `appSettings.json`
   - actualización de `stackModel.ts`
8. Corregir manualmente los problemas conocidos del generador si se va a usar en build real.

## Caso C. Eliminar una app

1. Ejecutar `npm run delete:template`.
2. Indicar nombre del proyecto.
3. Verificar:
   - remoción del `.sln`
   - remoción de la carpeta `apps/<Proyecto>`
   - limpieza de `.vscode`

---

## 19. Qué hace cada generador en resumen ejecutivo

## `add-template`

Genera una app completa del monorepo.

Incluye:

- template .NET corporativo
- integración al `.sln`
- tests
- `project.json`
- VS Code
- integración con CDK/Nx/Docker

## `add-lambda`

Genera una lambda .NET 8 con tests, runner local y opcionalmente stack CDK.

Puede actualizar un stack existente o crear uno nuevo.

## `add-lib`

Genera una librería .NET mínima bajo `libs/`, pero hoy no está madura ni alineada con el uso principal del repo.

## `remove-template`

Desintegra una app del monorepo:

- la saca del `.sln`
- borra la carpeta
- intenta limpiar VS Code

---

## 20. Limitaciones y deudas técnicas del template actual

Esta sección es importante si el objetivo es inspección técnica de bajo nivel.

## 20.1 Desalineación entre modelo conceptual y modelo real

El repo declara:

- `apps`
- `libs`

Pero el uso real está casi completamente concentrado en:

- `apps`

No hay una estrategia madura de librerías Nx independientes.

## 20.2 Nx no modela dependencias internas de .NET

Nx compila la app raíz.

Las dependencias internas se resuelven por:

- `ProjectReference`
- `.sln`

Esto simplifica el scaffolding, pero le quita precisión al grafo de Nx.

## 20.3 Generadores con inconsistencias

### `add-template`

- puede ignorar puertos ingresados por la lógica actual
- genera un task de VS Code con una comilla sobrante

### `remove-template`

- puede dejar residuos en `launch.json`

### `add-lib`

- no está operacionalmente alineado con el modelo real

### `add-lambda`

- tiene dependencia circular entre targets
- referencia target inexistente

## 20.4 Residuos del template base de Nx

Persisten señales de código no terminado o heredado:

- `defaultCollection = @workspace`
- path a `tools/my-plugin` inexistente
- referencias viejas en `tsconfig.base.json`

## 20.5 Potencial fragilidad del plugin local de Nx

Se observa mezcla de versiones entre:

- `nx`
- `@nx/devkit`
- dependencias del plugin local

Esto puede afectar introspección de Nx y workers de plugin.

---

## 21. Recomendación de uso para un proyecto nuevo

Si se usa este template hoy para crear una app nueva, el camino más seguro es:

1. usar `add-template` como generador principal de apps
2. considerar `add-lambda` como generador utilizable solo con revisión manual posterior
3. evitar depender de `add-lib` como estrategia central hasta alinearlo
4. validar siempre:
   - `.sln`
   - `project.json`
   - `Dockerfile`
   - `cdk/`
   - `.vscode`
   - targets Nx

---

## 22. Resumen final

Este template implementa una plataforma de generación de aplicaciones .NET dentro de un monorepo Nx, donde:

- Nx orquesta
- .NET compila
- Docker empaqueta
- CDK despliega
- la solución `.sln` sigue siendo fuente de verdad para los proyectos .NET

La creación de una app nueva desde cero está pensada para ser:

1. generar base con template corporativo de `dotnet new`
2. integrar esa base al monorepo
3. estandarizar build, test, docker y synth vía Nx

El template es funcional para alta de aplicaciones completas mediante `add-template`, pero todavía muestra deuda técnica en:

- lambdas
- libs
- limpieza de residuos del template Nx original
- consistencia de versiones del toolchain

Si se explica correctamente, la mejor definición técnica de este repositorio es:

> un monorepo Nx adaptado para alojar y orquestar soluciones .NET empresariales, con generación automática de proyectos, infraestructura co-localizada por app y pipeline de build/deploy estandarizado
