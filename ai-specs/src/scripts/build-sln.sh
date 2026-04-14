#!/bin/bash
set -e

echo "🔧 Compilando solución completa..."

dotnet build Ln.Sus.Monorepo.Template.sln

echo "✅ Build completo de la solución .sln"