#!/bin/bash

# Verificar si el contenedor "localstack_main" ya existe
if ! docker ps -a --format '{{.Names}}' | grep -iq "localstack_main"; then
  # Si no existe, crear y levantar el contenedor usando docker-compose-localstack.yml
  docker-compose -f ./solutionItems/localstack/docker-compose.yml up -d
else
  # Si existe, simplemente iniciar el contenedor
  docker start localstack_main
fi

# Esperar unos segundos para asegurarse de que el contenedor se haya iniciado correctamente
sleep 5

# Verificar si el contenedor "mysql-database" ya existe
if ! docker ps -a --format '{{.Names}}' | grep -iq "mysql-database"; then
  # Si no existe, crear y levantar el contenedor usando docker-compose-sql.yml
  docker-compose -f ./solutionItems/mysql/docker-compose.yml up -d
else
  # Si existe, simplemente iniciar el contenedor
  docker start mysql-database
fi

echo "✅ Todas las operaciones completadas."
