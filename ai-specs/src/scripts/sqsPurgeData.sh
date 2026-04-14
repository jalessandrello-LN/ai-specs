#!/bin/bash

# Configuración de LocalStack
ENDPOINT_URL="http://sqs.us-east-1.localhost.localstack.cloud:4566"
ACCOUNT_ID="000000000000"

while true; do
  # Pedir al usuario el nombre completo de la cola
  read -p "Ingrese el nombre completo de la cola SQS (ej: suscripciones-dev-sqs-mi-listener): " QUEUE_NAME

  # Validar input
  if [[ -z "$QUEUE_NAME" ]]; then
    echo "❌ Debe ingresar un nombre de cola válido."
    exit 1
  fi

  QUEUE_URL="$ENDPOINT_URL/$ACCOUNT_ID/$QUEUE_NAME"

  echo "🔄 Purgando mensajes de la cola: $QUEUE_NAME..."

  aws --endpoint-url=$ENDPOINT_URL sqs purge-queue --queue-url "$QUEUE_URL"

  if [ $? -eq 0 ]; then
    echo "✅ Mensajes eliminados exitosamente."
  else
    echo "❌ Error al purgar los mensajes."
  fi

  read -p "¿Desea purgar otra cola? (s/n): " another
  [[ "$another" =~ ^([sS][iI]?|[sS])$ ]] || break
done
