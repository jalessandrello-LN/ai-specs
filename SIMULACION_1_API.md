# SIMULACIÓN 1: Requerimiento de API

## Entrada del Usuario
```
/plan-backend-ticket HU-101
```

**Descripción del Ticket HU-101:**
- Crear endpoint para actualizar estado de suscripción
- Método: PUT /api/v1/subscriptions/{id}/status
- Validar estado anterior y nuevo
- Publicar evento de cambio de estado
- Requiere autenticación JWT

## Flujo Esperado

### Paso 1: Clasificación
- ✅ Agente: `lanacion-backend-planner`
- ✅ Tipo detectado: **API** (endpoint HTTP)
- ✅ Estándar: `ln-susc-api-standards.mdc`

### Paso 2: Generación de Plan
- ✅ Archivo generado: `ai-specs/changes/HU-101_backend.md`
- ✅ Prefijo de ticket: **HU-101** ✅
- ✅ Estructura: Domain → Application → Infrastructure → Presentation → Tests

### Paso 3: Validación de Coherencia
- ✅ Plan incluye: Command, Validator, Handler, Repository, Endpoint
- ✅ Eventos publicados correctamente
- ✅ Cobertura de tests: 80%+

## Resultado Esperado
```
✅ Plan generado: ai-specs/changes/HU-101_backend.md
✅ Prefijo correcto: HU-101
✅ Tipo: API
✅ Estándar aplicado: ln-susc-api-standards.mdc
```
