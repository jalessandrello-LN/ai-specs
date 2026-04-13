#!/bin/bash

STATE_MACHINE_ARN="arn:aws:states:us-east-1:000000000000:stateMachine:dev-blanqueo-maquina"
ENDPOINT="http://localhost:4566"
INPUT_FILE="./solutionItems/messages/step-function-messages/input_step_function.json"

echo "🚀 Ejecutando Step Function con payload de $INPUT_FILE..."

aws --endpoint-url=$ENDPOINT stepfunctions start-execution \
  --state-machine-arn "$STATE_MACHINE_ARN" \
  --input file://$INPUT_FILE