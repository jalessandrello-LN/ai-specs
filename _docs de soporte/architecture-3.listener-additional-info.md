# LaNacion.Core.Templates.SqsRdr

Plantilla (template) para crear nuevos workers de .NET 6 que procesan mensajes de colas SQS.

## Propósito

- **Objetivo:** Proveer una base consistente y lista para producción para la creación de microservicios de procesamiento en segundo plano. Incluye una estructura de proyectos basada en Clean Architecture, configuraciones por ambiente, scripts de BD y definiciones de infraestructura como código (CDK).
- **Uso típico:** Arrancar un nuevo microservicio que necesita escuchar una cola SQS, procesar mensajes de forma asíncrona y realizar operaciones de negocio (ej: actualizar una base de datos, llamar a otras APIs, etc.).

## Requisitos
- .NET SDK (recomendado: .NET 6 o superior).
- Node.js + npm (para trabajar con el proyecto `cdk/`).
- Docker (opcional, para build y ejecución en contenedores).
- Visual Studio 2022.

## Estructura principal del repositorio
- `cdk/`: Infraestructura como Código (AWS CDK en TypeScript) para desplegar los recursos en AWS.
- `src/`: Código fuente de la solución .NET.
	- `LaNacion.Core.Templates.SqsRdr/`: Proyecto principal del worker (Host y Capa de Infraestructura).
	- `LaNacion.Core.Templates.SqsRdr.Application/`: Capa de aplicación (lógica de casos de uso).
    - `LaNacion.Core.Templates.SqsRdr.Application.Interfaces/`: Define las abstracciones (interfaces) de la infraestructura.
	- `LaNacion.Core.Templates.SqsRdr.Domain/`: Modelos y lógica de dominio.
    - `LaNacion.Core.Templates.SqsRdr.Domain.Events/`: Define los eventos de dominio que se manejan.
	- `LaNacion.Core.Templates.SqsRdr.Repositories.SQL/`: Implementaciones de persistencia con Dapper.
- `Dockerfile`: Definición para construir la imagen Docker del worker.
- `azure-pipelines.yml`: Pipeline de ejemplo para CI/CD en Azure DevOps.
- `MensajesRecibidos_DB_Artifacts.sql`: Script para crear la tabla de idempotencia.

## Guía de Inicio Rápido

### 1. Configurar el Entorno de Desarrollo
#### Instalar el template desde NuGet
Para acceder al feed de paquetes NuGet de La Nación, es necesario instalar el **Azure Artifacts Credential Provider**. Utilitario de GitHub - microsoft/artifacts-credprovider: The Azure Artifacts Credential Provider.

- **En Windows:**
  ```powershell
  iex "& { $(irm https://aka.ms/install-artifacts-credprovider.ps1) }"
  ```
- **En Linux:**
  ```bash
  wget -qO- https://aka.ms/install-artifacts-credprovider.sh | bash
  ```

Descargar los templates desde los pacakages Nuget propios de La Nacion para poder generar las Minimals APIs.

Para ello desde la consola de comando ejecutar los siguientes comandos:

Minimal Api Template:

  ```powershell
	  dotnet new install lanacion.Core.MinimalWebApi.Template --nuget-source https://pkgs.dev.azure.com/lndigital/_packaging/lanacion-v2/nuget/v3/index.json --interactive
  ```
o

```powershell
	dotnet new -i lanacion.Core.MinimalWebApi.Template --nuget-source https://pkgs.dev.azure.com/lndigital/_packaging/lanacion-v2/nuget/v3/index.json --interactive
```

La opción **--interactive** verificará si hay una sesión válida iniciada en Azure, si la hay se ejecutará sin más. Si no, solicitará loguearse a Azure para establecer una sessión válida. Para ello hay que abrir un navegador apuntando a la url que indica la herramienta y copiar el código (blureado en la imagen) en el cuadro de texto, clickear en siguiente, y la instalación continuará automáticamente

![](azureArtifactsAuth.png)


#### Configurar Acceso AWS
	1. Ejecutar la Terminal como Administrador
		Si estás en Windows, sigue estos pasos para abrir el Símbolo del sistema (cmd) con privilegios de administrador:

		Presiona Windows + R para abrir el cuadro de diálogo "Ejecutar".

		Escribe cmd en el campo de texto.	Antes de presionar Enter, mantén presionadas las teclas Ctrl + Shift y luego presiona Enter.

		Esto abrirá el Símbolo del sistema con privilegios de administrador.


	2. Configuración de SSO
		Una vez abierta la consola, ejecuta el siguiente comando:
		```powershell   
		aws configure sso
		```
		Completa el prompt de configuración con la siguiente información:

    	* **SSO Session Name:** Ingresa un nombre de sesión. Puedes elegir cualquier nombre; en futuras configuraciones, al repetir este proceso, podrás usar el mismo nombre para saltarte estos pasos. Para este ejemplo, escribamos stg-suscripciones.

    	* **SSO Start URL:** Usa la siguiente URL: https://lanacion.awsapps.com/start/
    	* **SSO Region:** Nuestra región es us-east-1.
    	* **SSO Registration Scopes:** Introduce el número de cuenta correspondiente. Si no lo conoces, puedes presionar Enter, ya que el SSO detectará las cuentas a las que tienes permiso de ingresar.

		Una vez completado el prompt, el navegador se abrirá y mostrará un código. Este código debe coincidir con el que se muestra en la terminal. Si coincide, en el navegador haz clic en Confirm and Continue. Posteriormente, aparecerá una vista pidiendo autorización.

		Después de otorgar los permisos, vuelve a la terminal y elige la cuenta que deseas configurar (para este ejemplo, usaremos la cuenta de STG-Suscripciones).

	3. Para Finalizar de la Configuración: 

		* **Región por defecto:** Puedes presionar Enter si la región por defecto (us-east-1) es correcta. Si no es la región deseada, ingresa la región correcta.
		* **Formato de salida por defecto:** El valor por defecto es json. Si no deseas cambiarlo, presiona Enter.
		* **Nombre del perfil:** Se recomienda usar el nombre de la cuenta en minúsculas, pero si prefieres otro nombre, puedes cambiarlo o simplemente presionar Enter para dejar el valor por defecto.

