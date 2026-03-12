## Intro

Una API REST, o API RESTful, es una interfaz de programación de aplicaciones (API o API web) que es la base de una arquitectura REST. Las API son conjuntos de definiciones y protocolos que **se utilizan para integrar aplicaciones**. Suele considerarse como **un contrato entre el proveedor de información y el consumidor**, donde se establece el contenido que se necesita por parte del consumidor (la llamada) y el que requiere el productor (la respuesta).

Las API RESTful requieren que las **solicitudes contengan** los siguientes componentes principales:

**Identificador único de recursos**  
El servidor identifica cada recurso con identificadores únicos de recursos. En los servicios REST, el servidor por lo general identifica los recursos mediante el uso de un localizador uniforme de recursos (URL). El URL especifica la ruta hacia el recurso. Un URL es similar a la dirección de un sitio web que se ingresa al navegador para visitar cualquier página web. El URL también se denomina punto de conexión de la solicitud y especifica con claridad al servidor qué requiere el cliente.

**Método**  
Los desarrolladores a menudo implementan API RESTful mediante el uso del protocolo de transferencia de hipertexto (HTTP). Un método de HTTP informa al servidor lo que debe hacer con el recurso. A continuación, se indican cuatro métodos de HTTP comunes:

**GET**  
Los clientes utilizan GET para acceder a los recursos que están ubicados en el URL especificado en el servidor. Pueden almacenar en caché las solicitudes GET y enviar parámetros en la solicitud de la API RESTful para indicar al servidor que filtre los datos antes de enviarlos.

**POST**  
Los clientes usan POST para enviar datos al servidor. Incluyen la representación de los datos con la solicitud. Enviar la misma solicitud POST varias veces produce el efecto secundario de crear el mismo recurso varias veces.

**PUT**  
Los clientes utilizan PUT para actualizar los recursos existentes en el servidor. A diferencia de POST, el envío de la misma solicitud PUT varias veces en un servicio web RESTful da el mismo resultado.

**DELETE**  
Los clientes utilizan la solicitud DELETE para eliminar el recurso. Una solicitud DELETE puede cambiar el estado del servidor.

Los principios de REST requieren que **la respuesta del servidor contenga los siguientes componentes** principales:

**Estado**  
La línea de estado contiene un código de estado de tres dígitos que comunica si la solicitud se procesó de manera correcta o dio error. Por ejemplo, los códigos 2XX indican el procesamiento correcto, pero los códigos 4XX y 5XX indican errores. Los códigos 3XX indican la redirección de URL.

A continuación, se enumeran algunos códigos de estado comunes:

- 200: respuesta genérica de procesamiento correcto  
- 201: respuesta de procesamiento correcto del método POST  
- 400: respuesta incorrecta que el servidor no puede procesar  
- 404: recurso no encontrado  

**Cuerpo del mensaje**  
El cuerpo de la respuesta contiene la representación del recurso. El servidor selecciona un formato de representación adecuado en función de lo que contienen los encabezados de la solicitud. Los clientes pueden solicitar información en los formatos XML o JSON, lo que define cómo se escriben los datos en texto sin formato. Por ejemplo, si el cliente solicita el nombre y la edad de una persona llamada John, el servidor devuelve una representación JSON como la siguiente:

```json
{"name": "John", "age": 30}
```

**Encabezados**
La respuesta también contiene encabezados o metadatos acerca de la respuesta. Estos brindan más contexto sobre la respuesta e incluyen información como el servidor, la codificación, la fecha y el tipo de contenido.

## REST Enpoints Naming & Conventions

Un recurso nombrado adecuadamente hace que una API sea simple de usar e intuitiva. La misma API, cuando se implementa incorrectamente, puede resultar complicada y desafiante de usar y comprender. El siguiente artículo te ayudará a comenzar a construir los URI de recursos para tu nueva API.

##### Usar minúsculas en las URIs
Usar letras minúsculas en las URIs para mantener consistencia entre diferentes endpoints 

**No usar funciones CRUD como nombres en las URIs**
*No se debe usar URIs para indicar una función CRUD. Los URIs solo deben usarse para identificar los recursos y no para indicar una acción específica sobre ellos.*

Debemos usar los métodos de solicitud HTTP para indicar qué función CRUD se está realizando.

```text
HTTP GET /device-management/managed-devices             //Get all devices 
HTTP POST /device-management/managed-devices            //Create new Device 
HTTP GET /device-management/managed-devices/{id}        //Get device for given Id 
HTTP PUT /device-management/managed-devices/{id}        //Update device for given Id 
HTTP DELETE /device-management/managed-devices/{id}     //Delete device for given Id
``` 

##### Usar sustantivos para representar recursos / No verbos

