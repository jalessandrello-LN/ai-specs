#!/bin/bash

STATE_MACHINE_NAME="dev-blanqueo-maquina"
ROLE_ARN="arn:aws:iam::000000000000:role/step-functions-local"
DEFINITION_FILE="./solutionItems/step-function/definition.json"
ENDPOINT="http://localhost:4566"

# Buscar si ya existe la máquina de estado por nombre
EXISTING_ARN=$(aws --endpoint-url=$ENDPOINT stepfunctions list-state-machines \
  --query "stateMachines[?name=='$STATE_MACHINE_NAME'].stateMachineArn" \
  --output text)

if [ -n "$EXISTING_ARN" ]; then
  echo "🔄 Máquina de estado: $EXISTING_ARN ya existe. Haciendo update..."
  aws --endpoint-url=$ENDPOINT stepfunctions update-state-machine \
    --state-machine-arn "$EXISTING_ARN" \
    --definition file://$DEFINITION_FILE
else
  echo "🆕 Máquina de estado no existe. Creando..."
  aws --endpoint-url=$ENDPOINT stepfunctions create-state-machine \
    --name "$STATE_MACHINE_NAME" \
    --definition file://$DEFINITION_FILE \
    --role-arn "$ROLE_ARN"
fi
