# 📊 CAPACIDADES E INTENCIONALIDAD

**Ln.Sus.Monorepo.Template** — Monorepo estructurado para orquestar la generación automática y el despliegue escalable de **Minimal APIs y listeners event-driven en .NET**, con soporte de infraestructura en AWS (Lambda/SQS/EventBridge) y generación de código consistente mediante Nx.

---

## 🎯 Propósito Principal

Acelerar y estandarizar la creación de **listeners SQS/EventBridge y Minimal APIs** en .NET, con integración automática de stacks CDK y un flujo de trabajo guiado; también soporta la creación de funciones Lambda como modelo de ejecución underlying.

**Problema que resuelve:**
- Antes: Cada listener o API requería scaffolding manual (estructura, entidades, enrutamiento, CDK, tests, configuración).
- Ahora: `npm run generate:template` / `npm run generate:lambda` → proyecto completo, listo para desarrollo.

---

## 🏗️ Arquitectura

### Pilares

| Componente | Tecnología | Propósito |
|------------|-----------|----------|
| **Build System** | [Nx 19.5.6](https://nx.dev) | Orquestar compilación incremental de múltiples proyectos .NET |
| **IaC** | AWS CDK 2.158.0 + TypeScript | Definir y desplegar stacks de Lambda, SQS, y Step Functions |
| **Runtime .NET** | .NET SDK 6.0 + 8.0 | Compilar funciones Lambda y Minimal APIs |
| **Scaffolding** | NX Generators Custom | Plantillas interactivas para generar código boilerplate |
| **Testing** | Jest + .NET xUnit | Tests unitarios en TS y .NET |
| **CI/CD** | Azure Pipelines | Build, test y deploy automático en dev/qa/prod |
| **Local Development** | LocalStack + Docker | Simular AWS (Lambda, SQS, StepFunctions) sin costos |

### Capas del Monorepo

```
apps/
  ├── {ProyectoLambda}/
  │   ├── src/{ProyectoLambda}/          ← Código .NET de Lambda
  │   ├── tests/{ProyectoLambda}.Tests/  ← Tests .NET
  │   └── cdk/                            ← Definición IaC (AWS CDK)
  │
  └── {ProyectoAPI}/
      ├── src/{ProyectoAPI}/             ← Código Minimal API .NET
      ├── tests/{ProyectoAPI}.Tests/     ← Tests
      └── cdk/                            ← Stack CDK para API

libs/
  ├── {LibreríaCompartida}/              ← Código compartido (.NET/.TS)
  └── ...

tools/
  └── ln-generators/                     ← Generadores Nx (add-lambda, add-template, etc.)
```

---

## 🚀 CAPACIDADES PRINCIPALES

### 1️⃣ Generar Listeners / Minimal APIs

**Comando:**
```bash
npm run generate:template
```

**¿Qué crea?**
- Minimal API .NET que escucha eventos (SQS, SNS, EventBridge)
- CDK stack con Lambda + event source mapping
- Estructura de tests completa
- Endpoints preconstruidos para debug local
- Integración automática al `.sln`

**Flujo típico:**
```
SQS → Lambda (Listener) → Procesa mensaje → Responde
```

---

### 2️⃣ Generar Funciones Lambda (Puras)

**Comando:**
```bash
npm run generate:lambda
```

**¿Qué crea?**
- Proyecto .NET con estructura lista para Lambda
- CDK stack para desplegar la función
- Tests unitarios con xUnit
- Configuración de memoria, timing, variables de entorno
- Integración automática al `.sln` y Nx

**Proyectos generados:**
```
apps/{NombreProyecto}/
├── src/{NombreProyecto}.Lambda/
│   ├── {NombreProyecto}.Lambda.csproj
│   └── Function.cs                    ← Handler de Lambda
├── tests/{NombreProyecto}.Lambda.Tests/
│   ├── ClassTests.cs
│   └── appsettings.Tests.json
├── cdk/src/
│   ├── bin/cdk.ts                     ← Entry point
│   ├── lib/cdk-stack.ts               ← Stack definition
│   ├── config/appSettings.{env}.json  ← Configuración por ambiente
│   └── model/                         ← StackModel, config types
└── local/{NombreProyecto}.Lambda.Local/  ← Para testing local con SAM
```

**Tipo de integraciones que soporta:**
- ✅ Triggers: SQS, SNS, EventBridge, API Gateway
- ✅ Servicios: DynamoDB, S3, Secrets Manager, RDS
- ✅ Patrones: Retry, DLQ, async patterns

---

### 3️⃣ Generar Librerías Compartidas

**Comando:**
```bash
npm run generate:template
```

**¿Qué crea?**
- Minimal API .NET que escucha eventos (SQS, SNS)
- CDK stack con Lambda + event source mapping
- Estructura de tests completa
- Endpoints preconstruidos para debug local
- Integración automática al `.sln`

**Diferencia con Lambda pura:**
- Las Lambdas puras: Función + Handler
- Templates (Listeners): Lambda + Consumer + Endpoints expuestos + CDK con event source mapping

**Flujo típico:**
```
SQS → Lambda (Listener) → Procesa mensaje → Responde
```

---

### 3️⃣ Generar Librerías Compartidas

**Comando:**
```bash
npm run generate:lib
```

**Para:**
- Código reutilizable entre múltiples Lambdas
- DTOs, servicios, utilidades
- Modelos de datos

**Ejemplo de estructura:**
```
libs/LN.Sus.Subscriptions.Common/
├── src/
│   ├── Services/
│   ├── Models/
│   └── Utils/
└── {LibName}.csproj
```

Todas las Lambdas pueden referenciar `LN.Sus.Subscriptions.Common` en sus `.csproj`.

---

### 4️⃣ Eliminar Proyectos

**Comando:**
```bash
npm run delete:template
```

**Limpia automáticamente:**
- Eliminación completa de la carpeta del proyecto
- Remoción del `.csproj` del `.sln`
- Remoción de referencias en `launch.json` y `tasks.json`

---

## 🔄 FLUJO DE TRABAJO COMPLETO

### Fase 1: Inicialización Local

```bash
# 1. Instalar dependencias
npm install

# 2. Iniciar Docker: LocalStack + MySQL
npm run initDocker

# 3. Crear esquema MySQL
npm run mysqlCreator

# 4. Crear cola SQS
npm run sqsCreator
```

**Resultado:** LocalStack ejecutando con servicios AWS simulados sin costo.

---

### Fase 2: Generar nuevo Proyecto

```bash
npm run generate:lambda
# O para listener
npm run generate:template
```

**Flujo interactivo (preguntas):**
- Nombre del proyecto
- ¿Stack CDK nuevo o existente?
- Namespace base (ej: `LN.Sus.EventoPrueba.Lambda`)
- Memoria requerida (MB)

**Resultado:** Estructura completa lista para código.

---

### Fase 3: Desarrollo Local

Cada proyecto generado incluye:

**Debug con VSCode:**
- `launch.json` preconfigurado con puertos
- `tasks.json` con comandos de build/run
- Run → Select and Start Debugging (`Ctrl+Shift+D`)

**Interacción con LocalStack:**
```bash
# Enviar mensajes a SQS (para testing listeners)
npm run sqsAddData

# Purgar cola
npm run sqsPurgeData

# Inspeccionar historiales Step Functions
npm run inspectExecutions
```

---

### Fase 4: Build & Test

**Build incremental (solo cambios):**
```bash
npm run build
```

**Build completo:**
```bash
npm run build:all
```

**Bajo el capó:**
```bash
npx nx affected --target=build --configuration=dev
```

Nx detecta automáticamente qué proyectos fueron modificados y compila solo esos + dependientes.

**Tests:**
```bash
npm run test        # Solo proyectos modificados
npm run test:all    # Todos
npm run test:ci     # Con cobertura + reporte
```

---

### Fase 5: Deploy a AWS

**Configurar credenciales:**
```bash
aws configure --profile stg-Suscripciones
# Access Key ID = <tu key>
# Secret Access Key = <tu secret>
# Region = us-east-1
```

**Deploy local (dev):**
```bash
ENV=dev PROFILE=stg-Suscripciones npm run deploy:local
```

**Deploy en CI/CD (Azure Pipelines):**
```bash
# Automático en cada commit a main/dev/qa
npm run deploy:ci
```

**¿Qué hace el deploy?**
1. Compila todos los proyectos .NET
2. Transpila CDK TypeScript → CloudFormation
3. Ejecuta `aws cdk deploy` con perfiles de AWS
4. Despliega Lambdas, SQS, Step Functions, etc.

---

## 🛠️ SCRIPTS DISPONIBLES

### Build & Compilación

| Script | Propósito |
|--------|----------|
| `build:lambda` | Compila Lambdas (env dev, config específica) |
| `build` | Build incremental (solo modificados) |
| `build:all` | Build completo de todos los proyectos |
| `build:local` | Build con limpieza previa (desarrollo local) |
| `build:ci` | Build + prep para deploy (CI) |
| `dotnet:build` | Ejecuta `dotnet build` en el `.sln` |

### Testing

| Script | Propósito |
|--------|----------|
| `test` | Test incremental (proyectos modificados) |
| `test:all` | Test completo |
| `test:ci` | Tests + generación de cobertura (CI) |
| `coverage` | Reporte de cobertura (istanbul) |

### Generación de Código

| Script | Propósito |
|--------|----------|
| `generate:lambda` | Crear nueva función Lambda |
| `generate:template` | Crear listener/Minimal API |
| `generate:lib` | Crear librería compartida |
| `delete:template` | Eliminar proyecto existente |

### Deploy

| Script | Propósito |
|--------|----------|
| `deploy:local` | Deploy a AWS (env dev, profile local) |
| `deploy:ci` | Deploy en CI (Azure Pipelines) |

### LocalStack & AWS Simulado

| Script | Propósito |
|--------|----------|
| `initDocker` | Inicia LocalStack + MySQL en Docker |
| `mysqlCreator` | Crea esquema MySQL |
| `sqsCreator` | Crea cola SQS |
| `sqsAddData` | Inserta mensajes de prueba a SQS |
| `sqsPurgeData` | Limpia todos los mensajes de la cola |
| `create-step-function` | Crea/actualiza Step Function en LocalStack |
| `start-step-function` | Inicia una ejecución de Step Function |
| `start-execution` | Comienza ejecución de Step Function con parámetros |
| `inspect-executions` | Lista y analiza historiales de ejecución |

---

## 📦 STACK TECNOLÓGICO

### Frontend/Build

```json
{
  "Nx": "19.5.6",                    // Orquestación y caching
  "TypeScript": "5.x",               // CDK, generadores
  "Node.js": "20.x",                 // Runtime build
  "Jest": "29.4.1",                  // Testing TS
  "ESLint": "8.57.0",               // Linting
  "Prettier": "2.6.2",              // Code formatting
  "husky + lint-staged": "latest"   // Git hooks
}
```

### Backend .NET

```json
{
  ".NET SDK": "6.0 + 8.0",                              // Runtime
  "AWS CDK for .NET": "2.158.0",                        // IaC
  "AWS Lambda Runtime for .NET": "latest",             // Lambda execution
  "AutoMapper": "8.8.1",                               // Object mapping
  "xUnit": "latest",                                    // Testing framework
  "@ln/appolo-core-*": "2.x",                          // LN internal libraries
  "@ln/aws-core-cdk-utils": "2.1.1"                    // AWS CDK utils
}
```

### AWS Services (Integración)

- **Lambda**: Funciones event-driven serverless
- **SQS**: Colas de mensajes, event sources para Lambdas
- **SNS**: Pub/sub para notificaciones
- **EventBridge**: Eventos automáticos
- **DynamoDB**: Base de datos NoSQL
- **S3**: Object storage
- **Secrets Manager**: Gestión de credenciales
- **Step Functions**: Orquestación de workflows
- **CloudWatch**: Logs y monitoreo
- **IAM**: Control de acceso

### Local Development

- **LocalStack**: Emulación AWS completa en Docker
- **Docker Desktop**: Contenedorización
- **MySQL**: Base de datos relacional simulada

### CI/CD

- **Azure Pipelines**: Orquestación de build, test, deploy
- **NuGet**: Package management .NET
- **npm**: Package management TS

---

## 💡 CASOS DE USO

### ✅ Recomendado para:

1. **Minimal APIs serverless**
   - Endpoints HTTP bajo demanda
   - Integraciones sin servidor

2. **Listeners event-driven (SQS/EventBridge/SNS)**
   - Procesar mensajes de colas
   - Enrutamiento de eventos a handlers .NET
   - Workflows asincronos y retry

3. **Funciones Lambda event-driven (SQS)**
   - Si se requiere lógica de función aislada o tasks individuales

4. **Proyectos con múltiples Lambdas**
   - Estructura compartida centralizada
   - Código reutilizable entre funciones
   - Versionado unificado

4. **Equipos con estándares fuertes**
   - Estructura consistente obligatoria
   - Automatización de scaffold
   - Menos errores de configuración

5. **Desarrollo ágil y escalable**
   - Crear nuevas funciones en minutos
   - Deploy automático en CI/CD
   - Testing local con LocalStack

---

## 🎁 BENEFICIOS

| Beneficio | Impacto |
|-----------|--------|
| **Automatización de scaffold** | Reducir setup de 15 min a <1 min |
| **Estructura consistente** | Menos deuda técnica, fácil onboarding |
| **Tests preconfigurados** | Calidad desde el inicio |
| **Build incremental Nx** | Compilaciones 10x más rápidas |
| **LocalStack integration** | Desarrollo sin costos AWS reales |
| **CI/CD automático** | Deploy a producción sin pasos manuales |
| **Escalabilidad horizontal** | N funciones Lambda sin complejidad |
| **Versionado unificado** | Una sola verdad de versiones |

---

## 🚦 REQUISITOS PARA EMPEZAR

### Instalación

```bash
# 1. Node.js 20.x (recomendado vía nvm)
nvm install 20
nvm use 20

# 2. .NET SDK 6.0 y 8.0
sudo apt-get install -y dotnet-sdk-6.0 aspnetcore-runtime-6.0 dotnet-sdk-8.0

# 3. AWS CLI
aws configure --profile localstack
# Access Key ID = test
# Secret Access Key = test
# Region = us-east-1

# 4. Docker Desktop (WSL 2 en Windows)

# 5. Project dependencies
npm install
```

### Estructura de Desarrollo

**Primera kórida:**
```bash
npm install                    # ~2 min
npm run build:lambda          # ~30 seg
npm run initDocker            # ~1 min
npm run generate:lambda       # Responder 5 preguntas
npm run test                  # ~10 seg
npm run deploy:local          # ~1 min
```

---

## 📊 ARQUITECTURA DE EJEMPLO

**Caso de uso típico: Procesar suscripciones desde SQS**

```
┌───────────────────────────────────────────────────────┐
│                   AWS Account                         │
│                                                       │
│  ┌──────────┐       ┌──────────────┐                  │
│  │   SQS    │──────▶│   Lambda     │                 │
│  │ Queue    │       │ (Listener)   │                  │
│  └──────────┘       └──────┬───────┘                  │
│                            │                          │
│                     ┌──────▼────────┐                 │
│                     │ LN.Sus.Common │ (lib)           │
│                     │ - Mapper      │                 │
│                     │ - Validator   │                 │
│                     └──────┬────────┘                 │
│                            │                          │
│              ┌─────────────▼──────────────┐           │
│              │ DynamoDB / RDS             │           │
│              │ Persistencia               │           │
│              └────────────────────────────┘           │
│                                                       │
└───────────────────────────────────────────────────────┘

                         ▼

┌──────────────────────────────────────────────────────┐
│              Monorepo Ln.Sus.Template                │
│                                                      │
│  apps/SubscriptionListener                           │
│  ├── src/SubscriptionListener.Lambda/                │
│  │   └── Function.cs ← Entry point                   │
│  ├── tests/ ← xUnit tests                            │
│  ├── cdk/   ← IaC (Lambda + SQS mapping)             │
│  ├── local/ ← Local testing                          │
│  └── project.json                                    │
│                                                      │
│  libs/LN.Sus.Subscriptions.Common                    │
│  ├── Models/  ← DTOs                                 │
│  ├── Services/ ← Business logic                      │
│  └── Validators/                                     │
│                                                      │
│  CI/CD: Azure Pipelines                              │
│  ├── Build (dotnet build + npm)                      │
│  ├── Test (JUnit + xUnit)                            │
│  └── Deploy (aws cdk deploy)                         │
│                                                      │
└──────────────────────────────────────────────────────┘
```

---

## ⚡ COMANDOS CHEATSHEET

```bash
# ========== SETUP ==========
npm install
npm run initDocker
npm run mysqlCreator

# ========== GENERAR ==========
npm run generate:lambda        # Nueva Lambda
npm run generate:template      # Nuevo listener
npm run generate:lib           # Nueva librería
npm run delete:template        # Eliminar proyecto

# ========== BUILD & TEST ==========
npm run build                  # Incremental
npm run build:all             # Todos
npm run test                  # Incremental
npm run test:all              # Todos
npm run test:ci               # Con cobertura

# ========== LOCAL DEV ==========
npm run sqsCreator            # Crear cola
npm run sqsAddData            # Añadir mensajes
npm run sqsPurgeData          # Limpiar cola

# ========== DEPLOY ==========
npm run deploy:local          # Dev
npm run deploy:ci             # CI/CD

# ========== DEBUGGING ==========
# Run → Select and Start Debugging (Ctrl+Shift+D)
# VSCode launch.json preconfigurado
```

---

## 🔗 Integraciones Clave

### Con Azure Pipelines
- Trigger en: `main`, `develop`, `dev/*`, `qa/*`, `dp/*`
- Configuración por rama: `dev` → `qual`, `main` → `prod`
- Pipeline: Build → Test → Quality gate (SonarQube) → Deploy

### Con AWS
- Deploy automático a Lambda, SQS, StepFunctions
- Perfiles: `localstack` (dev local), `stg-Suscripciones` (staging)
- Retry y timeout configurables

### Con LocalStack
- Emulación local de AWS (sin costos)
- Ideales para:
  - Testing antes de deploy
  - Desarrollo offline
  - Experimentos sin riesgo

---

## 🧩 Coherencia con template-nx-dotnet-desde-cero.md
Este documento está alineado con el objetivo y los detalles técnicos de `template-nx-dotnet-desde-cero.md`, con foco en un resumen ejecutable. Aquí se resumen los puntos clave de la comparación:

- `tools/ln-generators` es el núcleo de scaffolding y contiene los 4 generadores: `add-template`, `add-lambda`, `add-lib`, `remove-template`.
- `add-template` (documentado en el otro archivo) usa `dotnet new`, limpia artefactos, actualiza `.sln`, crea `project.json`, actualiza `.vscode` y prepara `cdk/`.
- `add-lambda` exige `name` con sufijo `.lambda`, genera estructura `apps/<Stack>/{app/tests/local}`, incluye handler `Function.cs` y runner local.
- La solución `.sln` global se mantiene y es actualizada automáticamente por los generadores.
- El workspace Nx es un adaptador (no reemplazo) sobre la compilación real de .NET.
- Existen operaciones híbridas (Nx Tree + side effects `execSync`, `fs`) que pueden ser frágiles.
- Scripts mencionados en este documento reflejan los de `package.json`; se detecta que `build:lambda` puede estar listado en `.vscode` aunque no exista en `package.json`.

### Ajustes recomendados para mantener coherencia activa
1. Confirmar que `package.json` contenga `build:lambda` o removerlo del `.vscode/tasks.json`.
2. Mantener actualizado el Lotus de prompts de `add-template` (name/templateType/httpPort/httpsPort/orderRelease) y `add-lambda` (cdkOption/cdkName/name/memorySize/orderRelease).
3. Documentar en `analisis-arq.md` la convención de nombres de `add-lambda` para evitar errores en el uso.
4. Añadir alerta sobre el comportamiento de side-effects parciales si `dotnet new` o `dotnet sln` fallan en mitad de ejecución.

---

## 🎯 CONCLUSIÓN

**Ln.Sus.Monorepo.Template** es una plataforma **lista para producción** que combina:

- ✅ **Nx** para orquestar builds
- ✅ **AWS CDK** para IaC
- ✅ **.NET** para Lambda y APIs
- ✅ **Generadores automáticos** para reducir fricción
- ✅ **CI/CD integrado** (Azure Pipelines)
- ✅ **LocalStack** para desarrollo sin costos

**Ideal para equipos que desean:**
1. Crear Lambdas + APIs rápido sin errores
2. Mantener estándares arquitectónicos
3. Escalar de 1 a N funciones sin complejidad
4. Automatizar todo lo posible

---

*Documento generado: 2026-04-01 | Versión: 1.0*
