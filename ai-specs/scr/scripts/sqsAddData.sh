#!/usr/bin/env bash

# Configuración - el archivo se guardará en el mismo directorio del script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/.sqs_sender_config"
DEFAULT_ENDPOINT="http://sqs.us-east-1.localhost.localstack.cloud:4566"

# Función para cargar la configuración
load_config() {
    if [[ -f "$CONFIG_FILE" ]]; then
        source "$CONFIG_FILE"
    else
        LAST_QUEUE=""
    fi
}

# Función para guardar la configuración
save_config() {
    echo "LAST_QUEUE='$LAST_QUEUE'" > "$CONFIG_FILE"
}

# Función para verificar archivos
check_file() {
    local file_path="$1"
    
    # Eliminar comillas simples o dobles del inicio y final
    file_path="${file_path%[\'\"]}"
    file_path="${file_path#[\'\"]}"
    
    # Expandir ~ si está presente
    file_path="${file_path/#\~/$HOME}"
    
    # Convertir a ruta absoluta
    if [[ "$file_path" != /* ]]; then
        file_path="$(pwd)/$file_path"
    fi
    
    # Normalizar la ruta
    if command -v realpath >/dev/null 2>&1; then
        file_path="$(realpath -m "$file_path")"
    else
        file_path="$(cd "$(dirname "$file_path")" >/dev/null 2>&1 && pwd)/$(basename "$file_path")"
    fi
    
    echo "$file_path"
}

# Función para enviar mensaje
send_message() {
    local QUEUE_NAME=$1
    local FILE_PATH=$2
    
    # Configuración del endpoint
    ENDPOINT_URL="${3:-$DEFAULT_ENDPOINT}"
    QUEUE_URL="${ENDPOINT_URL}/000000000000/${QUEUE_NAME}"

    echo "🚀 Preparando enviar mensaje a la cola: $QUEUE_NAME"
    echo "📍 Endpoint: $ENDPOINT_URL"
    echo "🔗 Queue URL: $QUEUE_URL"

    read -p "¿Confirma que desea enviar este mensaje? (Y/n) default(Y): " confirm
    confirm=${confirm:-Y}  # Valor por defecto Y (sí)
    
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        echo "❌ Envío cancelado"
        return 1
    fi

    # Enviar mensaje
    response=$(aws sqs send-message \
      --endpoint-url="$ENDPOINT_URL" \
      --queue-url="$QUEUE_URL" \
      --message-body "file://$FILE_PATH" \
      2>&1)

    exit_code=$?

    if [ $exit_code -eq 0 ]; then
        echo "✅ Mensaje enviado exitosamente a $QUEUE_NAME"
        echo "📨 Message ID: $(echo "$response" | jq -r '.MessageId' 2>/dev/null || echo "$response")"
        
        # Guardar la queue usada
        LAST_QUEUE="$QUEUE_NAME"
        save_config
    else
        echo "❌ Error al enviar el mensaje a $QUEUE_NAME"
        echo "🔍 Detalles del error: $response"
        
        # Diagnósticos adicionales
        echo ""
        echo "🔧 Diagnósticos:"
        echo "   - Verificando conectividad a LocalStack..."
        curl -s "$ENDPOINT_URL" > /dev/null 2>&1 && echo "   ✅ Endpoint está respondiendo" || echo "   ❌ Endpoint no está respondiendo"
        
        echo "   - Verificando si la cola existe..."
        aws sqs get-queue-url --endpoint-url="$ENDPOINT_URL" --queue-name="$QUEUE_NAME" > /dev/null 2>&1 && \
          echo "   ✅ La cola existe" || echo "   ❌ La cola no existe o no es accesible"
    fi
    
    return $exit_code
}

# Cargar configuración previa
load_config
CURRENT_QUEUE="$LAST_QUEUE"

# Main
while true; do
    # Preguntar por la cola solo si no hay una actual o el usuario quiere cambiarla
    if [[ -z "$CURRENT_QUEUE" ]]; then
        read -p "Ingrese el nombre completo de la cola SQS (sin ARN) o 'q' para salir: " QUEUE_NAME
        if [[ "$QUEUE_NAME" == "q" ]]; then
            echo "👋 Saliendo del script..."
            exit 0
        fi
        CURRENT_QUEUE="$QUEUE_NAME"
    else
        echo ""
        echo "📌 Cola actual: $CURRENT_QUEUE"
        read -p "¿Desea usar una cola diferente? (y/N) default(N): " change_queue
        change_queue=${change_queue:-N}  # Valor por defecto N (no)
        
        if [[ "$change_queue" =~ ^[Yy]$ ]]; then
            read -p "Ingrese el nuevo nombre de la cola SQS: " QUEUE_NAME
            CURRENT_QUEUE="$QUEUE_NAME"
        fi
    fi

    if [[ -z "$CURRENT_QUEUE" ]]; then
        echo "❌ Debe ingresar un nombre de cola válido."
        continue
    fi

    # Preguntar por la ruta del archivo del mensaje
    read -p "Ingrese la ruta del archivo que contiene el mensaje JSON: " FILE_PATH_INPUT

    # Procesar la ruta del archivo
    FILE_PATH=$(check_file "$FILE_PATH_INPUT")

    echo "🔍 Verificando archivo en: $FILE_PATH"

    # Verificar si el archivo existe
    if [ ! -f "$FILE_PATH" ]; then
        echo "❌ El archivo especificado no existe: $FILE_PATH"
        echo "📁 Directorio actual: $(pwd)"
        echo "📋 Archivos disponibles:"
        ls -la "$(dirname "$FILE_PATH")" 2>/dev/null || echo "   El directorio no existe"
        continue
    fi

    # Verificar si el archivo es legible
    if [ ! -r "$FILE_PATH" ]; then
        echo "❌ El archivo no es legible: $FILE_PATH"
        continue
    fi

    # Verificar que el archivo contenga JSON válido
    echo "🔍 Validando formato JSON..."
    if ! python3 -m json.tool "$FILE_PATH" > /dev/null 2>&1; then
        echo "⚠️  Advertencia: El archivo no parece contener JSON válido"
        read -p "¿Desea continuar de todos modos? (y/N) default(N): " continue_anyway
        continue_anyway=${continue_anyway:-N}  # Valor por defecto N (no)
        
        if [[ ! "$continue_anyway" =~ ^[Yy]$ ]]; then
            continue
        fi
    fi

    # Enviar el mensaje
    send_message "$CURRENT_QUEUE" "$FILE_PATH" "$DEFAULT_ENDPOINT"

    # Preguntar si desea enviar otro mensaje
    read -p "¿Desea enviar otro mensaje? (Y/n) default(Y): " send_another
    send_another=${send_another:-Y}  # Valor por defecto Y (sí)
    
    if [[ ! "$send_another" =~ ^[Yy]$ ]]; then
        echo "👋 Saliendo del script..."
        exit 0
    fi
    
    echo ""
    echo "--------------------------------------------------"
    echo ""
done

# #!/bin/bash

# # Preguntar por el nombre completo de la cola SQS
# read -p "Ingrese el nombre completo de la cola SQS (sin ARN): " QUEUE_NAME

# if [[ -z "$QUEUE_NAME" ]]; then
#   echo "❌ Debe ingresar un nombre de cola válido."
#   exit 1
# fi

# # Preguntar por la ruta del archivo del mensaje
# read -p "Ingrese la ruta del archivo que contiene el mensaje JSON: " FILE_PATH

# if [ ! -f "$FILE_PATH" ]; then
#   echo "❌ El archivo especificado no existe: $FILE_PATH"
#   exit 1
# fi

# # Configuración de LocalStack
# ENDPOINT_URL="http://sqs.us-east-1.localhost.localstack.cloud:4566"
# QUEUE_URL="${ENDPOINT_URL}/000000000000/${QUEUE_NAME}"

# # Enviar mensaje
# aws sqs send-message \
#   --endpoint-url=$ENDPOINT_URL \
#   --queue-url=$QUEUE_URL \
#   --message-body file://$FILE_PATH

# if [ $? -eq 0 ]; then
#   echo "✅ Mensaje enviado exitosamente a $QUEUE_NAME"
# else
#   echo "❌ Error al enviar el mensaje a $QUEUE_NAME"
# fi
