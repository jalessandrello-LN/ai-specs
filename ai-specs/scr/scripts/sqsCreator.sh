#!/bin/bash
read -p "Ingrese el nombre de la cola: " queueName

ENDPOINT_URL="http://sqs.us-east-1.localhost.localstack.cloud:4566"

# Detectar si es Zsh y definir función de lectura
if [ -n "$ZSH_VERSION" ]; then
    READ_PROMPT() {
        read "QueueName?Ingrese el nombre de la cola AWS: "
    }
    READ_CONFIRM() {
        read "response?$1 (s/n): "
    }
else
    READ_PROMPT() {
        read -p "Ingrese el nombre de la cola AWS: " QueueName
    }
    READ_CONFIRM() {
        read -p "$1 (s/n): " response
    }
fi

while true; do
    # Leer nombre de la cola
    READ_PROMPT

    # Validar que el nombre no esté vacío
    if [[ -z "$QueueName" ]]; then
        echo "❌ El nombre de la cola no puede estar vacío."
        continue
    fi

    echo "🔍 Verificando si la cola '$QueueName' existe..."

    # Verificar si la cola existe
    if aws --endpoint-url="$ENDPOINT_URL" sqs get-queue-url --queue-name "$QueueName" >/dev/null 2>&1; then
        echo "⚠️  La cola '$QueueName' ya existe."
        
        # Preguntar si desea otro nombre
        READ_CONFIRM "¿Desea crear otra cola con un nombre diferente?"
        if [[ $response =~ ^[Ss]$ ]]; then
            continue  # Volver a pedir nombre
        else
            echo "👋 Saliendo del script..."
            exit 0
        fi
    else
        echo "📝 La cola '$QueueName' no existe, procediendo a crearla..."
        
        # Crear la cola
        if aws --endpoint-url="$ENDPOINT_URL" sqs create-queue --queue-name "$QueueName" >/dev/null 2>&1; then
            echo "✅ Cola '$QueueName' creada exitosamente!"
        else
            echo "❌ Error al crear la cola '$QueueName'"
            READ_CONFIRM "¿Desea intentar con otro nombre?"
            if [[ $response =~ ^[Ss]$ ]]; then
                continue
            else
                echo "👋 Saliendo del script..."
                exit 1
            fi
        fi
        
        # Preguntar si desea crear otra cola
        READ_CONFIRM "¿Desea crear otra cola?"
        if [[ $response =~ ^[Ss]$ ]]; then
            continue  # Volver al inicio del bucle
        else
            echo "👋 ¡Gracias por usar el script!"
            break
        fi
    fi
done

echo "🔚 Script finalizado."

# #!/bin/bash

# QUEUE_NAME="suscripciones-dev-sqs-<%= queueName %>"

# aws --endpoint-url=http://sqs.us-east-1.localhost.localstack.cloud:4566 sqs get-queue-url --queue-name "$QUEUE_NAME" >/dev/null 2>&1

# if [ $? -eq 0 ]; then
#   echo "La cola ya existe: $QUEUE_NAME"
# else
#   echo "La cola no existe. Creándola..."
#   aws --endpoint-url=http://sqs.us-east-1.localhost.localstack.cloud:4566 sqs create-queue --queue-name "$QUEUE_NAME"
# fi
