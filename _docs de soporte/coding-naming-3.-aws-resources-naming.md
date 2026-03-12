## Nombres de recursos
(Reducimos de 5 a 4 segmentos a partir del 25/1/2024 para acotar los problemas de largo de nombres en AWS) Definimos utilizar cuatro segmentos que responden a las siguientes preguntas:
1 - ¿A qué producto pertenece?
2 - ¿Para qué entorno?
3 - ¿Qué proyecto es?
4 - ¿Qué componente de ese proyecto es? (Opcional)

### {product/solution}-{environment}-{component}-{project/aplication}
Ej: `suscripciones-prod-stack-cobro-dashboard`

### En el caso de colas sqs 
### {product/solution}-{environment}-{component}-{evento/comando}
Ej: `suscripciones-prod-sqs-cobro-registraciontarjeta`
En el caso de las dead letter queues se le agrega ek subfijo '_dlq'
Ej: `suscripciones-prod-sqs-cobro-registraciontarjeta_dlq`

### Opciones de nombres por segmento

#### product:
* suscripciones
* experiencias

#### environment:
* qa
* dev
* pre
* prod

#### ejemplo component:
* stack
* role
* sqs
* …

#### ejemplo project:
* cobro
* cic
* …


**Ejemplo de cómo veríamos un listado de lambdas:**

```text
lanacion-prod-arcexporter-a
lanacion-prod-arcexporter-b
lanacion-prod-arcexporter-c
lanacion-prod-audionews-a
lanacion-prod-audionews-b
lanacion-prod-audionews-c
```
## Tags

Todos los recursos deben tener estos tags, que heredan del stack que los crea

### Los siguientes tags los usa Datadog

* `SERVICE`: nombre de la aplicación, minuscula, acepta guiones  
* `VERSION`: versión deployada.  
* `ENV`: entorno. Puede ser: `dp`, `beta`, `qa`, `pre`, `prod`

### Los siguientes tags los usa Operaciones:

* `AMBIENTE`: PRODUCCION O STAGING
* `APLICACION`: nombre de la aplicación
* `AREA`: área dueña de la aplicación
* `CC`: centro de costos
* `DIRECCION`
* `GERENCIA`
* `PRODUCTO`: producto de SAP. (Ver valores posibles en tabla al final)
* `SOLUCION`: nombre que agrupa las diferentes aplicaciones.

## Valores posibles del tag PRODUCTO:

| **PRODUCTO** | **DESCRIPCION**              | **TRIBUS/EQUIPOS**                | **Soluciones posibles**                                                   |
| ------------ | ---------------------------- | --------------------------------- | ------------------------------------------------------------------------- |
| LN136Z       |                              | Maximización                      |                                                                           |
| LN136Z       | Suscripción Digital + Club   | Tribu Suscripciones y Club        | * ClubLN<br>* Credenciales                                               |
| LN414Z       | CPM - VIDEO -ROS             | Tribu Contenidos                  | * Videos                                                                  |
| LN301Z       | LaNacion.com                 | Tribu Contenidos                  | * ArcExporter<br>* ArcImporter<br>* ArcRepublisher<br>* ArcPosPublicationService |
| LN385Z       | Audio                        | Tribu Contenidos                  | * AudioNews                                                               |
| LN386Z       | Foodit                       | Tribu Contenidos                  | * Foodit                                                                  |
| LN387Z       | Canchallena                  | Tribu Contenidos                  | * Canchallena                                                             |
| LN388Z       | Gaming                       | Tribu Contenidos                  | * Juegos                                                                  |
| PU6010       | Bonvivir                     | Tribu Nuevos Negocios             | * Bonvivir                                                                |
| LN9999       | Indirecto General            | Todo lo genérico. Cualquier Tribu | * Notificaciones<br>* Newsletters                                        |
| LI7000       | Libooks                      | Tribu Nuevos Negocios             | * Libooks                                                                 |
| PU4791       | LN+                          | Tribu Contenidos                  | * TV                                                                      |
| LN1010       | Diario Print y Circulación   | Tribu Nuevos Negocios             | * SGDI<br>* Concentrador                                                 |
| LN147Z       | IA Core                      | A definir                         | A definir                                                                 |

## Centros de costos frecuentes

| **Sociedad**              | **Centro de costos** | **Responsable del presupuesto** | **Squad**     |
| ------------------------- | -------------------- | -------------------------------- | ------------- |
| SA LA NACION              | LN422                | Mauro Terrizzi                  |               |
| PUBLIREVISTAS (BONVIVIR) | PU422                | Mauro Terrizzi                  |               |
| SA LA NACION              | LN450                | Lore Artal / Roger Mantilero    |               |
| SA LA NACION              | LN452                | Mauro Morigi                    |               |
|                           | LN422                |                                  | Maximización  |