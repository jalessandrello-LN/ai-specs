# Monorepo NX para Listeners .NET y Minimal APIs

Este repositorio contiene múltiples aplicaciones .NET organizadas como funciones Lambda o APIs, gestionadas mediante [Nx](https://nx.dev). Usamos generadores personalizados para scaffoldear listeners, funciones Lambda y minimal web APIs de forma estandarizada y automática.

---

## ⚙️ Requisitos de Configuración Inicial

### 🖥️ Sistema
- Docker Desktop con WSL 2 habilitado (para Windows)
- WSL 2 (Ubuntu recomendado)

### 📦 Herramientas necesarias
- Node.js 20 via [nvm](https://github.com/nvm-sh/nvm):
  ```bash
  nvm install 20
  nvm use 20
  ```

- .NET SDK 6 **(runtime incluido)**:
  ```bash
  sudo apt-get install -y dotnet-sdk-6.0
  sudo apt-get install -y aspnetcore-runtime-6.0
  ```

- .NET SDK 8:
  ```bash
  sudo apt-get install -y dotnet-sdk-8.0
  ```

- AWS CLI:
  ```bash
  aws configure --profile localstack
  ```
  > Recomendado: `Access Key ID = test`, `Secret Access Key = test`, `Region = us-east-1`, `Output = json`

- LocalStack instalado y funcionando con Docker

---

## 🗂️ Estructura del Proyecto

```bash
apps/NombreDelProyecto/
├── src/
│   └── NombreDelProyecto/
├── tests/
│   └── NombreDelProyecto.Tests/
├── cdk/
├── project.json
```

---

## 🧬 Generadores Disponibles

### ✅ Generar un nuevo listener o minimal API:
```bash
npm run generate:template
```
- Preguntas:
  - ¿Querés usar un CDK existente o crear uno nuevo? (1= Stack existente / 2= Crear uno nuevo)
  - ¿Cuál es el nombre del stack CDK?
  - ¿Cuál es el nombre de la función lambda? (debe terminar en `.lambda`)
  - ¿Cuál es el namespace base de la función lambda? (ej: `LN.Sus.EventoPrueba.Lambda`)
  - ¿Cuánta memoria necesita la lambda? (en MB)

### 🧬 Generar una función Lambda (sin listener/API):
```bash
npm run generate:lambda
```
- Preguntas:
  - ¿Querés usar un CDK existente o crear uno nuevo? (1= Stack existente / 2= Crear uno nuevo)
  - ¿Cuál es el nombre del stack de CDK?
  - ¿Cuál es el nombre de la función lambda? (debe terminar en `.lambda`)
  - ¿Cuánta memoria necesita la lambda? (en MB)

### ❌ Eliminar un proyecto existente:
```bash
npm run delete:template
```

### 🧪 Generar librería compartida:
```bash
npm run generate:lib
```

---

## 🧰 Scripts de NPM

```bash
npm run build:all       # Compila todos los proyectos
npm run build           # Compila los modificados (por defecto)
npm run dotnet:build    # Ejecuta dotnet build sobre el .sln
npm run build:local     # Compila en modo dev con limpieza previa
npm run build:ci        # Build completo + deploy.sh

npm run test:all        # Ejecuta tests en todos los proyectos
npm run test            # Ejecuta tests en proyectos modificados
npm run test:ci         # Ejecuta tests y cobertura
npm run coverage        # Genera informe de cobertura

npm run format:write    # Aplica formato
npm run format:check    # Verifica formato
npm run eslint:check    # Verifica con eslint

npm run generate:template  # Crear listener/API
npm run delete:template    # Eliminar listener/API
npm run generate:lambda    # Crear Lambda simple
npm run generate:lib       # Crear librería compartida
```

---

## 🧪 Tests generados automáticamente

Cada template genera una estructura de tests dentro de:
```
tests/NOMBRE_DEL_PROYECTO.Tests/
```
Y se agrega automáticamente al `.sln` y al proyecto con un `.csproj` listo para correr.

---

## ⚡ VSCode: Debug y Tasks

### 🔍 Ejecutar o debuguear

- Cada listener tiene su `launch.json` con puertos y entorno preconfigurado.
- Podés iniciar desde Run and Debug (`Ctrl+Shift+P`).
- Debug: Select and Start Debugging

### 🛠️ Ejecutar tareas personalizadas
```bash
Ctrl + Shift + P → Tasks: Run Task
```
- `generate template`
- `delete template`
- `generate lambda`
- `run listener {nombre}`
- `Crear cola`, `Purgar cola`, `Añadir datos a la cola`

---

## 🧠 Nx + .NET = 🔥

Cuando modificás una librería como `Ln.Sus.Monorepo.Template.Services`, MSBuild recompila automáticamente los proyectos dependientes.

Pero si querés que **Nx** lo tenga en cuenta para `nx affected`, agregá en el `project.json`:

```json
{
  "implicitDependencies": ["Ln.Sus.Monorepo.Template.Services"]
}
```

---

## 🚀 Cómo funciona el generador de templates

- Crea la estructura `src`, `cdk` y `tests` automáticamente
- Usa templates `.tmpl` con placeholders (`<%= name %>`, etc.)
- Genera `launch.json` y `tasks.json`
- Limpia archivos no necesarios del template (`.editorconfig`, `.gitignore`, etc.)
- Agrega todos los `.csproj` al `.sln`
- Si no tiene el template, lo instala dinámicamente desde Azure

---

## 🗑️ Cómo funciona el removedor

- Elimina todos los `.csproj` del `.sln` con búsqueda recursiva
- Borra la carpeta `apps/{proyecto}` completa
- Elimina referencias en `launch.json` y `tasks.json`
- Limpia cualquier configuración residual

---

## 💙 Con amor por el equipo de suscripciones

Todo esto se pensó para acelerar la creación de listeners y APIs, reducir errores y facilitar el mantenimiento.