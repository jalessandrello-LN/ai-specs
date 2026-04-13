# Verificar que la variable de entorno $ENV esté definida y no esté vacía
if [ -z "$ENV" ]; then
  echo "Error: La variable de entorno ENV no está definida."
  exit 1
fi

# Configurar timeouts para evitar errores de socket al publicar Lambdas grandes o múltiples
export AWS_METADATA_SERVICE_TIMEOUT=30000
export AWS_METADATA_SERVICE_NUM_ATTEMPTS=5
export AWS_CLIENT_TIMEOUT=600000

DIST_DIR=$(pwd)/dist/

if [ -n "$PROFILE" ]; then
  profile="--profile $PROFILE"
else
  profile="stg-Suscripciones"
fi

full_parallel_dir=$DIST_DIR/$parallelDir
echo "Procesando Parallel Dir: $full_parallel_dir"
for dir in $(find "$full_parallel_dir" -type d -name "cdk" | sort -n); do
  if [ -d "$dir" ]; then
    echo "Ejecutando 'cdk deploy' $dir"
    filename="*-$ENV-*stack.template.json"
    file=$(find "$dir" -iname "$filename" -exec basename {} \;)
    echo "File: $file"
    if [ ! -z "$file" ]; then
      stack_name="${file%%.*}"
      echo "Procesando Stack Name: $stack_name ......."

      echo "Usando perfil: $PROFILE"
      aws sts get-caller-identity --profile $PROFILE

      cdk deploy --app "$dir" $stack_name --require-approval never $profile --http-timeout 600 || exit 1
      echo ".......Proceso completo para el stack $stack_name"
    else
      echo "*********************************************"
      echo "*********** '$filename' no existe ***********"
      echo "*********************************************"
    fi
  fi
done
