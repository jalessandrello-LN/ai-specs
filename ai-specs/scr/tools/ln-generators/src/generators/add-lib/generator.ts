import {
  Tree,
  formatFiles,
  generateFiles,
  joinPathFragments,
  names,
} from '@nx/devkit';

import { execSync } from 'child_process';

interface Options {
  name: string;
}

function normalizeOptions(options: Options) {
  const cleanName = options.name; // No usar kebab-case
  const projectRoot = joinPathFragments('libs', cleanName);

  const nameParts = names(options.name);

  return {
    ...options,
    ...nameParts,
    name: cleanName,
    tmpl: '',
    projectRoot,
  };
}

export default async function (tree: Tree, options: Options) {
  const normalized = normalizeOptions(options);
  const slnFile = 'LLn.Sus.Monorepo.Template.sln';

  // Generar estructura de archivos completa desde plantilla
  console.log('Variables disponibles para templates:', normalized);

  // Copiar el template del listener
  generateFiles(
    tree,
    joinPathFragments(__dirname, 'files', 'src', '__name__'),
    normalized.projectRoot,
    normalized
  );

  // Crear project.json para compatibilidad con Nx
  tree.write(
    joinPathFragments(normalized.projectRoot, 'project.json'),
    JSON.stringify(
      {
        name: normalized.name,
        projectType: 'library',
        sourceRoot: `${normalized.projectRoot}/src`,
        targets: {
          build: {
            executor: 'nx:run-commands',
            options: {
              commands: [
                `dotnet build libs/${normalized.name}/${normalized.name}.csproj`,
              ],
            },
          },
          serve: {
            executor: 'nx:run-commands',
            options: {
              cwd: `${normalized.projectRoot}/libs/${normalized.name}`,
              commands: ['dotnet run'],
            },
          },
        },
        tags: [],
      },
      null,
      2
    )
  );

  try {
    const appProject = joinPathFragments(
      normalized.projectRoot,
      `${normalized.name}.csproj`
    );

    await formatFiles(tree);

    return () => {
      try {
        execSync(`dotnet sln ${slnFile} add ${appProject}`);
        console.log(
          `✅ Proyecto ${normalized.name} agregado a la solución .sln`
        );
      } catch (error) {
        console.warn(`⚠️ Error al agregar proyectos a la solución: ${error}`);
      }
    };
  } catch (error) {
    console.warn(`⚠️ Error al agregar proyectos a la solución: ${error}`);
  }
}
