#!/bin/bash

echo "🔍 Verificando la disponibilidad de MySQL..."

while ! docker exec -i mysql-database mysqladmin -uroot -proot_LN2022 ping &> /dev/null; do
  echo "❌ MySQL no está disponible, esperando 5 segundos..."
  sleep 5
done

echo "✅ MySQL disponible. Ejecutando script de base de datos..."

docker exec -i mysql-database mysql -uroot -proot_LN2022 db < ./solutionItems/sql-scripts/MensajesRecibidos_DB_Artifacts.sql

if [ $? -ne 0 ]; then
  echo "❌ Error al ejecutar el script SQL. Verificá el archivo y la base de datos."
else
  echo "✅ Script ejecutado correctamente. Asegurando que MySQL esté corriendo..."
  docker start mysql-database
fi
