#!/bin/bash

STATE_MACHINE_ARN="arn:aws:states:us-east-1:000000000000:stateMachine:dev-blanqueo-maquina"

INPUT='{
  "PK": "LN#123",
  "SK": "LN#PDD#PAGODEDEUDA#456"
}'

aws --endpoint-url=http://localhost:4566 stepfunctions start-execution \
  --state-machine-arn "$STATE_MACHINE_ARN" \
  --input "$INPUT"
