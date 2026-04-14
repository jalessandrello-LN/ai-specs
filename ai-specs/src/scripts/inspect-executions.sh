#!/bin/bash

STATE_MACHINE_NAME="dev-blanqueo-maquina"
ENDPOINT="http://localhost:4566"

# 🧪 Validar dependencia jq
if ! command -v jq &> /dev/null; then
  echo "❌ El comando 'jq' no está instalado. Es necesario para analizar la ejecución."
  echo "👉 Instalalo con: sudo apt install jq"
  exit 1
fi

echo "🔍 Buscando ARN de la máquina de estado..."
STATE_MACHINE_ARN=$(aws --endpoint-url=$ENDPOINT stepfunctions list-state-machines \
  --query "stateMachines[?name=='$STATE_MACHINE_NAME'].stateMachineArn" \
  --output text)

if [ -z "$STATE_MACHINE_ARN" ]; then
  echo "❌ No se encontró la máquina de estado '$STATE_MACHINE_NAME'"
  exit 1
fi

echo "✅ ARN encontrado: $STATE_MACHINE_ARN"

echo "📋 Buscando ejecución más reciente..."
EXECUTION_ARN=$(aws --endpoint-url=$ENDPOINT stepfunctions list-executions \
  --state-machine-arn "$STATE_MACHINE_ARN" \
  --query "sort_by(executions, &startDate)[-1].executionArn" \
  --output text)

if [ -z "$EXECUTION_ARN" ] || [ "$EXECUTION_ARN" == "None" ]; then
  echo "❌ No hay ejecuciones registradas aún."
  exit 0
fi

echo "📌 Última ejecución: $EXECUTION_ARN"
echo "📊 Resumen de pasos ejecutados:"
echo ""

aws --endpoint-url=$ENDPOINT stepfunctions get-execution-history \
  --execution-arn "$EXECUTION_ARN" \
  --output json | node ./scripts/parseExecution.js