### 2. Crear una nueva solución usando el template

#### Crear la solución
1. ejecutar dotnet new:

```powershell
	dotnet new ln-SQSlstnr -n [nombreQueQuieroDeLaSolucion]
```

2. Ajustar la configuración de entorno
2. Ajustar la configuración de entorno

La plantilla está pre-configurada para funcionar con servicios locales en contenedores (ej: LocalStack para SQS, y una base de datos MySQL).

- Revisar `src/*/appsettings.*.json` y `config/appSettings.*.json` y añadir valores específicos (connection strings, keys, etc.).
  - **`ConnectionStrings`**: Asegúrese de que el `connectionString` apunte a su base de datos MySQL local o en un contenedor. El valor `host.docker.internal` es usado para conectar desde el contenedor del worker a un servicio corriendo en el host de Docker.
  - **`AWSSQSConnectionSettings`**:
    - `ServiceURL`: Apunta a la URL de su instancia de LocalStack.
    - `QueueUrlMappings`: Mapea la clase del evento (`Customer_Added`) con la URL de la cola SQS en LocalStack (ej: `http://sqs.us-east-1.localhost.localstack.cloud:4566/000000000000/customer-created`).

- Para secretos, es preferible usar aws secret manager.

#### Restaurar, Compilar y Ejecutar

Desde la raíz de la solución, ejecute los siguientes comandos:

```powershell
# Restaurar dependencias de NuGet
dotnet restore [nombreQueQuieroDeLaSolucion].sln

# Compilar la solución
dotnet build [nombreQueQuieroDeLaSolucion].sln

```
Al ejecutarse, la consola mostrará los logs de Serilog indicando que el servicio está corriendo y escuchando la cola SQS configurada.

#### Ejecutar

```powershell
# Ejecutar el worker
dotnet run --project [nombreQueQuieroDeLaSolucion]/[nombreQueQuieroDeLaSolucion].csproj
```
1.  Con el worker corriendo y conectado a LocalStack, enviar un mensaje a la cola SQS `customer-created`. El cuerpo del mensaje debe ser un JSON que corresponda a la estructura de la clase `Customer_Added` en el proyecto `Domain.Events`.
2.  Observar los logs del worker. Debería ver la recepción del mensaje, el procesamiento por parte de `MessageProcessor` y la confirmación de la persistencia.
3.  Verificar la base de datos MySQL para confirmar que el nuevo cliente ha sido guardado.

#### Trabajar con la infraestructura (CDK)

El proyecto `cdk/` le permite desplegar toda la infraestructura necesaria en AWS.

```powershell
# Navegar a la carpeta de CDK
cd cdk

# Instalar dependencias de npm
npm install

# Compilar el código de TypeScript a JavaScript
npm run build

# Sintetizar la plantilla de CloudFormation (opcional, para ver el resultado)
cdk synth

# Desplegar en AWS (requiere tener perfiles de AWS configurados)
# Reemplace [SuPerfilDeAWS] con el nombre de su perfil configurado
npx cdk deploy --profile [SuPerfilDeAWS] --require-approval never
```
**Bases de datos**
- Scripts listos: `SqlServer_DB.sql`, `Postgre_DB.sql`, `MySql_DB.sql`. Úsalos como punto de partida para crear los esquemas necesarios.

**Docker y CI**
- `Dockerfile` incluido para construir imágenes de la API.
- `azure-pipelines.yml` muestra un pipeline de ejemplo (adaptar a su infraestructura de CI).


## Buenas Prácticas y Personalización
- **Nuevos Eventos**: Para escuchar un nuevo tipo de evento, registre un nuevo `SqsQueueConsumerService<T>` y su `SqsQueueNameService<T>` correspondiente en `Workers/ConfigureServicesExtensions.cs` y cree el `Handler` en la capa de Aplicación.
- **Secretos**: No guarde información sensible en `appsettings.json`. Utilice el gestor de secretos de .NET para desarrollo local y AWS Secrets Manager para los ambientes de nube.