Las  **URIs deben ser nombrados con sustantivos** para especificar el recurso **en lugar de usar verbos**. Los URIs no deberían indicar ninguna operación CRUD (Crear, Leer, Actualizar, Eliminar). Además, debe evitarse combinaciones verbo-sustantivo  

Ejemplos Erroneos:  
http://api.example.com/v1/store/CreateItems/{item-id}    ❌
http://api.example.com/v1/store/getEmployees/{emp-id}    ❌
http://api.example.com/v1/store/update-prices/{price-id} ❌
http://api.example.com/v1/store/deleteOrders/{order-id}  ❌

Ejemplos Correctos:  
http://api.example.com/v1/store/items/{item-id}    ✅
http://api.example.com/v1/store/employees/{emp-id} ✅
http://api.example.com/v1/store/prices/{price-id}  ✅
http://api.example.com/v1/store/orders/{order-id}  ✅

##### Usar sustantivos en plural para recursos

Usar el plural cuando sea posible, a menos que se trate de recursos singleton.
Por ejemplo, "customers" (clientes) es un recurso de colección y "customer" (cliente) es un recurso singleton (en un dominio bancario).  

Podemos identificar el recurso de colección "customers" usando el URI “/customers“. Podemos identificar un recurso individual "customer" usando el URI “/customers/{customerId}“.
`http://api.example.com/v1/customers`                   //es un recurso de colección  
`http://api.example.com/v1/customers/{id}`              //es un recurso singleton  

##### Recursos de Colección y Subcolección

Un recurso también puede contener recursos de subcolección.  
Por ejemplo, el recurso de subcolección "accounts" (cuentas) de un "customer" en particular puede identificarse usando el URN “/customers/{customerId}/accounts” (en un dominio bancario).  

De manera similar, un recurso singleton "account" (cuenta) dentro del recurso de subcolección "accounts" puede identificarse de la siguiente manera: “/customers/{customerId}/accounts/{accountId}“.  

`http://api.example.com/v1/customers`                        //es un recurso de colección  
`http://api.example.com/v1/customers/{id}/accounts`          //es un recurso de subcolección  

**Ejemplos Erróneos (Recursos típicos y singleton):**  
http://api.example.com/v1/store/item/{item-id}             ❌
http://api.example.com/v1/store/employee/{emp-id}/address  ❌

**Ejemplos Correctos(Recursos típicos y singleton):**  
http://api.example.com/v1/store/items/{item-id}             ✅
http://api.example.com/v1/store/employees/{emp-id}/address  ✅

##### Usar guiones (-) para mejorar la legibilidad de los URIs
> No usar guión bao (_).

**Ejemplos Erróneos** :  
`http://api.example.com/v1/store/vendormanagement/{vendor-id}❌`
`http://api.example.com/v1/store/itemmanagement/{item-id}/producttype❌`
`http://api.example.com/v1/store/inventory_management❌`

**Ejemplos Correctos**:  
`http://api.example.com/v1/store/vendor-management/{vendor-id}✅`  
`http://api.example.com/v1/store/item-management/{item-id}/product-type✅`
`http://api.example.com/v1/store/inventory-management✅`

##### Usar barras inclinadas (/) para jerarquía, pero no barra inclinada final (/)*

Las barras inclinadas se utilizan para mostrar la jerarquía entre recursos individuales y colecciones.  

**Ejemplos Erróneos** :  
`http://api.example.com/v1/store/items/❌`

**Ejemplos Correctos**:  
`http://api.example.com/v1/store/items✅`

##### No usar extensiones de archivo

Son innecesarias y añaden longitud y complejidad a los URIs.  

**Ejemplos Erróneos** :  
`http://api.example.com/v1/store/items.json❌`
`http://api.example.com/v1/store/products.xml❌`

**Ejemplos Correctos**:  
`http://api.example.com/v1/store/items✅`
`http://api.example.com/v1/store/products✅`

##### Usa el QueryString para filtrar la colección de URIs

Ante requisitos que requieran ordenar, filtrar o limitar un grupo de recursos en función de uno o varios atributos de recurso particular, puede utilizarse parámetros en el querystring, para realizar estas operaciones. .  

`http://api.example.com/v1/store/items?group=124`
`http://api.example.com/v1/store/employees?department=IT&region=USA`

##### Versionado de APIs

Proporcionar una ruta con la actualización sin hacer cambios en las APIs existentes versionando las APIs. Permite independencia en la evolución del servicio y no requiere esperar que todos los clientes actualicen las llamadas a la api ya que permite la ejecución en paralelo de diferentes versiones del mismo código  

**Ejemplos Correctos**:  
`http://api.example.com/v1/store/employees/{emp-id}`

La introducción de cualquier actualización importante puede evitarse con la siguiente /v2.  

`http://api.example.com/v1/store/items/{item-id}`
`http://api.example.com/v2/store/employees/{emp-id}/address`
